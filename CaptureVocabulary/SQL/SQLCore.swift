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
    }
    
    private var tables: Array<TableProtocol.Type> {
        [VocabularyCardORM.self,
         AzureDictionaryORM.self,
         AzureDictionaryTranslationORM.self
        ]
    }
    
    func createTables() {
        tables.forEach {
            $0.createTable(db: db)
        }
    }
    
    func dropTables() {
        tables.forEach {
            $0.drop()
        }
    }
    
    func deleteTables() {
        tables.forEach {
            $0.delete()
        }
    }
}

protocol ORMProtocol: Codable {
    var id: Int64? { get }
}

protocol TableProtocol {
    static func createTable(db: Connection)
    static func delete()
    static func drop()
}

protocol TableType: TableProtocol {
    associatedtype ORM: ORMProtocol
    static var table: Table { get }
    static var id: Expression<Int64> { get }
    static func create(_ orm: ORM)
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
    
    static func create(_ orm: ORM) {
        do {
            try SQLCore.shared.db.run(Self.table.insert(orm))
        }
        catch { print(error) }
    }
    
    static func delete() {
        let _ = try? SQLCore.shared.db.run(Self.table.delete())
    }
    
    static func drop() {
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
