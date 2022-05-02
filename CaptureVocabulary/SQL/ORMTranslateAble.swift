//
//  ORMTranslateAble.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/2.
//

import SQLite

protocol ORMTranslateAble {
    associatedtype ORMModel: TableType
    func save(_ foreignKey: Int64?)
    static func load(key: String? ,foreignKey: Int64?) -> [Self]
}
