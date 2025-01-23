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
class SQLCoreMigration {
    private static var currentDatabaseVersion: Int { readDatabaseVersion() }
    static let migrationScripts: [MigrationProcess] = [
        SQLCoreMigration_1(),
        SQLCoreMigration_2(),
        SQLCoreMigration_3(),
        SQLCoreMigration_4(),
        SQLCoreMigration_5(),
    ]
    
    static func checkVersion(_ completion: () -> Void) throws {
        switch analysisDatabaseStatus() {
        case .newUser:
            try createNewDatabase()
            completion()
        case .oldVersionSystem(let version):
            writeDatabaseVersion(version: version)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.currentDatabaseVersion.rawValue)
        case .needUpdate:
            try migration()
            try checkVersion(completion)
        case .isLastVersion:
            completion()
        }
    }
    
    static func reset() {
        writeDatabaseVersion(version: 0)
    }
    
    static func debugTest() {
        recoverDatabase()
        writeDatabaseVersion(version: 1)
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

extension SQLCoreMigration {
    enum DatabaseStatus {
        case newUser
        /// (準備遷移到新版號系統)
        case oldVersionSystem(version: Int)
        case needUpdate
        case isLastVersion
    }
}

private extension SQLCoreMigration {
    static func migration() throws {
        guard let script = migrationScripts[safe: currentDatabaseVersion] else {
            // 拋出 error
            throw SQLCoreMigrationError.noMigrationScript
        }
        try script.process()
        script.updateVersionNumber()
    }
    
    static func createNewDatabase() throws {
        let script = SQLCoreMigration_newDatabase()
        script.process()
        script.updateVersionNumber()
    }
    
    static func readDatabaseVersion() -> Int {
        let userVersion = (try? SQLCore.shared.db.scalar("PRAGMA user_version") as? Int64) ?? 0
        return Int(userVersion)
    }
    
    static func writeDatabaseVersion(version: Int) {
        let _ = try? SQLCore.shared.db.run("PRAGMA user_version = \(version)")
    }
    
    static func analysisDatabaseStatus() -> DatabaseStatus {
        let count = try! SQLCore.shared.db.scalar("SELECT count(*) FROM sqlite_master WHERE type='table';") as! Int64
        if count == 0 { return .newUser }
        
        if let oldVersion = UserDefaults.standard[UserDefaultsKeys.currentDatabaseVersion] {
            return .oldVersionSystem(version: oldVersion)
        }
        
        if currentDatabaseVersion < migrationScripts.count {
            return .needUpdate
        }
        
        return .isLastVersion
    }
}

protocol MigrationProcess {
    /// 版號，從一開始起跳 (所以是 SQLCoreMigration.migrationScripts index + 1)
    var dbVersionNumber: Int { get }
    func process() throws
    func updateVersionNumber()
}

extension MigrationProcess {
    var dbVersionNumber: Int {
        let index = SQLCoreMigration.migrationScripts.firstIndex(where: { type(of: $0) == Self.self })
        assert(index != nil, "可能有新的 Migration 腳本未新增到 SQLCoreMigration.migrationScripts")
        return (index ?? 0) + 1
    }
    
    func updateVersionNumber() {
        SQLCoreMigration.writeDatabaseVersion(version: dbVersionNumber)
    }
}

extension String: Error {}
