//
//  SimpleSentencesORM.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/11/21.
//

import SQLite

struct SimpleSentencesORM: TableType {
    static let table = Table("simpleSentences")
    static let id = Expression<Int64>("id")
    static let normalizedSource = Expression<String>("normalizedSource")
    static let sentence = Expression<String>("sentence")
    static let translate = Expression<String>("translate")
    
    
    struct ORM: ORMProtocol {
        var id: Int64? = nil
        var normalizedSource: String?
        var sentence: String?
        var translate: String?
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(normalizedSource)
                t.column(sentence)
                t.column(translate)
            })
        }
        catch {
            print(error)
        }
    }
}

extension SimpleSentencesORM.ORM {
    typealias ORMModel = SimpleSentencesORM
    
    static func get(normalizedSource: String) -> [Self]? {
        let query = ORMModel.table.filter(ORMModel.normalizedSource == normalizedSource)
        return ORMModel.prepare(query)
    }
}
