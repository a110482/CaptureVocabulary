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

class VocabularyListCell: UITableViewCell {
    let mainStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20)
    }
    
    let memorizedSwitchButton = UIButton().then {
        $0.setTitle("已記憶".localized(), for: .normal)
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
        backgroundColor = (self.cellModel?.memorized ?? false) ? .gray : .systemBackground
    }
    
    func configUI() {
        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.left.equalTo(5)
        }
        
        mainStack.addArrangedSubviews([
            nameLabel,
            UIView(),
            memorizedSwitchButton
        ])
    }
    
    func bindAction() {
        memorizedSwitchButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            #warning("寫入已記憶")
        }).disposed(by: disposeBag)
    }
}
