//
//  StoryGeneratorViewController.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import UIKit
import RxSwift
import RxCocoa

class StoryGeneratorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    private var viewModel: StoryGeneratorViewModel!
    private let mainStackView = UIStackView()
    private let titleLabel = UILabel()
    private let stepOneLabel = UILabel()
    private let segmentView = SegmentedView()
    private let stepTwoLabel = UILabel()
    private let vocabularyAmountSliderLabel = UILabel()
    private let vocabularyAmountSlider = UISlider()
}

extension StoryGeneratorViewController {
    func bind(viewModel: StoryGeneratorViewModel) {
        self.viewModel = viewModel
    }
}

private extension StoryGeneratorViewController {
    func configUI() {
        configMainStackView()
        configTitleLabel()
        configStepOneLabel()
        configSegmentView()
        configStepTwoLabel()
        configVocabularyAmountSlider()
        
#if DEBUG
        view.backgroundColor = .lightGray
        mainStackView.addArrangedSubview(UIView())
        segmentView.backgroundColor = .brown
#endif
    }
    
    func configMainStackView() {
        mainStackView.axis = .vertical
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
    }
    
    func configTitleLabel() {
        mainStackView.addArrangedSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        titleLabel.text = NSLocalizedString("StoryGeneratorViewController.title", comment: "故事產生器")
    }
    
    func configStepOneLabel() {
        mainStackView.addArrangedSubview(mainStackView.padding(gap: 20))
        mainStackView.addArrangedSubview(stepOneLabel)
        stepOneLabel.textAlignment = .left
        stepOneLabel.text = NSLocalizedString("StoryGeneratorViewController.stepOne", comment: "第一步")
    }
    
    func configSegmentView() {
        mainStackView.addArrangedSubview(mainStackView.padding(gap: 10))
        mainStackView.addArrangedSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        segmentView.delegate = self
        segmentView.dataSource = self
//        segmentView.configuration
    }
    
    func configStepTwoLabel() {
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 20),
            stepTwoLabel
        ])
        stepTwoLabel.textAlignment = .left
        stepTwoLabel.text = NSLocalizedString("StoryGeneratorViewController.stepTwo", comment: "")
    }
    
    func configVocabularyAmountSlider() {
        let sliderContainer = UIStackView()
        sliderContainer.axis = .horizontal
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 10),
            sliderContainer
        ])
        
        sliderContainer.addArrangedSubviews([
            vocabularyAmountSliderLabel,
            sliderContainer.padding(gap: 10),
            vocabularyAmountSlider,
        ])
        vocabularyAmountSlider.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        vocabularyAmountSlider.minimumValue = viewModel.vocabularyAmountRange.lowerBound
        vocabularyAmountSlider.maximumValue = viewModel.vocabularyAmountRange.upperBound
        vocabularyAmountSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        updateSliderUI()
    }
    
    func updateSliderUI() {
        vocabularyAmountSliderLabel.text = "\(Int(viewModel.output.vocabularyAmount))"
        vocabularyAmountSlider.value = viewModel.output.vocabularyAmount
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        guard let viewModel else { return }
        let step: Float = 1.0
        // 計算出接近的步長值
        let roundedValue = round(sender.value / step) * step
        // 設置滑塊值為調整過後的值
        
        guard vocabularyAmountSlider.value != roundedValue else { return }
        vocabularyAmountSlider.value = roundedValue
        viewModel.set(vocabularyAmount: Int(roundedValue))
        updateSliderUI()
    }
}

extension StoryGeneratorViewController: SegmentedViewDelegate {
    func segmentedView(_ view: SegmentedView, didSelectOptionAt index: Int) {
        let model = viewModel.output.storyStyleOptions[index]
        viewModel.setSelected(option: model)
        view.reloadData()
    }
}

extension StoryGeneratorViewController: SegmentedViewDataSource {
    func segmentedView(_ view: SegmentedView, titleForOptionAt index: Int) -> SegmentedOptionView {
        let option = StoryGeneratorOptionView()
        option.backgroundColor = .yellow
        let model = viewModel.output.storyStyleOptions[index]
        option.config(title: model.key, isSelected: model.isSelected)
        return option
    }
    
    func numberOfOptions(in view: SegmentedView) -> Int {
        return viewModel.output.storyStyleOptions.count
    }
}
