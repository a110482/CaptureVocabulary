//
//  ReviewCollectionViewCell.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/16.
//

import UIKit
import RxSwift
import RxCocoa

// ActiveSwitchButton
class ReviewCollectionViewCell: UICollectionViewCell {
    private let activeSwitchButton = ActiveSwitchButton()
    private let mainStackView = UIStackView()
    private let pronunciationStackView = UIStackView()
    private let speakerButton = UIButton()
    private var cellModel: VocabularyCardORM.ORM?
    private let disposeBag = DisposeBag()
    
    
    // 暫時開放, 等ＵＩ設計完成再封裝
    let sourceLabel = UILabel()
    let translateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        bindAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [sourceLabel, translateLabel].forEach { $0.text = " " }
    }
    
    func set(cellModel: VocabularyCardORM.ORM) {
        self.cellModel = cellModel
        sourceLabel.text = cellModel.normalizedSource
        Task {
            translateLabel.text = await cellModel.normalizedTarget?.localized()
        }
        activeSwitchButton.setActive(cellModel.memorized ?? false)
    }
}

// UI
private extension ReviewCollectionViewCell {
    func configUI() {
        contentView.backgroundColor = .white
        contentView.cornerRadius = 12
        contentView.addSubview(activeSwitchButton)
        configActiveSwitchButton()
        contentView.addSubview(mainStackView)
        configMainStackView()
    }
    
    func configActiveSwitchButton() {
        activeSwitchButton.snp.makeConstraints {
            $0.top.left.equalTo(24)
            $0.size.equalTo(24)
        }
    }
    
    func configMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 9
        mainStackView.alignment = .leading
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(activeSwitchButton)
            $0.left.equalTo(activeSwitchButton.snp.right).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-20)
        }

        mainStackView.addArrangedSubviews([
            sourceLabel,
            pronunciationStackView,
            translateLabel,
            UIView()
        ])
        configPronunciationStackView()
    }
    
    func configPronunciationStackView() {
        pronunciationStackView.axis = .horizontal
        pronunciationStackView.addArrangedSubviews([
            UIView(),
            speakerButton,
        ])
        pronunciationStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        configSpeakerButton()
    }
    
    func configSpeakerButton() {
        speakerButton.setImage(UIImage(systemName: "speaker.wave.3"), for: .normal)
        speakerButton.snp.makeConstraints {
            $0.height.equalTo(24)
        }
    }
}

// action
private extension ReviewCollectionViewCell {
    func bindAction() {
        speakerButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.tapSpeakerButton()
        }).disposed(by: disposeBag)
        
        activeSwitchButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.tapActiveSwitchButton()
        }).disposed(by: disposeBag)
    }
    
    func tapSpeakerButton() {
        guard let source = cellModel?.normalizedSource else { return }
        Speaker.speak(source, language: .en_US)
    }
    
    func tapActiveSwitchButton() {
        guard var cellModel = cellModel else { return }
        cellModel.memorized = true
        cellModel.update()
        activeSwitchButton.setActive(true)
    }
}
