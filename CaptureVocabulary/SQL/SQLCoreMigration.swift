//
//  SQLCoreMigration.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/20.
//

import SQLite

// MARK: -
enum SQLCoreMigrationError: Error {
    case noMigrationScript
    
    var localizedDescription: String {
        switch self {
        case .noMigrationScript:
            return "無對應更新腳本"
        }
    }
}

class SQLCoreMigration {
    private static let lastDatabaseVersion = AppParameters.shared.model.lastDatabaseVersion
    private static var currentDatabaseVersion: Int { UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] ?? 0
    }
    private static let migrationScripts: [MigrationProcess] = [
        SQLCoreMigration_1(),
        SQLCoreMigration_2()
    ]
    
    static func checkVersion(_ completion: () -> Void) throws {
        guard lastDatabaseVersion > currentDatabaseVersion else {
            completion()
            return
        }
        try migration()
        try checkVersion(completion)
    }
    
    static func reset() {
        UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] = 0
    }
    
    private static func migration() throws {
        guard let script = migrationScripts[safe: currentDatabaseVersion] else {
            // 拋出 error
            throw SQLCoreMigrationError.noMigrationScript
        }
        try script.process()
        script.updateVersionNumber()
    }
    
    static func debugTest() {
        recoverDatabase()
        UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] = 1
    }
    
    static func backDataBase() {
        let databaseURL = SQLCore.groupDatabaseURL
        let backupURL = SQLCore.backupDatabaseURL
        
        do {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: databaseURL, to: backupURL)
            Log.debug("backDataBase completed")
        } catch {
            assert(false, error.localizedDescription)
        }
    }
    
    static func recoverDatabase() {
        let databaseURL = SQLCore.groupDatabaseURL
        let backupURL = SQLCore.backupDatabaseURL
        
        do {
            if FileManager.default.fileExists(atPath: databaseURL.path) {
                try FileManager.default.removeItem(at: databaseURL)
            }
            try FileManager.default.copyItem(at: backupURL, to: databaseURL)
            Log.debug("recoverDatabase completed")
        } catch {
            assert(false, error.localizedDescription)
        }
    }
}


protocol MigrationProcess {
    func process() throws
    func updateVersionNumber()
}

extension MigrationProcess {
    func updateVersionNumber() {
        let currentDatabaseVersion =  UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] ?? 0
        
        UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] = currentDatabaseVersion + 1
    }
}

// 新建 db 或是拷貝舊版 db
struct SQLCoreMigration_1: MigrationProcess {
    func process() {
        let count = try! SQLCore.oldDatabase.db.scalar("SELECT count(*) FROM sqlite_master WHERE type='table';") as! Int64
        if count == 0 {
            // 未建立過 db
            SQLCore.shared.createTables()
            VocabularyCardListORM.ORM.createDefaultList()
        } else {
            // 有舊的就拷貝
            copyDatabase()
        }
    }
    
    private func copyDatabase() {
        let sourceURL = SQLCore.firstVersionDatabaseURL
        let targetURL = SQLCore.groupDatabaseURL
        
        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: targetURL)
        } catch {
            assert(false, error.localizedDescription)
        }
    }
}

// 新增音標到單字庫裡
struct SQLCoreMigration_2: MigrationProcess {
    typealias Card = VocabularyCardORM
    func process() {
        do {
            try addColumn()
            updateDateBase()
        } catch {
            assert(false, error.localizedDescription)
        }
    }
    
    private func addColumn() throws {
        let addColumn = Card.table.addColumn(
            Card.phonetic, defaultValue: "")
        try SQLCore.shared.db.run(addColumn)
    }
    
    // 查詢所有單字
    private func updateDateBase() {
        guard let allCards = Card.prepare(Card.table) else {
            return
        }
        allCards.forEach {
            var card = $0
            guard let source = card.normalizedSource else { return }
            let phonetic = StarDictORM.query(word: source)?.phonetic
            card.phonetic = phonetic
            card.update()
        }
    }
}
