//
//  SQLCoreMigration.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/20.
//

import SQLite

// MARK: -
class SQLCoreMigration {
    private static let lastDatabaseVersion = AppParameters.shared.model.lastDatabaseVersion
    private static var currentDatabaseVersion: Int { UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] ?? 0
    }
    private static let migrationScripts: [MigrationProcess] = [
        SQLCoreMigration_1(),
    ]
    
    static func checkVersion() {
        guard lastDatabaseVersion > currentDatabaseVersion else {
            return
        }
        migration()
        checkVersion()
    }
    
    static func reset() {
        UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] = 0
    }
    
    private static func migration() {
        Log.debug("目前資料庫版本 \(currentDatabaseVersion)")
        guard let script = migrationScripts[safe: currentDatabaseVersion] else {
            assert(false, "資料庫更新 version: \(currentDatabaseVersion), 無對應腳本")
            return
        }
        Log.debug("正在更新資料庫版本 \(currentDatabaseVersion)")
        script.process()
        script.updateVersionNumber()
        Log.debug("已更新資料庫版本 \(currentDatabaseVersion)")
    }
}


protocol MigrationProcess {
    func process()
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
