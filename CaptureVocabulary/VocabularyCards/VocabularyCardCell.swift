//
//  VocabularyCardCell.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/25.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

class VocabularyCardCell: UITableViewCell {
    private let mainStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
    private let sourceLabel = UILabel().then {
        $0.textAlignment = .center
    }
    private let translateLabel = UILabel().then {
        $0.textAlignment = .center
    }
    private let speakerButton = UIButton().then {
        $0.setImage(UIImage(systemName: "speaker.wave.3"), for: .normal)
    }
    private let memorizedSwitchButton = UIButton().then {
        $0.setTitle("已記憶".localized(), for: .normal)
        $0.setTitleColor(UILabel().textColor, for: .normal)
    }
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func bind(cellModel: VocabularyCardORM.ORM) {
        sourceLabel.text = cellModel.normalizedSource
        translateLabel.text = cellModel.normalizedTarget
    }
}

private extension VocabularyCardCell {
    func configUI() {
        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalTo(10)
            $0.top.equalTo(10)
        }
        
        mainStack.addArrangedSubviews([
            sourceLabel,
            translateLabel,
            speakerButton,
            memorizedSwitchButton
        ])
        
        speakerButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        memorizedSwitchButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }
    
    func bindAction() {
        speakerButton.rx.tap.subscribe(onNext: { [weak self] _ in
            Speaker.speak(self?.sourceLabel.text ?? "", language: .en_US)
        }).disposed(by: disposeBag)
    }
}
