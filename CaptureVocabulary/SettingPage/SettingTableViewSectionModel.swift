//
//  SettingTableViewSectionModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/23.
//

import UIKit

struct SettingTableViewSectionModel {
    var title: String
    var cellModels: [any SettingPageCellModelProtocol]
}

enum SettingPageCellType: String {
    case readingSpeed
    case readingSimpleSentenceOption
    case moreSetting
    case versionNumber
    
    var reuseId: String { self.rawValue }
}

protocol SettingPageCellModelProtocol {
    var type: SettingPageCellType { get }
}

protocol SettingPageCellProtocol: UITableViewCell {
    static var type: SettingPageCellType { get }
    func config(cellModel: any SettingPageCellModelProtocol)
    
    var cellLeftPadding: CGFloat { get }
}

extension SettingPageCellProtocol {
    var cellLeftPadding: CGFloat { 20 }
    var cellRightPadding: CGFloat { 30 }
}
