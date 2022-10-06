//
//  YDTranslateORM.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/10/6.
//

import Foundation
import SQLite

struct YDTranslateORM: TableType {
    static var table = Table("YDTranslateORM")
    struct ORM: ORMProtocol {
        var id: Int64?
        var query: String
        var data: Data?
    }
    static let id = Expression<Int64>("id")
    static let query = Expression<String>("query")
    static let data = Expression<Data?>("data")
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(query, unique: true)
                t.column(data)
            })
        }
        catch {
            print(error)
        }
    }
    
}
