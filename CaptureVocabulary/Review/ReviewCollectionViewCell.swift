//
//  ReviewCollectionViewCell.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/16.
//

import UIKit

// ActiveSwitchButton
class ReviewCollectionViewCell: UICollectionViewCell {
    private let activeSwitchButton = ActiveSwitchButton()
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }
    
    // 暫時開放, 等ＵＩ設計完成再封裝
    let sourceLabel = UILabel()
    let translateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [sourceLabel, translateLabel].forEach { $0.text = " " }
    }
    
    func set(cellModel: VocabularyCardORM.ORM) {
        sourceLabel.text = cellModel.normalizedSource
        Task {
            translateLabel.text = await cellModel.normalizedTarget?.localized()
        }
    }
    
    private func configUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(mainStackView)
        contentView.cornerRadius = 12
        mainStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.left.greaterThanOrEqualTo(24)
        }
        let padding = mainStackView.padding(gap: 1).then {
            $0.backgroundColor = .gray
        }
        
        mainStackView.addArrangedSubviews([
            sourceLabel,
            padding,
            translateLabel
        ])
        
        padding.snp.makeConstraints {
            $0.width.equalTo(contentView).multipliedBy(0.8)
        }
    }
}
