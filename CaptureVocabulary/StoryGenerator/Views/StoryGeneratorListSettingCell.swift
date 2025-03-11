//
//  StoryGeneratorListSettingCell.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/20.
//

import UIKit
import RxSwift
import RxCocoa

class StoryGeneratorListSettingCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    
    private let selectedIcon = UIImageView()
    private let titleLabel = UILabel()
}

extension StoryGeneratorListSettingCell {
    func config(cellModel: StoryGeneratorListSettingCellModel) {
        titleLabel.text = cellModel.title
        let selectedImage = UIImage(named: "checkIcon")
        selectedIcon.image = cellModel.isSelected ? selectedImage : nil
    }
}

// UI
private extension StoryGeneratorListSettingCell {
    func configUI() {
        selectionStyle = .none
        
        contentView.addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.size.equalTo(17)
        }
        selectedIcon.layer.cornerRadius = 4
        selectedIcon.layer.borderColor = "667080".color.cgColor
        selectedIcon.layer.borderWidth = 1
        selectedIcon.contentMode = .scaleAspectFill
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(selectedIcon.snp.right).offset(15)
        }
        titleLabel.numberOfLines = 2
    }
}

// MARK: cellModel -
struct StoryGeneratorListSettingCellModel {
    let orm: VocabularyCardListORM.ORM
    var title: String? { orm.name }
    var id: Int64 { orm.id ?? 0 }
    var isSelected: Bool
    
    init(orm: VocabularyCardListORM.ORM) {
        self.orm = orm
        self.isSelected = !(orm.memorized ?? true)
    }
}
