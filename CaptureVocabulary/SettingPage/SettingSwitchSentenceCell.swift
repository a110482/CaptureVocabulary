//
//  SettingSwitchSentenceCell.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/10/4.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SettingSwitchSentenceCell: UITableViewCell, SettingPageCellProtocol {
    static let type: SettingPageCellType = .readingSimpleSentenceOption
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func config(cellModel: any SettingPageCellModelProtocol) {
        guard let cellModel = cellModel as? SettingSwitchSentenceCellModel else { return }
        resettableDisposeBag = DisposeBag()
        self.cellModel = cellModel
        slider.minimumValue = Float(cellModel.numberOfReadSentencesRange.lowerBound)
        slider.maximumValue = Float(cellModel.numberOfReadSentencesRange.upperBound)
        
        bindSliderLabel(cellModel)
        setSlider(cellModel)
        bind(isNeedReadSentences: cellModel.output.isNeedReadSentences)
    }
    
    private var cellModel: SettingSwitchSentenceCellModel?
    private let mainStackView = UIStackView()
    private let switchStackView = UIStackView()
    private let titleLabel = UILabel()
    private let sentenceSwitch = UISwitch()
    /// 設定要念多少例句
    private let numberStackView = UIStackView()
    private let numberOfReadSentencesTitleLabel = UILabel()
    private let numberOfReadSentencesLabel = UILabel()
    private let slider = UISlider()
    private var resettableDisposeBag = DisposeBag()
}

private extension SettingSwitchSentenceCell {
    func configUI() {
        selectionStyle = .none
        contentView.addSubview(mainStackView)
        configMainStackView()
        configSwitchStackView()
        configNumberStackView()
    }
    
    func configMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 10),
            switchStackView,
            numberStackView,
            mainStackView.padding(gap: 10),
        ])
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().priority(999)
        }
    }
    
    func configSwitchStackView() {
        switchStackView.axis = .horizontal
        switchStackView.addArrangedSubviews([
            switchStackView.padding(gap: cellLeftPadding),
            titleLabel,
            UIView(),
            sentenceSwitch,
            switchStackView.padding(gap: cellRightPadding),
        ])
        
        configTitleLabel()
        configSentenceSwitch()
    }
    
    func configTitleLabel() {
        titleLabel.text = NSLocalizedString("SettingSwitchSentenceCell.titleLabel", comment: "閱讀例句")
    }
    
    func configSentenceSwitch() {
        sentenceSwitch.addTarget(self,
                                 action: #selector(switchToggle(_:)),
                                 for: .valueChanged)
    }
    
    @objc func switchToggle(_ sender: UISwitch) {
        guard let cellModel else { return }
        cellModel.set(isNeedReadSentences: sender.isOn)
    }
    
    func configNumberStackView() {
        numberStackView.axis = .horizontal
        
        numberStackView.addArrangedSubviews([
            numberStackView.padding(gap: cellLeftPadding),
            numberOfReadSentencesTitleLabel,
            numberOfReadSentencesLabel,
            numberStackView.padding(gap: 20),
            slider,
            numberStackView.padding(gap: cellRightPadding),
        ])
        
        configNumberOfReadSentencesTitleLabel()
        configNumberOfReadSentencesLabelLabel()
        configSlider()
    }
    
    func configNumberOfReadSentencesTitleLabel() {
        numberOfReadSentencesTitleLabel.text = NSLocalizedString("SettingSwitchSentenceCell.numberOfReadSentencesTitleLabel", comment: "閱讀次數") + ": "
    }
    
    func configNumberOfReadSentencesLabelLabel() {
        numberOfReadSentencesLabel.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
    }
    
    func configSlider() {
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let cellModel else { return }
        let step: Float = 1.0
        // 計算出接近的步長值
        let roundedValue = round(sender.value / step) * step
        // 設置滑塊值為調整過後的值
        if slider.value != roundedValue {
            slider.value = roundedValue
            cellModel.set(numberOfReadSentences: Int(roundedValue))
        }
    }
    
    func bind(isNeedReadSentences: Observable<Bool>) {
        isNeedReadSentences
            .bind(to: sentenceSwitch.rx.isOn)
            .disposed(by: resettableDisposeBag)
    }
    
    func bindSliderLabel(_ cellModel: SettingSwitchSentenceCellModel) {
        cellModel.output
            .numberOfReadSentences.map({
                String($0)
            }).bind(to: numberOfReadSentencesLabel.rx.text)
            .disposed(by: resettableDisposeBag)
    }
    
    func setSlider(_ cellModel: SettingSwitchSentenceCellModel) {
        slider.value = Float(cellModel.output.numberOfReadSentencesCurrentValue)
    }
}

// MARK: - CellModel
class SettingSwitchSentenceCellModel: SettingPageCellModelProtocol {
    let type: SettingPageCellType = .readingSimpleSentenceOption
    private(set) lazy var output = Output(self)
    /// 限制唸幾句例句
    let numberOfReadSentencesRange = 1...3

    init() {
        let isNeedReadSentencesValue = UserDefaults
            .standard[UserDefaultsKeys.isNeedReadSentences] ?? true
        isNeedReadSentences = BehaviorRelay(value: isNeedReadSentencesValue)
        let numberOfReadSentencesValue = UserDefaults
            .standard[UserDefaultsKeys.numberOfReadSentences] ?? 1
        numberOfReadSentences = BehaviorRelay(value: numberOfReadSentencesValue)
    }
    
    func set(isNeedReadSentences: Bool) {
        self.isNeedReadSentences.accept(isNeedReadSentences)
        UserDefaults
            .standard[UserDefaultsKeys.isNeedReadSentences] = isNeedReadSentences
    }
    
    func set(numberOfReadSentences: Int) {
        @LimitedInt(range: numberOfReadSentencesRange)
        var limitInt = Int(numberOfReadSentences)
        
        self.numberOfReadSentences.accept(limitInt)
        UserDefaults
            .standard[UserDefaultsKeys.numberOfReadSentences] = numberOfReadSentences
    }
    
    /// 語音模式是否閱讀例句
    private let isNeedReadSentences: BehaviorRelay<Bool>
    /// 語音模式閱讀例句的數量
    private let numberOfReadSentences: BehaviorRelay<Int>
}

extension SettingSwitchSentenceCellModel {
    class Output: RxOutput<SettingSwitchSentenceCellModel> {
        var isNeedReadSentences: Observable<Bool> {
            target.isNeedReadSentences.asObservable()
        }
        var numberOfReadSentences: Observable<Int> {
            target.numberOfReadSentences.asObservable()
        }
        var numberOfReadSentencesCurrentValue: Int {
            target.numberOfReadSentences.value
        }
    }
}
