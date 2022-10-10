//
//  SQLCore.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/2.
//

import SQLite

class SQLCore {
    static let shared = SQLCore()
    let db: Connection
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        db = try! Connection("\(path)/db.sqlite3")
        try? db.execute("PRAGMA foreign_keys=ON")
    }
    
    private var tables: Array<TableProtocol.Type> {
        [
            VocabularyCardListORM.self,
            VocabularyCardORM.self,
            AzureDictionaryORM.self,
            AzureDictionaryTranslationORM.self,
            YDTranslateORM.self
        ]
    }
    
    func createTables() {
        #warning("資料庫版本遷移功能")
        tables.forEach {
            $0.createTable(db: db)
        }
    }
    
    func dropTables() {
        tables.forEach {
            $0.dropTable()
        }
    }
    
    func deleteTables() {
        tables.forEach {
            $0.deleteTable()
        }
    }
}

protocol ORMProtocol: Codable {
    var id: Int64? { get }
}

protocol TableProtocol {
    static func createTable(db: Connection)
    static func deleteTable()
    static func dropTable()
}

protocol TableType: TableProtocol {
    associatedtype ORM: ORMProtocol
    static var table: Table { get }
    static var id: Expression<Int64> { get }
    static func create(_ orm: ORM)
    static func delete(_ orm: ORM)
    static func prepare(_ query: QueryType) -> [ORM]?
}

extension TableType {
    static func prepare(_ query: QueryType) -> [ORM]? {
        do {
            return try SQLCore.shared.db.prepare(query).map {
                return try $0.decode()
            }
        }
        catch {
            print(error)
            return nil
        }
    }
    
    static func scalar<V: Value>(_ scalar: ScalarQuery<V>, type: V.Type) -> V? {
        do {
            return try SQLCore.shared.db.scalar(scalar)
        }
        catch {
            print(error)
            return nil
        }
    }
    
    static func create(_ orm: ORM) {
        do {
            try SQLCore.shared.db.run(Self.table.insert(orm))
        }
        catch { print(error) }
    }
    
    static func delete(_ orm: ORM) {
        guard orm.id != nil else { return }
        do {
            try SQLCore.shared.db.run(self.table.filter(self.id == orm.id!).delete())
        }
        catch { print(error) }
    }
    
    static func deleteTable() {
        let _ = try? SQLCore.shared.db.run(Self.table.delete())
    }
    
    static func dropTable() {
        let _ = try? SQLCore.shared.db.run(Self.table.drop())
    }
    
    static func update(_ orm: ORM) {
        guard orm.id != nil else { return }
        do {
            try SQLCore.shared.db.run(self.table.filter(self.id == orm.id!).update(orm))
        }
        catch { print(error) }
    }
}
