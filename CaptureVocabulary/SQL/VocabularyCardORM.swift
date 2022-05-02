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
    
    private var db: Connection {
        SQLCore.shared.db
    }
    
    struct ORM: Codable {
        var id: Int64? = nil
        var normalizedSource: String
        var normalizedTarget: String
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
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

