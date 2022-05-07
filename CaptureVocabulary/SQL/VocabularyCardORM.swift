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
    static let timestamp = Expression<Double>("timeStamp")
    static let listId = Expression<Int64>("groupId")
    
    private var db: Connection {
        SQLCore.shared.db
    }
    
    struct ORM: ORMProtocol {
        var id: Int64? = nil
        var normalizedSource: String?
        var normalizedTarget: String?
        var enable: Bool?
        var memorized: Bool?
        var timestamp: TimeInterval?
        var groupId: Int64?
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(normalizedSource)
                t.column(normalizedTarget)
                t.column(enable, defaultValue: true)
                t.column(memorized, defaultValue: false)
                t.column(timestamp, defaultValue: Date().timeIntervalSince1970)
                t.column(listId, references: VocabularyCardListORM.table, id)
            })
        }
        catch {
            print(error)
        }
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
}

extension VocabularyCardListORM.ORM: ORMTranslateAble {
    typealias ORMModel = VocabularyCardListORM
    
    static func newList() -> Self? {
        let dateString = Date().string(withFormat: "yyyy/MM/dd")
        var defaultName = "我的單字".localized() + dateString
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
    
    static func lastEditList() -> Self? {
        let query = ORMModel.table.order(ORMModel.timestamp.desc)
        return ORMModel.prepare(query)?.first
    }
    
    static func allList() -> [Self]? {
        let query = ORMModel.table.order(ORMModel.id.desc)
        return ORMModel.prepare(query)
    }
}
