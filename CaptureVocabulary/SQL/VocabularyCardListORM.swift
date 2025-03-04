//
//  VocabularyCardListORM.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/23.
//

import Foundation
import SQLite


struct VocabularyCardListORM: TableType {
    static let table = Table("vocabularyCardList")
    static let id = SQLite.Expression<Int64>("id")
    static let name = SQLite.Expression<String>("name")
    // 是否標示為刪除
    static let enable = SQLite.Expression<Bool>("enable")
    // 標示為已記憶 (複習不出現, 但測驗會出)
    static let memorized = SQLite.Expression<Bool>("memorized")
    static let timestamp = SQLite.Expression<Double>("timestamp")
    
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
    
    /// 建立預設空的單字列表
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
    
    static func getList(by listId: Int64) -> Self? {
        let query = ORMModel.table.filter(ORMModel.id == listId).limit(1)
        return ORMModel.prepare(query)?.first
    }
}
