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
    ]
    
    private static weak var statusLabel: UILabel?
    
    
    static func checkVersion(statusLabel: UILabel? = nil, _ completion: () -> Void) throws {
        Self.statusLabel = statusLabel
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
        Self.statusLabel?.text = "目前資料庫版本 \(currentDatabaseVersion)"
        guard let script = migrationScripts[safe: currentDatabaseVersion] else {
            // 拋出 error
            throw SQLCoreMigrationError.noMigrationScript
        }
        Self.statusLabel?.text = "正在更新資料庫版本 \(currentDatabaseVersion)"
        try script.process()
        script.updateVersionNumber()
        Self.statusLabel?.text = "已更新資料庫版本 \(currentDatabaseVersion)"
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
