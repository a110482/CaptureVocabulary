//
//  ORMTranslateAble.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/2.
//

import SQLite

protocol ORMTranslateAble {
    associatedtype ORMModel: TableType
    func create(_ foreignKey: Int64?)
    func update()
    func delete()
}

extension ORMTranslateAble {
    func create(_ foreignKey: Int64?) {
        guard type(of: self) == ORMModel.ORM.self else { return }
        ORMModel.create(self as! Self.ORMModel.ORM)
    }
    func update(){
        guard type(of: self) == ORMModel.ORM.self else { return }
        guard (self as! Self.ORMModel.ORM).id != nil else { return }
        ORMModel.update(self as! Self.ORMModel.ORM)
    }
    func delete() {
        guard type(of: self) == ORMModel.ORM.self else { return }
        guard (self as! Self.ORMModel.ORM).id != nil else { return }
        ORMModel.delete(self as! ORMModel.ORM)
    }
}
