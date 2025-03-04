//
//  MyStoryTableViewCell.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/3/3.
//

import UIKit

class MyStoryTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private let titleLabel = UILabel()
}

extension MyStoryTableViewCell {
    func bind(cellModel: MyStoryTableViewCellModel) {
        titleLabel.text = cellModel.dataModel.title.ch
    }
}

private extension MyStoryTableViewCell {
    func configUI() {
        configTitle()
    }
    
    func configTitle() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
            make.top.equalTo(20)
        }
    }
}

// MARK: - cellModel
class MyStoryTableViewCellModel {
    let orm: StoryORM.ORM
    let dataModel: StoryDataModel
    
    init?(orm: StoryORM.ORM) {
        self.orm = orm
        guard let dataModel = orm.getStoryDataModel() else { return nil }
        self.dataModel = dataModel
    }
}
