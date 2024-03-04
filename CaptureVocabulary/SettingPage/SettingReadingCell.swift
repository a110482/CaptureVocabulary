//
//  SettingReadingCell.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/23.
//

import UIKit
import RxSwift
import RxCocoa

class SettingReadingCell: UITableViewCell, SettingPageCellProtocol {
    static let type: SettingPageCellType = .readingSpeed
    
    private weak var cellModel: SettingReadingCellModel?
    private let mainStackView = UIStackView()
    private let titleLabel = UILabel()
    private let playButton = UIButton()
    private let slider = UISlider()
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    func config(cellModel: any SettingPageCellModelProtocol) {
        guard let cellModel = cellModel as? SettingReadingCellModel else {
            return
        }
        self.cellModel = cellModel
        slider.maximumValue = Float(cellModel.maxSpeed)
        slider.minimumValue = Float(cellModel.minSpeed)
        cellModel.speed.drive(onNext: { [weak self] value in
            guard let self else { return }
            slider.value = Float(value)
        }).disposed(by: disposeBag)
    }
}

// UI
private extension SettingReadingCell {
    func configUI() {
        contentView.addSubview(mainStackView)
        configStackView()
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 20),
            titleLabel,
            mainStackView.padding(gap: 30),
            slider,
            mainStackView.padding(gap: 20),
            playButton,
            mainStackView.padding(gap: 20)
        ])
        
        configTitleLabel()
        configPlayButton()
        configSlider()
    }
    
    func configStackView() {
        mainStackView.axis = .horizontal
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(50).priority(999)
        }
    }
    
    func configPlayButton() {
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        playButton.rx.tap.subscribe(onNext: {
            Speaker.shared.speak("testing", language: .en_US)
        }).disposed(by: disposeBag)
        
        playButton.snp.makeConstraints {
            $0.size.equalTo(40)
        }
    }
    
    func configTitleLabel() {
        titleLabel.text = "閱讀速度"
    }
    
    func configSlider() {
        slider.rx.value.skip(1).subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.cellModel?.setReadingSpeed(value: value)
        }).disposed(by: disposeBag)
    }
}

// MARK: - CellModel
class SettingReadingCellModel: SettingPageCellModelProtocol {
    let type: SettingPageCellType = .readingSpeed
    
    let maxSpeed: Float = 1.5
    let minSpeed: Float = 0.5
    private let defaultSpeed: Float = 1
    private var _speed: BehaviorRelay<Float>
    var speed: Driver<Float> { _speed.asDriver() }
    
    
    init() {
        let userDefaultSpeed = UserDefaults.standard[UserDefaultsKeys.readingSpeedRatio] ?? defaultSpeed
        _speed = BehaviorRelay(value: userDefaultSpeed)
    }
    
    func setReadingSpeed(value: Float) {
        UserDefaults.standard[UserDefaultsKeys.readingSpeedRatio] = value
        _speed.accept(value)
        Speaker.shared.updateReadingRatio(ratio: value)
    }
}
