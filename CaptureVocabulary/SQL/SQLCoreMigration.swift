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
    
    case test
    
    var localizedDescription: String {
        switch self {
        case .noMigrationScript:
            return "無對應更新腳本"
        case .test:
            return "測試引發錯誤"
        }
    }
}

/// 修改資料庫步驟
/// 1. 更改資料庫 model e.x. VocabularyCardORM
/// 2. 新增 SQLCoreMigration 步驟, 讓舊用戶可以升級到新版資料庫
/// 3. 修改 SQLCoreMigration_newDatabase 讓全新用戶可以直接升到最新版本
/// 4. 記得修改 Plist file "lastDatabaseVersion"  !!!!
class SQLCoreMigration {
    private static let lastDatabaseVersion = AppParameters.shared.model.lastDatabaseVersion
    private static var currentDatabaseVersion: Int { UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] ?? 0
    }
    private static let migrationScripts: [MigrationProcess] = [
        SQLCoreMigration_1(),
        SQLCoreMigration_2(),
        SQLCoreMigration_3(),
        SQLCoreMigration_4(),
        SQLCoreMigration_5(),
    ]
    
    static func checkVersion(_ completion: () -> Void) throws {
        // 新建資料庫
        let count = try! SQLCore.shared.db.scalar("SELECT count(*) FROM sqlite_master WHERE type='table';") as! Int64
        if count == 0 {
            // 未建立過 db
            try createNewDatabase()
            completion()
            return
        }
        
        // 舊有資料庫升級
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
    
    private static func createNewDatabase() throws {
        let script = SQLCoreMigration_newDatabase()
        script.process()
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
    var dbVersionNumber: Int { get }
    func process() throws
    func updateVersionNumber()
}

extension MigrationProcess {
    func updateVersionNumber() {
        UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] = dbVersionNumber
    }
}

extension String: Error {}
