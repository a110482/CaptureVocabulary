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
    private let stepOneLabel = UIInsetLabel()
    private let vocabularyAmountSliderLabel = UILabel()
    private let vocabularyAmountSlider = UISlider()
    private let stepTwoLabel = UIInsetLabel()
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
        handle(vocabularyAmountNotEnough: viewModel.output.vocabularyAmountNotEnough)
    }
}

private extension StoryGeneratorViewController {
    func configUI() {
        view.backgroundColor = "F8F7F7".uicolor
        configConfirmButton()
        configMainStackView()
        configStepOneLabel()
        configVocabularyAmountSlider()
        configStepTwoLabel()
        configTableView()
        confitTableHeaderView()
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
        confirmButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.7)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        confirmButton.setTitle(confirmButtonStatus.title,
                               for: .normal)
        confirmButton.applyConfirmStyle()
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
        mainStackView.addArrangedSubview(stepOneLabel)
        stepOneLabel.text = NSLocalizedString("StoryGeneratorViewController.stepOne", comment: "第一步")
        stepOneLabel.applyStepLabelStyle()
        stepOneLabel.numberOfLines = 2
    }
    
    func configVocabularyAmountSlider() {
        let sliderContainer = UIStackView()
        sliderContainer.axis = .horizontal
        mainStackView.addArrangedSubviews([
            sliderContainer
        ])
        
        sliderContainer.addArrangedSubviews([
            sliderContainer.padding(gap: 20),
            vocabularyAmountSliderLabel,
            sliderContainer.padding(gap: 10),
            vocabularyAmountSlider,
            sliderContainer.padding(gap: 20),
        ])
        vocabularyAmountSlider.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        vocabularyAmountSlider.minimumValue = viewModel.vocabularyAmountRange.lowerBound
        vocabularyAmountSlider.maximumValue = viewModel.vocabularyAmountRange.upperBound
        vocabularyAmountSlider.minimumTrackTintColor = "667080".uicolor
        vocabularyAmountSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        updateSliderUI()
    }
    
    func configStepTwoLabel() {
        mainStackView.addArrangedSubview(stepTwoLabel)
        stepTwoLabel.text = NSLocalizedString("StoryGeneratorViewController.stepTwo", comment: "第二步")
        stepTwoLabel.applyStepLabelStyle()
    }
    
    func configTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.bottom.equalTo(confirmButton.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview()
        }
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.separatorColor = "555555".uicolor
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
            make.left.equalToSuperview()
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
    
    /// api 回應
    func handle(viewModelResponse: Observable<StoryGeneratorViewModel.Response>) {
        viewModelResponse.subscribe(onNext: { [weak self] action in
            guard let self else { return }
            stopLoadingAnimate()
        }).disposed(by: disposeBag)
    }
    
    /// 單字數量不足
    func handle(vocabularyAmountNotEnough: Observable<Void>) {
        vocabularyAmountNotEnough.subscribe(onNext: { [weak self] in
            guard let self else { return }
            stopLoadingAnimate()
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            let text = NSLocalizedString("StoryGeneratorViewController.VocabularyAmountNotEnough", comment: "單字量不足以產生文章")
            alertVC.title = text
            let ok = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"),
                                   style: .default)
            alertVC.addAction(ok)
            present(alertVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - 設定元件共用樣式
private extension UIInsetLabel {
    func applyStepLabelStyle() {
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(40)
        }
        textAlignment = .left
        numberOfLines = 2
        backgroundColor = "C4C9D3".uicolor
        textInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        textColor = "667080".uicolor
        font = .systemFont(ofSize: 13, weight: .medium)
    }
}
