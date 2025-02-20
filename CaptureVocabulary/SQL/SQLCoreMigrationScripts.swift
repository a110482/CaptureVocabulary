//
//  SQLCoreMigrationScripts.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/21.
//

import Foundation

struct SQLCoreMigration_newDatabase: MigrationProcess {
    /// 基本上此腳本已不使用, 可於 2024.8.1 以後重構刪除
    let dbVersionNumber: Int = AppParameters.shared.model.lastDatabaseVersion
    
    func process() {
        SQLCore.shared.createTables()
        VocabularyCardListORM.ORM.createDefaultList()
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


// 新建 db 或是拷貝舊版 db
struct SQLCoreMigration_1: MigrationProcess {
    /// 基本上此腳本已不使用, 可於 2024.8.1 以後重構刪除
    let dbVersionNumber: Int = 1
    
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
    
    let dbVersionNumber: Int = 2
    
    func process() {
        do {
            try addColumn()
            updateDateBase()
        } catch {
            Log.debug(error.localizedDescription)
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

// 本地化資料庫內容
struct SQLCoreMigration_3: MigrationProcess {
    typealias Card = VocabularyCardORM
    
    let dbVersionNumber: Int = 3
    
    func process() throws {
        guard let cards = Card.prepare(Card.table) else {
            return
        }
        for card in cards {
            var cardCopy = card
            cardCopy.normalizedTarget = card.normalizedTarget?.localized()
            cardCopy.update()
        }
    }
}

// 建立例句資料庫
struct SQLCoreMigration_4: MigrationProcess {
    let dbVersionNumber: Int = 4
    
    func process() throws {
        SimpleSentencesORM.createTable()
    }
}

// 建立單字卡上次記憶時間
struct SQLCoreMigration_5: MigrationProcess {
    typealias Card = VocabularyCardORM
    let dbVersionNumber: Int = 5
    
    func process() throws {
        try addColumn()
    }
    
    private func addColumn() throws {
        let addColumnTimestamp = Card.table.addColumn(Card.memorizedTimestamp, defaultValue: Date().timeIntervalSince1970)
        try SQLCore.shared.db.run(addColumnTimestamp)
        let addColumnTimes = Card.table.addColumn(Card.memorizedTimes, defaultValue: Int64.zero)
        try SQLCore.shared.db.run(addColumnTimes)
    }
}
