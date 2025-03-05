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
        title = NSLocalizedString("StoryGeneratorViewController.title", comment: "故事產生器")
        configBackButton()
        configUI()
    }
    
    private var viewModel: StoryGeneratorViewModel!
    private let mainStackView = UIStackView()
    private let stepOneLabel = UILabel()
    private let vocabularyAmountSliderLabel = UILabel()
    private let vocabularyAmountSlider = UISlider()
    private let stepTwoLabel = UILabel()
    private let tableView = UITableView()
    private let confirmButton = UIButton()
    
    private let disposeBag = DisposeBag()
}

extension StoryGeneratorViewController {
    enum ConfirmButtonStatus {
        case generatorStory
        case watchAd
        
        var title: String {
            switch self {
            case .generatorStory:
                return NSLocalizedString("StoryGeneratorViewController.generatorStory", comment: "產生故事")
            case .watchAd:
                return NSLocalizedString("StoryGeneratorViewController.watchAD", comment: "觀看廣告產生故事")
            }
        }
    }
    
    var confirmButtonStatus: ConfirmButtonStatus {
        AdsManager.shared.output.isPresentInterstitialAdValue ? .generatorStory : .watchAd
    }
    
    func bind(viewModel: StoryGeneratorViewModel) {
        self.viewModel = viewModel
        handle(viewModelResponse: viewModel.output.apiResponse)
    }
}

private extension StoryGeneratorViewController {
    func configUI() {
        view.backgroundColor = "F8F7F7".color
        configConfirmButton()
        configMainStackView()
        configStepOneLabel()
        configVocabularyAmountSlider()
        configStepTwoLabel()
        configTableView()
        confitTableHeaderView()
        
#if DEBUG
        stepOneLabel.text! += ": 選擇隨機產生的單字上限"
        stepTwoLabel.text! += ": 選擇單字來源"
#endif
    }
    
    func configBackButton() {
        let image = UIImage(named: "arrowLeft")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(tapBackButton))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func tapBackButton() {
        viewModel.tapBackButton()
    }
    
    func configConfirmButton() {
        view.addSubview(confirmButton)
        confirmButton.backgroundColor = .darkGray
        confirmButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
        }
        confirmButton.setTitle(confirmButtonStatus.title,
                               for: .normal)
        confirmButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            startLoadingAnimate()
            viewModel.pressStoryGenerateButton()
        }).disposed(by: disposeBag)
    }
    
    func configMainStackView() {
        mainStackView.axis = .vertical
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
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.bottom.equalTo(confirmButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.register(StoryGeneratorListSettingCell.self, forCellReuseIdentifier: "StoryGeneratorListSettingCell")
    }
    
    func confitTableHeaderView() {
        let headerViewHeight = mainStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let headerViewContainer = UIView()
        headerViewContainer.frame = CGRect(origin: .zero,
                                     size: CGSize(width: 0, height: headerViewHeight))
        headerViewContainer.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(8)
            make.centerX.equalToSuperview()
        }
        tableView.tableHeaderView = headerViewContainer
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
    
    func handle(viewModelResponse: Observable<StoryGeneratorViewModel.Response>) {
        viewModelResponse.subscribe(onNext: { [weak self] action in
            guard let self else { return }
            stopLoadingAnimate()
        }).disposed(by: disposeBag)
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
