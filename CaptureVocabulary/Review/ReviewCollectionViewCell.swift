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
    func tapMemorizedSwitchButton(orm: VocabularyCardORM.ORM)
    func hiddenTranslateSwitchDidChanged(isOn: Bool)
    func didPressedTipIcon()
    func didPressedAudioPlayButton()
}

class ReviewCollectionViewCell: UICollectionViewCell {
    weak var delegate: ReviewCollectionViewCellDelegate?
    private var isHiddenTranslateSwitchOn: Bool {
        get { return displayTranslateSwitch.isOn }
        set {
            displayTranslateSwitch.isOn = newValue
        }
    }
    private let activeSwitchButton = ActiveSwitchButton()
    private let mainStackView = UIStackView()
    private let speakerButton: UIButton = {
        let config = UIButton.Configuration.speakerButtonConfiguration
        let button = UIButton(configuration: config)
        return button
    }()
    private let sourceLabel = UILabel()
    private let translateButton = UIButton()
    private let displayTranslateSwitch = UISwitch()
    private let chineseLabel = UILabel()
    private let audioPlayButton = UIButton()
    private var cellModel: ReviewCollectionViewCellModel?
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
    
    func set(cellModel: ReviewCollectionViewCellModel) {
        self.cellModel = cellModel
        self.isHiddenTranslateSwitchOn = cellModel.isHiddenTranslateSwitchOn
        sourceLabel.text = cellModel.orm.normalizedSource
        activeSwitchButton.setActive(cellModel.orm.memorized ?? false)
        speakerButton.setTitle(cellModel.orm.phonetic, for: .normal)
        updateAudioButtonIcon()
        speakerButton.isHidden = false
        audioPlayButton.isHidden = false
        
        if isHiddenTranslateSwitchOn {
            cellModel.orm.normalizedSource == cellModel.pressTipVocabulary ? showTranslate() : hideTranslate()
        } else {
            showTranslate()
        }
    }
    
    private func resetToDefaultStatus() {
        activeSwitchButton.setActive(false)
        sourceLabel.text = "word house"
        let translateButtonTitle = NSLocalizedString("ReviewCollectionViewCell.addNewWords", comment: "你的單字屋, 快去新增單字吧")
        translateButton.setTitle(translateButtonTitle, for: .normal)
        speakerButton.setTitle("", for: .normal)
        speakerButton.isHidden = true
        audioPlayButton.isHidden = true
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
        contentView.addSubview(audioPlayButton)
        configAudioPlayButton()
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
            translateButton,
            mainStackView.padding(gap: 1),
        ])
        
        configSpeakerButton()
        activeSwitchButton.snp.makeConstraints {
            $0.centerY.equalTo(sourceLabel)
        }
        translateButton.setTitleColor(.black, for: .normal)
        translateButton.titleLabel?.numberOfLines = 2
        translateButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.width.greaterThanOrEqualTo(60)
        }
        translateButton.addTarget(self, action: #selector(didPressedTipIcon), for: .touchUpInside)
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
    
    func configAudioPlayButton() {
        updateAudioButtonIcon()
        
        audioPlayButton.snp.makeConstraints {
            $0.size.equalTo(50)
            $0.left.equalTo(displayTranslateSwitch)
            $0.bottom.equalTo(mainStackView)
        }
        
        audioPlayButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.delegate?.didPressedAudioPlayButton()
        }).disposed(by: disposeBag)
    }
    
    func configChineseLabel() {
        chineseLabel.text = "中"
        chineseLabel.snp.makeConstraints {
            $0.centerY.equalTo(displayTranslateSwitch)
            $0.right.equalTo(displayTranslateSwitch.snp.left).offset(-8)
        }
    }
    
    func updateAudioButtonIcon() {
        var config = UIButton.Configuration.plain()
        let isAudioModeOn = cellModel?.isAudioModeOn ?? false
        let imageName = isAudioModeOn ? "stop.circle" : "play.circle"
        config.image = UIImage(systemName: imageName)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 25))
        audioPlayButton.configuration = config
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
        guard let source = cellModel?.orm.normalizedSource else { return }
        Speaker.shared.speak(source, language: .en_US)
    }
    
    func tapActiveSwitchButton() {
        guard let cellModel = cellModel else { return }
        delegate?.tapMemorizedSwitchButton(orm: cellModel.orm)
        activeSwitchButton.setActive(true)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        delegate?.hiddenTranslateSwitchDidChanged(isOn: sender.isOn)
    }
}

// 控制隱藏或顯示模式 (複習模式)
private extension ReviewCollectionViewCell {
    private func hideTranslate() {
        translateButton.setTitle(" ", for: .normal)
        translateButton.setImage(UIImage(systemName: "lightbulb.fill"), for: .normal)
    }
    
    private func showTranslate() {
        translateButton.setImage(nil, for: .normal)
        translateButton.setTitle(cellModel!.orm.normalizedTarget, for: .normal)
        translateButton.setTitleColor(UIColor.label, for: .normal)
    }
    
    @objc func didPressedTipIcon() {
        delegate?.didPressedTipIcon()
    }
}
