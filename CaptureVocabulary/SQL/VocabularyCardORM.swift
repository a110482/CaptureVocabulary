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
    static let id = Expression<Int64>("id")
    static let normalizedSource = Expression<String>("normalizedSource")
    static let normalizedTarget = Expression<String>("normalizedTarget")
    // 是否標示為刪除
    static let enable = Expression<Bool>("enable")
    // 標示為已記憶 (複習不出現, 但測驗會出)
    static let memorized = Expression<Bool>("memorized")
    static let timestamp = Expression<Double>("timestamp")
    static let cardListId = Expression<Int64>("cardListId")
    
    /// version 2 以後新增欄位 參見: SQLCoreMigration_2
    static let phonetic = Expression<String>("phonetic")
    
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
    typealias ORMModel =  VocabularyCardORM
    
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
}

// MARK: -
struct VocabularyCardListORM: TableType {
    static let table = Table("vocabularyCardList")
    static let id = Expression<Int64>("id")
    static let name = Expression<String>("name")
    // 是否標示為刪除
    static let enable = Expression<Bool>("enable")
    // 標示為已記憶 (複習不出現, 但測驗會出)
    static let memorized = Expression<Bool>("memorized")
    static let timestamp = Expression<Double>("timestamp")
    
    struct ORM: ORMProtocol {
        var id: Int64? = nil
        var name: String?
        var enable: Bool?
        var memorized: Bool?
        var timestamp: TimeInterval = Date().timeIntervalSince1970
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(enable, defaultValue: true)
                t.column(memorized, defaultValue: false)
                t.column(timestamp)
            })
        }
        catch {
            print(error)
        }
    }
    
    static func delete(_ orm: ORM) {
        guard orm.id != nil else { return }
        do {
            try SQLCore.shared.db.run(self.table.filter(self.id == orm.id!).delete())
        }
        catch { print(error) }
    }
}

extension VocabularyCardListORM.ORM: ORMTranslateAble {
    typealias ORMModel = VocabularyCardListORM
    
    static func newList() -> Self? {
        let dateString = Date().string(withFormat: "yyyy/MM/dd")
        var defaultName = NSLocalizedString("VocabularyCardListORM.ORM.word", comment: "單字") + dateString
        let defaultNameScalar = ORMModel.table.filter(ORMModel.name.like("\(defaultName)%")).count
        let count = ORMModel.scalar(defaultNameScalar, type: Int.self) ?? 0
        if count > 0 {
            defaultName += "(\(count))"
        }
        
        var createObj = Self()
        createObj.name = defaultName
        ORMModel.create(createObj)
        
        let query = ORMModel.table.order(ORMModel.id.desc).limit(1)
        guard let orm = ORMModel.prepare(query)?.first else { return nil }
        return orm
    }
    
    @discardableResult static func createDefaultList() -> Self? {
        guard (allList()?.count ?? 0) == 0 else { return nil }
        return newList()
    }
    
    static func lastEditList() -> Self? {
        let query = ORMModel.table.order(ORMModel.timestamp.desc)
        return ORMModel.prepare(query)?.first
    }
    
    static func allList() -> [Self]? {
        let query = ORMModel.table.order(ORMModel.id.desc)
        return ORMModel.prepare(query)
    }
}
