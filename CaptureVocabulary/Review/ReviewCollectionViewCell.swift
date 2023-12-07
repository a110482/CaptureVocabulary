//
//  ReviewCollectionViewCell.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/16.
//

import UIKit
import RxSwift
import RxCocoa

protocol ReviewCollectionViewCellDelegate: AnyObject {
    func tapMemorizedSwitchButton(cellModel: VocabularyCardORM.ORM)
    func displayTranslateSwitchDidChanged(isOn: Bool)
}

class ReviewCollectionViewCell: UICollectionViewCell {
    weak var delegate: ReviewCollectionViewCellDelegate?
    var isDisplayTranslateSwitchOn: Bool {
        get { return displayTranslateSwitch.isOn }
        set { displayTranslateSwitch.isOn = newValue }
    }
    private let activeSwitchButton = ActiveSwitchButton()
    private let mainStackView = UIStackView()
    private let speakerButton: UIButton = {
        let config = UIButton.Configuration.speakerButtonConfiguration
        let button = UIButton(configuration: config)
        return button
    }()
    private let sourceLabel = UILabel()
    private let translateLabel = UILabel()
    private let displayTranslateSwitch = UISwitch()
    private let chineseLabel = UILabel()
    private var cellModel: VocabularyCardORM.ORM?
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        bindAction()
        resetToDefaultStatus()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetToDefaultStatus()
    }
    
    func set(cellModel: VocabularyCardORM.ORM) {
        self.cellModel = cellModel
        sourceLabel.text = cellModel.normalizedSource
        translateLabel.text = cellModel.normalizedTarget
        activeSwitchButton.setActive(cellModel.memorized ?? false)
        speakerButton.setTitle(cellModel.phonetic, for: .normal)
    }
    
    private func resetToDefaultStatus() {
        activeSwitchButton.setActive(false)
        sourceLabel.text = "word house"
        translateLabel.text = NSLocalizedString("ReviewCollectionViewCell.addNewWords", comment: "你的單字屋, 快去新增單字吧")
        speakerButton.setTitle("", for: .normal)
    }
}

// UI
private extension ReviewCollectionViewCell {
    func configUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.addSubview(activeSwitchButton)
        configActiveSwitchButton()
        contentView.addSubview(mainStackView)
        configMainStackView()
        contentView.addSubview(displayTranslateSwitch)
        configDisplayTranslateSwitch()
        contentView.addSubview(chineseLabel)
        configChineseLabel()
    }
    
    func configActiveSwitchButton() {
        activeSwitchButton.snp.makeConstraints {
            $0.left.equalTo(24)
            $0.size.equalTo(24)
        }
        // centerY 稍後對齊 sourceLabel
    }
    
    func configMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .leading
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(24)
            $0.left.equalTo(activeSwitchButton.snp.right).offset(8)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-20)
        }

        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 1),
            sourceLabel,
            speakerButton,
            translateLabel,
            mainStackView.padding(gap: 1),
        ])
        
        configSpeakerButton()
        activeSwitchButton.snp.makeConstraints {
            $0.centerY.equalTo(sourceLabel)
        }
    }
    
    func configSpeakerButton() {
        speakerButton.setImage(UIImage(systemName: "speaker.wave.3"), for: .normal)
        speakerButton.snp.makeConstraints {
            $0.height.equalTo(24)
        }
    }
    
    func configDisplayTranslateSwitch() {
        displayTranslateSwitch.onTintColor = UIColor(hexString: "3D5CFF")
        displayTranslateSwitch.snp.makeConstraints {
            $0.centerY.equalTo(activeSwitchButton)
            $0.right.equalToSuperview().offset(-8)
        }
        displayTranslateSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
    
    func configChineseLabel() {
        chineseLabel.text = "中"
        chineseLabel.snp.makeConstraints {
            $0.centerY.equalTo(displayTranslateSwitch)
            $0.right.equalTo(displayTranslateSwitch.snp.left).offset(-8)
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
        guard let cellModel = cellModel else { return }
        delegate?.tapMemorizedSwitchButton(cellModel: cellModel)
        activeSwitchButton.setActive(true)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        delegate?.displayTranslateSwitchDidChanged(isOn: sender.isOn)
    }
}
