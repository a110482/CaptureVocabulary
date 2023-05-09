//
//  VocabularyListCell.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/10.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift
import AVFoundation

protocol VocabularyListCellDelegate: AnyObject {
    func tapMemorizedSwitchButton(cellModel: VocabularyCardListORM.ORM)
}

class VocabularyListCell: UITableViewCell {
    weak var delegate: VocabularyListCellDelegate?
    
    private let mainStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20)
    }
    
    private let memorizedSwitchButton = ActiveSwitchButton().then {
        $0.setTitleColor(UILabel().textColor, for: .normal)
        $0.snp.makeConstraints {
            $0.size.equalTo(44)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private var cellModel: VocabularyCardListORM.ORM?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ cellModel: VocabularyCardListORM.ORM) {
        self.cellModel = cellModel
        nameLabel.text = cellModel.name
        updateUI()
    }
}

// UI
private extension VocabularyListCell {
    func updateUI() {
        selectionStyle = .none
        let memorized = self.cellModel?.memorized ?? false
        memorizedSwitchButton.setActive(memorized)
    }
    
    func configUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(mainStack)
        
        mainStack.backgroundColor = .white
        mainStack.cornerRadius = 10
        mainStack.alignment = .center
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalTo(24)
            $0.top.equalTo(5)
            $0.height.equalTo(60)
        }
        
        mainStack.addArrangedSubviews([
            mainStack.padding(gap: 14),
            memorizedSwitchButton,
            mainStack.padding(gap: 14),
            nameLabel,
            mainStack.padding(gap: 24),
        ])
    }
    
    func bindAction() {
        memorizedSwitchButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            guard let cellModel = self.cellModel else { return }
            self.delegate?.tapMemorizedSwitchButton(cellModel: cellModel)
        }).disposed(by: disposeBag)
    }
}

