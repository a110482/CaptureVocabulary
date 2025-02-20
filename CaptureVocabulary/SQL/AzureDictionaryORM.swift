//
//  AzureDictionaryORM.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/1.
//

import Foundation
import SQLite

struct AzureDictionaryORM: TableType {
    static var table = Table("azureDictionary")
    struct ORM: ORMProtocol {
        var id: Int64?
        var normalizedSource: String
        var displaySource: String
    }
    static let id = SQLite.Expression<Int64>("id")
    static let normalizedSource = SQLite.Expression<String>("normalizedSource")
    static let displaySource = SQLite.Expression<String>("displaySource")
    
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(normalizedSource, unique: true)
                t.column(displaySource)
            })
        }
        catch {
            print(error)
        }
    }
}

// MARK: -
struct AzureDictionaryTranslationORM: TableType {
    static var table = Table("azureDictionaryTranslation")
    struct ORM: ORMProtocol {
        var id: Int64?
        var posTag: String
        var prefixWord: String
        var displayTarget: String
        var confidence: Double
        var normalizedTarget: String
        var backTranslations: Data?
        var azureDictionaryId: Int64
    }
    
    static let id = SQLite.Expression<Int64>("id")
    static let posTag = SQLite.Expression<String>("posTag")
    static let prefixWord = SQLite.Expression<String>("prefixWord")
    static let displayTarget = SQLite.Expression<String>("displayTarget")
    static let confidence = SQLite.Expression<Double>("confidence")
    static let normalizedTarget = SQLite.Expression<String>("normalizedTarget")
    static let backTranslations = SQLite.Expression<Data?>("backTranslations")
    static let azureDictionaryId = SQLite.Expression<Int64>("azureDictionaryId")
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(posTag)
                t.column(prefixWord)
                t.column(displayTarget)
                t.column(confidence)
                t.column(normalizedTarget)
                t.column(backTranslations)
                t.column(azureDictionaryId, references: AzureDictionaryORM.table, id)
                t.foreignKey(azureDictionaryId,
                             references: AzureDictionaryORM.table, id,
                             update: .cascade,
                             delete: .cascade)
            })
        }
        catch {
            print(error)
        }
    }
}
