//
//  VocabularyCardORM.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/1.
//

import Foundation
import SQLite


struct VocabularyCardORM: TableType {
    static let table = Table("vocabularyCard")
    static let id = SQLite.Expression<Int64>("id")
    static let normalizedSource = SQLite.Expression<String>("normalizedSource")
    static let normalizedTarget = SQLite.Expression<String>("normalizedTarget")
    // 是否標示為刪除
    static let enable = SQLite.Expression<Bool>("enable")
    // 標示為已記憶 (複習不出現, 但測驗會出)
    static let memorized = SQLite.Expression<Bool>("memorized")
    static let timestamp = SQLite.Expression<Double>("timestamp")
    static let cardListId = SQLite.Expression<Int64>("cardListId")
    
    /// version 2 以後新增欄位 參見: SQLCoreMigration_2
    static let phonetic = SQLite.Expression<String>("phonetic")
    
    /// version 5 以後新增欄位 參見: SQLCoreMigration_5
    static let memorizedTimestamp = SQLite.Expression<Double>("memorizedTimestamp")
    static let memorizedTimes = SQLite.Expression<Int64>("memorizedTimes")
    
    private var db: Connection {
        SQLCore.shared.db
    }
    
    struct ORM: ORMProtocol {
        var id: Int64? = nil
        var normalizedSource: String?
        var normalizedTarget: String?
        var enable: Bool?
        var memorized: Bool?
        var timestamp: TimeInterval = Date().timeIntervalSince1970
        var cardListId: Int64?
        var phonetic: String?
        var memorizedTimestamp: TimeInterval = Date().timeIntervalSince1970
        var memorizedTimes: Int64 = 0
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(normalizedSource)
                t.column(normalizedTarget)
                t.column(enable, defaultValue: true)
                t.column(memorized, defaultValue: false)
                t.column(timestamp)
                t.column(cardListId)
                t.column(phonetic)
                t.column(memorizedTimestamp)
                t.column(memorizedTimes)
                t.foreignKey(cardListId,
                             references: VocabularyCardListORM.table,
                             id,
                             update: .cascade,
                             delete: .cascade)
            })
        }
        catch {
            print(error)
        }
    }
}

extension VocabularyCardORM.ORM: ORMTranslateAble {
    typealias ORMModel = VocabularyCardORM
    
    private static func query(listIds: [Int64] = [], memorized: Bool? = nil) -> Table {
        var query = ORMModel.table
        if listIds.count > 0 {
            query = query.filter(listIds.contains(ORMModel.cardListId))
        }
        if let memorized = memorized {
            query = query.filter(ORMModel.memorized == memorized)
        }
        return query
    }
    
    static func allList(listId: Int64) -> [Self]? {
        let query = ORMModel.table.filter(ORMModel.cardListId == listId)
        return ORMModel.prepare(query)
    }
    
    /// 算出共有幾筆資料
    static func cardNumbers(listIds: [Int64] = [], memorized: Bool? = nil) -> Int {
        let query = query(listIds: listIds, memorized: memorized)
        return ORMModel.scalar(query.count, type: Int.self) ?? 0
    }
    
    /// 取出第 n 筆資料
    static func get(by index: Int, listIds: [Int64] = [], memorized: Bool? = nil) -> Self? {
        guard cardNumbers(listIds: listIds, memorized: memorized) > index else { return nil }
        let query = query(listIds: listIds, memorized: memorized).limit(1, offset: index)
        return ORMModel.prepare(query)?.first
    }
    
    /// 由 id 算出資料是第 n 筆
    static func getIndex(by id: Int?, listIds: [Int64] = [], memorized: Bool? = nil) -> Int {
        guard let id = id else { return 0 }
        let query = query(listIds: listIds, memorized: memorized).filter(ORMModel.id < Int64(id))
        return ORMModel.scalar(query.count, type: Int.self) ?? 0
    }
    
    /// 更新單字卡集的記憶狀況
    func updateVocabularyCardListMemorizedStatus() {
        typealias List =  VocabularyCardListORM
        guard let cardListId else { return }
        let query = List.table.filter(List.id == cardListId)
        guard var listObject = List.prepare(query)?.first else { return }
        let allCards = VocabularyCardORM.ORM.allList(listId: cardListId) ?? []
        listObject.memorized = allCards.allSatisfy({ $0.memorized ?? false })
        listObject.update()
    }
    
    func getListOrm() -> VocabularyCardListORM.ORM? {
        guard let cardListId else { return nil }
        return VocabularyCardListORM.ORM.getList(by: cardListId)
    }
}
