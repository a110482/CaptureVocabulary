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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardListStackView.arrangedSubviews
            .filter({ !($0 is UIImageView) })
            .forEach({ $0.removeFromSuperview() })
        
    }
    
    private let containerView = UIView()
    private let mainStackView = UIStackView()
    private let titleLabel = UILabel()
    private let cardListStackView = UIStackView()
}

extension MyStoryTableViewCell {
    func bind(cellModel: MyStoryTableViewCellModel) {
        titleLabel.text = cellModel.dataModel.title.ch
        for cardListTitle in cellModel.allCardListTitle {
            let label = UILabel(text: cardListTitle)
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = "3D5CFF".color
            cardListStackView.addArrangedSubview(label)
        }
    }
}

private extension MyStoryTableViewCell {
    func configUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        configContainerView()
        configStackView()
        configTitle()
        configCardListStackView()
    }
    
    func configContainerView() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(92)
            make.top.equalTo(5)
        }
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
    }
    
    func configStackView() {
        mainStackView.axis = .vertical
        mainStackView.alignment = .leading
        mainStackView.spacing = 10
        containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(24)
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }
    }
    
    func configTitle() {
        mainStackView.addArrangedSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    func configCardListStackView() {
        mainStackView.addArrangedSubview(cardListStackView)
        let folderIcon = UIImage(systemName: "folder")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: folderIcon)
        imageView.tintColor = "3D5CFF".color
        imageView.snp.makeConstraints { make in
            make.size.equalTo(18)
        }
        cardListStackView.addArrangedSubview(imageView)
        cardListStackView.spacing = 5
    }
}

// MARK: - cellModel
class MyStoryTableViewCellModel {
    let orm: StoryORM.ORM
    let dataModel: StoryDataModel
    var allCardListTitle: [String] {
        return loadCardListTitles(orm: orm)
    }
    
    init?(orm: StoryORM.ORM) {
        self.orm = orm
        guard let dataModel = orm.getStoryDataModel() else { return nil }
        self.dataModel = dataModel
    }
    
    private func loadCardListTitles(orm: StoryORM.ORM) -> [String] {
        let allCards = orm.getAllVocabularyCard()
        let allListOrm = allCards.compactMap({ $0.getListOrm() })
        // 去除重複
        let allListTitle: [String] = Array(Set(allListOrm.map({ $0.title })))
        return allListTitle
    }
}
