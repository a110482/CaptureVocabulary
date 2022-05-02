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
        createTables()
    }
    
    private func createTables() {
        VocabularyCardORM.createTable()
        AzureDictionaryORM.createTable()
        AzureDictionaryTranslationORM.createTable()
    }
}


protocol TableType {
    associatedtype ORM: Codable
    static var table: Table { get }
    static func createTable(db: Connection)
    static func create(_ orm: ORM)
    static func prepare(_ query: QueryType) -> [ORM]?
    static func clear()
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
    
    static func pluck(_ query: QueryType) -> ORM? {
        do {
            return try SQLCore.shared.db.pluck(query)?.decode()
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
    
    static func clear() {
        let _ = try? SQLCore.shared.db.run(Self.table.delete())
    }
    
    static func drop() {
        let _ = try? SQLCore.shared.db.run(Self.table.drop())
    }
}
