//
//  SettingSectionHeader.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/8/1.
//

import UIKit

class SettingSectionHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension SettingSectionHeader {
    func configUI() {
        addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 25)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}
