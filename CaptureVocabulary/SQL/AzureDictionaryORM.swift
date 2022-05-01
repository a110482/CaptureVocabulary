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
    let id = Expression<Int64>("id")
    let normalizedSource = Expression<String>("normalizedSource")
    let displaySource = Expression<String>("displaySource")
    
    
    func createTable(db: Connection = Database.shared.db) {
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
    
    private let id = Expression<Int64>("id")
    private let posTag = Expression<String>("posTag")
    private let prefixWord = Expression<String>("prefixWord")
    private let displayTarget = Expression<String>("displayTarget")
    private let confidence = Expression<Double>("confidence")
    private let normalizedTarget = Expression<String>("normalizedTarget")
    private let backTranslations = Expression<Data?>("backTranslations")
    private let azureDictionaryId = Expression<Int64>("azureDictionaryId")
    
    func createTable(db: Connection = Database.shared.db) {
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
