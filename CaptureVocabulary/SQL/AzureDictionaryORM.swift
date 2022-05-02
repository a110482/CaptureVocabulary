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
    struct ORM: Codable {
        var id: Int64?
        var normalizedSource: String
        var displaySource: String
    }
    static let id = Expression<Int64>("id")
    static let normalizedSource = Expression<String>("normalizedSource")
    static let displaySource = Expression<String>("displaySource")
    
    
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
    struct ORM: Codable {
        var id: Int64?
        var posTag: String
        var prefixWord: String
        var displayTarget: String
        var confidence: Double
        var normalizedTarget: String
        var backTranslations: Data?
        var azureDictionaryId: Int64
    }
    
    static let id = Expression<Int64>("id")
    static let posTag = Expression<String>("posTag")
    static let prefixWord = Expression<String>("prefixWord")
    static let displayTarget = Expression<String>("displayTarget")
    static let confidence = Expression<Double>("confidence")
    static let normalizedTarget = Expression<String>("normalizedTarget")
    static let backTranslations = Expression<Data?>("backTranslations")
    static let azureDictionaryId = Expression<Int64>("azureDictionaryId")
    
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
