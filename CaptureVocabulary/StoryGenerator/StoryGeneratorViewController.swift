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
    private let vocabularyAmountSliderLabel = UILabel()
    private let vocabularyAmountSlider = UISlider()
    private let stepTwoLabel = UILabel()
    private let tableView = UITableView()
    private let confirmButton = UIButton()
    private let displayModeButton = UIButton()
    
    private var currentDisplayMode: DisplayMode = .normal
    private let disposeBag = DisposeBag()
}

extension StoryGeneratorViewController {
    enum DisplayMode {
        case normal
        case selectVocabulary
        
        @discardableResult
        mutating func toggle() -> DisplayMode {
            switch self {
            case .normal:
                self = .selectVocabulary
                return self
            case .selectVocabulary:
                self = .normal
                return self
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .normal:
                return UIImage(named: "arrow.down.backward.and.arrow.up.forward")
            case .selectVocabulary:
                return UIImage(named: "arrow.down.right.and.arrow.up.left")
            }
        }
    }
    
    func bind(viewModel: StoryGeneratorViewModel) {
        self.viewModel = viewModel
    }
}

private extension StoryGeneratorViewController {
    func configUI() {
        configConfirmButton()
        configMainStackView()
        configTitleLabel()
        configStepOneLabel()
        configVocabularyAmountSlider()
        configStepTwoLabel()
        configTableView()
        configDisplayModeButton()
        
#if DEBUG
        view.backgroundColor = .lightGray
        stepOneLabel.text! += ": 選擇隨機產生的單字上限"
        stepTwoLabel.text! += ": 選擇單字來源"
#endif
    }
    
    func configConfirmButton() {
        view.addSubview(confirmButton)
        confirmButton.backgroundColor = .darkGray
        confirmButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
        }
        confirmButton.setTitle(NSLocalizedString("StoryGeneratorViewController.generatorStory", comment: "產生故事"),
                               for: .normal)
        confirmButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            viewModel.pressStoryGenerateButton(from: self)
        }).disposed(by: disposeBag)
    }
    
    func configMainStackView() {
        mainStackView.axis = .vertical
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.bottom.equalTo(confirmButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
    }
    
    func configTitleLabel() {
        mainStackView.addArrangedSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        titleLabel.text = NSLocalizedString("StoryGeneratorViewController.title", comment: "故事產生器")
    }
    
    func configStepOneLabel() {
        mainStackView.addArrangedSubview(mainStackView.padding(gap: 20))
        mainStackView.addArrangedSubview(stepOneLabel)
        stepOneLabel.textAlignment = .left
        stepOneLabel.text = NSLocalizedString("StoryGeneratorViewController.stepOne", comment: "第一步")
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
    
    func configStepTwoLabel() {
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 20),
            stepTwoLabel
        ])
        stepTwoLabel.textAlignment = .left
        stepTwoLabel.text = NSLocalizedString("StoryGeneratorViewController.stepTwo", comment: "第二步")
    }
    
    func configTableView() {
        mainStackView.addArrangedSubviews([
            mainStackView.padding(gap: 10),
            tableView
        ])
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.register(StoryGeneratorListSettingCell.self, forCellReuseIdentifier: "StoryGeneratorListSettingCell")
    }
    
    func configDisplayModeButton() {
        let size: CGFloat = 40
        view.addSubview(displayModeButton)
        displayModeButton.backgroundColor = .darkGray
        displayModeButton.snp.makeConstraints { make in
            make.size.equalTo(size)
            make.right.equalTo(tableView).offset(-10)
            make.bottom.equalTo(tableView).offset(-10)
        }
        displayModeButton.layer.cornerRadius = size / 2
        displayModeButton.setImage(currentDisplayMode.icon, for: .normal)
        
        displayModeButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else { return }
            currentDisplayMode.toggle()
            updateDisplayMode()
        }).disposed(by: disposeBag)
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
    
    func updateDisplayMode() {
        displayModeButton.setImage(currentDisplayMode.icon, for: .normal)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self else { return }
            switch currentDisplayMode {
            case .normal:
                mainStackView.arrangedSubviews.forEach({
                    $0.isHidden = false
                    $0.alpha = 1
                })
            case .selectVocabulary:
                mainStackView.arrangedSubviews.forEach({
                    $0.alpha = $0 != self.tableView ? 0 : 1
                    $0.isHidden = $0 != self.tableView
                })
            }
        })
    }
}

// MARK: - delegate & datasource
extension StoryGeneratorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.output.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoryGeneratorListSettingCell")
                as? StoryGeneratorListSettingCell else {
            return UITableViewCell()
        }
        let cellModel = viewModel.output.cellModels[indexPath.row]
        cell.config(cellModel: cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = viewModel.output.cellModels[indexPath.row]
        viewModel.toggle(cellModel: cellModel)
        tableView.reloadData()
    }
}
