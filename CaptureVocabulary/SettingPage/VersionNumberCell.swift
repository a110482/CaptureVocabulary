//
//  VersionNumberCell.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/27.
//

import UIKit

class VersionNumberCell: UITableViewCell, SettingPageCellProtocol {
    static let type: SettingPageCellType = .versionNumber
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(40).priority(999)
            make.top.bottom.equalToSuperview()
        }
        titleLabel.text = NSLocalizedString("SettingPageViewController.cell.versionTitle", comment: "版本號")
        
        contentView.addSubview(versionNumberLabel)
        versionNumberLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumberLabel.text = version
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func config(cellModel: any SettingPageCellModelProtocol) {}
    
    private let titleLabel = UILabel()
    private let versionNumberLabel = UILabel()
}

class VersionNumberCellModel: SettingPageCellModelProtocol {
    let type: SettingPageCellType = .versionNumber
}
