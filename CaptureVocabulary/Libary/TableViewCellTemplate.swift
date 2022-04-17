//
//  TableViewCellProtocol.swift
//  JX_SBK_UI_MODULE
//
//  Created by 譚培成 on 2021/9/11.
//

import Foundation

enum CellType: String {
    case red
    case blue
}

protocol CellModel {
    var type: CellType { get }
}

protocol ProtocolCell: AnyObject {
    static var type: CellType { get }
    func config(dataModel: CellModel)
}

protocol ConfigCellType: ProtocolCell {
    associatedtype ModelType: CellModel
}

extension ConfigCellType {
    func checkType(model: CellModel) -> Bool {
        return model.type == Self.type
    }
    func convertModel(model: CellModel) -> ModelType? {
        guard checkType(model: model) else {
            return nil
        }
        return model as? ModelType
    }
}
