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

protocol VocabularyCardCellDelegate: AnyObject {
    func tapMemorizedSwitchButton(cellModel: VocabularyCardORM.ORM)
}

class VocabularyCardCell: UITableViewCell {
    weak var delegate: VocabularyCardCellDelegate?
    
    private let mainStack = UIStackView()
    
    private let firstLineStack = UIStackView()
    
    private let sourceLabel = UILabel().then {
        $0.textAlignment = .left
    }
    
    private let memorizedSwitchButton = ActiveSwitchButton()
    
    private let secondLineStack = UIStackView()
    
    private let translateLabel = UILabel().then {
        $0.textAlignment = .left
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private let speakerButton = UIButton()
    
    private var cellModel: VocabularyCardORM.ORM?
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [sourceLabel, translateLabel].forEach {
            $0.text = ""
        }
        memorizedSwitchButton.setActive(false)
    }
    
    func bind(cellModel: VocabularyCardORM.ORM) {
        self.cellModel = cellModel
        sourceLabel.text = cellModel.normalizedSource
        translateLabel.text = cellModel.normalizedTarget
        let memorized = cellModel.memorized ?? false
        memorizedSwitchButton.setActive(memorized)
    }
    
    private func bindAction() {
        speakerButton.rx.tap.subscribe(onNext: { [weak self] _ in
            Speaker.shared.speak(self?.sourceLabel.text ?? "", language: .en_US)
        }).disposed(by: disposeBag)
        
        memorizedSwitchButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            guard let cellModel = self.cellModel else { return }
            self.delegate?.tapMemorizedSwitchButton(cellModel: cellModel)
        }).disposed(by: disposeBag)
    }
}

// UI
private extension VocabularyCardCell {
    func configUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(mainStack)
        configMainStackView()
        
        mainStack.addArrangedSubviews([
            mainStack.padding(gap: 5),
            firstLineStack,
            secondLineStack,
            mainStack.padding(gap: 5),
        ])
        mainStack.addSubview(speakerButton)
        
        configFirstLineStackView()
        configSecondLineStackView()
        configSpeakerButton()
        configMemorizedSwitchButton()
    }
    
    func configMainStackView() {
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.backgroundColor = .white
        mainStack.layer.cornerRadius = 10
        mainStack.layer.masksToBounds = true
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalTo(24)
            $0.top.equalTo(5)
        }
    }
    
    func configFirstLineStackView() {
        firstLineStack.axis = .horizontal
        firstLineStack.addArrangedSubviews([
            firstLineStack.padding(gap: 20),
            memorizedSwitchButton,
            firstLineStack.padding(gap: 13),
            sourceLabel,
            firstLineStack.padding(gap: 20),
        ])
    }
    
    func configSecondLineStackView() {
        secondLineStack.axis = .horizontal
        secondLineStack.addArrangedSubviews([
            firstLineStack.padding(gap: 20),
            translateLabel
        ])
    }
    
    func configSpeakerButton() {
        speakerButton.setImage(UIImage(systemName: "speaker.wave.3"), for: .normal)
        speakerButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.right.equalTo(-24)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configMemorizedSwitchButton() {
        memorizedSwitchButton.snp.makeConstraints {
            $0.size.equalTo(25)
        }
    }
}
