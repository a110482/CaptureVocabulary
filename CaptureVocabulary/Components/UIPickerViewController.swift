//
//  UIPickerViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/7.
//

import UIKit
import SnapKit
import RxSwift

protocol UIPickerViewModelProtocol {
    var title: String { get }
}
extension String: UIPickerViewModelProtocol {
    var title: String { self }
}

class UIPickerViewController<M: UIPickerViewModelProtocol>: UIViewController,
                                                          UIPickerViewDelegate,
                                                          UIPickerViewDataSource {

    /// - Parameters:
    ///   - title: 先保留參數, 有用到再實作
    ///   - message: 先保留參數, 有用到再實作
    init(title: String? = nil, message: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareAnimate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimate()
    }
    
    private let mainStack = UIStackView().then {
        $0.spacing = 5
        $0.axis = .vertical
    }
    private let pickerView = UIPickerView()
    private let okButton = UIButton().then {
        $0.setTitle(NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"), for: .normal)
        $0.setTitleColor(UILabel().textColor, for: .normal)
        $0.backgroundColor = .systemBackground
    }
    private let disposeBag = DisposeBag()
    private var models: [[M]] = []
    private(set) var currentSelectedModel: M?
    
    // interface
    func setModels (models: [[M]]) {
        self.models = models
        pickerView.reloadAllComponents()
        selectFirstItem()
    }
    
    var selected: ((_ model: M) -> Void)?
    
    private func selectFirstItem() {
        guard models.flatMap({ $0 }).count > 0 else { return }
        guard let notNilComponentIndex = models.firstIndex(where: { $0.count > 0 }) else { return }
        pickerView.selectRow(0, inComponent: Int(notNilComponentIndex), animated: false)
        currentSelectedModel = models.flatMap({ $0 }).first
    }
    
    // delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        models.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        models[component].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return models[component][row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSelectedModel = models[safe: component]?[safe: row]
    }
}

// UI
extension UIPickerViewController {
    func configUI() {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = .black.withAlphaComponent(0.3)
        
        view.addSubview(mainStack)
        mainStack.layer.cornerRadius = 10
        mainStack.layer.masksToBounds = true
        view.shadowColor = .black
        view.shadowOffset = CGSize(width: 0, height: -10)
        view.shadowRadius = 20
        view.shadowOpacity = 0.3
        
        mainStack.addArrangedSubviews([
            pickerView,
            okButton
        ])
        pickerView.snp.makeConstraints {
            $0.height.equalTo(150)
        }
        okButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .systemBackground
        prepareAnimate()
    }
    
    func prepareAnimate() {
        let offsetY = mainStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        mainStack.snp.remakeConstraints {
            $0.bottom.equalToSuperview().offset(offsetY)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(5)
        }
    }
    
    func showAnimate() {
        mainStack.snp.updateConstraints {
            $0.bottom.equalToSuperview().offset(-25)
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// Action
extension UIPickerViewController {
    func bindAction() {
        backgroundAction()
        okButtonAction()
    }
    
    func backgroundAction() {
        let ges = UITapGestureRecognizer()
        view.addGestureRecognizer(ges)
        ges.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func okButtonAction() {
        okButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
            guard let model = self.currentSelectedModel else { return }
            self.selected?(model)
        }).disposed(by: disposeBag)
    }
}
