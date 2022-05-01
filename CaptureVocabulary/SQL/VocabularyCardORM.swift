//
//  VocabularyCardORM.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/1.
//

import Foundation
import SQLite

class Database {
    static let shared = Database()
    let db: Connection
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        db = try! Connection("\(path)/db.sqlite3")
    }
}


protocol TableType {
    associatedtype ORM: Codable
    static var table: Table { get }
    func createTable(db: Connection)
    func create(_ orm: ORM)
    func prepare(_ query: QueryType) -> [ORM]?
    func clear()
}

extension TableType {
    func prepare(_ query: QueryType) -> [ORM]? {
        do {
            return try Database.shared.db.prepare(query).map {
                return try $0.decode()
            }
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func pluck(_ query: QueryType) -> ORM? {
        do {
            return try Database.shared.db.pluck(query)?.decode()
        }
        catch {
            print(error)
            return nil
        }
    }
    
    func create(_ orm: ORM) {
        do {
            try Database.shared.db.run(Self.table.insert(orm))
        }
        catch { print(error) }
    }
    
    func clear() {
        let _ = try? Database.shared.db.run(Self.table.delete())
    }
    
    func drop() {
        let _ = try? Database.shared.db.run(Self.table.drop())
    }
}

// MARK: -
struct VocabularyCardORM: TableType {
    static let table = Table("vocabularyCard")
    private let id = Expression<Int64>("id")
    private let normalizedSource = Expression<String>("normalizedSource")
    private let normalizedTarget = Expression<String>("normalizedTarget")
    
    private var db: Connection {
        Database.shared.db
    }
    
    struct ORM: Codable {
        var id: Int64? = nil
        var normalizedSource: String
        var normalizedTarget: String
    }
    
    func createTable(db: Connection = Database.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(normalizedSource, unique: true)
                t.column(normalizedTarget)
            })
        }
        catch {
            print(error)
        }
    }
}

// MARK: -

