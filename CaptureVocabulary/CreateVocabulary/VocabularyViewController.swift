//
//  VocabularyView.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import SwifterSwift

// MARK: - View
class VocabularyViewController: UIViewController {
    enum Action {
        case dismiss
        case dismissWithAnimate
    }
    let action = PublishRelay<Action>()
    
    private let mainStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
    }
    private let buttonStack = UIStackView()
    private let newListButton = UIButton().then {
        $0.backgroundColorHex = "#EBF1FF"
        $0.setImage(UIImage(named: "addNewList"), for: .normal)
    }
    private let listButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = " "
        config.baseBackgroundColor = UIColor(hexString: "#EBF1FF")
        config.background.cornerRadius = 0
        config.cornerStyle = .fixed
        let listButton = UIButton(configuration: config)
        listButton.titleLabel?.font = .systemFont(ofSize: 14)
        listButton.setTitleColor(UIColor(hexString: "#3D5CFF"), for: .normal)
        return listButton
    }()
    private let arrowDownButton = UIButton().then {
        $0.backgroundColorHex = "#EBF1FF"
        $0.setImage(UIImage(named: "downArrow"), for: .normal)
    }
    private let sourceTextField = QueryStringTextField().then {
        $0.textColor = UILabel().textColor
        $0.font = .systemFont(ofSize: 25)
        $0.textAlignment = .center
    }
    private let speakerButton: UIButton = {
        let config = UIButton.Configuration.speakerButtonConfiguration
        let button = UIButton(configuration: config)
        return button
    }()
    private let translateResultView = TranslateResultView()
    private let saveButton = UIButton().then {
        $0.setTitle("添加".localized(), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColorHex = "3D5CFF"
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.createDefaultList()
    }
    
    private weak var viewModel: VocabularyViewModel?
    
    func bind(_ viewModel: VocabularyViewModel) {
        self.viewModel = viewModel
        viewModel.inout.vocabulary.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            self.sourceTextField.text = text
            self.sourceTextField.updateUnderLineColor()
        }).disposed(by: disposeBag)
    
        sourceTextField.rx.text.bind(to: viewModel.inout.vocabulary).disposed(by: disposeBag)
        
        viewModel.output.translateData.subscribe(onNext: { [weak self] translateData in
            guard let self = self else { return }
            self.translateResultView.config(model: translateData)
        }).disposed(by: disposeBag)
        
        viewModel.output.vocabularyListORM.subscribe(onNext: { [weak self] orm in
            guard let self = self else { return }
            self.listButton.setTitle(orm?.name, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.output.showEditListNameAlert.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showEditListNameAlert()
        }).disposed(by: disposeBag)
        
        viewModel.output.phonetic.bind(to: speakerButton.rx.title()).disposed(by: disposeBag)
    }
    
    private func showEditListNameAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertVC.title = "請輸入新的清單名稱".localized()
        alertVC.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.text = self.viewModel?.output.vocabularyListORM.value?.name?.localized()
        }
        let ok = UIAlertAction(title: "確認".localized(),
                               style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newName = alertVC.textFields?.first?.text else { return }
            self.viewModel?.setListORMName(newName)
        }
        let cancel = UIAlertAction(title: "取消".localized(), style: .default) { [weak self] _ in
            self?.viewModel?.cancelNewListORM()
        }
        
        alertVC.addAction(cancel)
        alertVC.addAction(ok)
        
        present(alertVC, animated: true, completion: {
            alertVC.textFields?.first?.selectAll(nil)
        })
    }
    
    private func showListPicker() {
        guard let orms = viewModel?.getAllList() else { return }
        let picker = UIPickerViewController<VocabularyCardListORM.ORM>()
        picker.setModels(models: [orms])
        
        picker.selected = { [weak self] orm in
            guard let self = self else { return }
            self.viewModel?.selected(orm: orm)
        }
        
        present(picker, animated: true, completion: nil)
    }
}

// UI
extension VocabularyViewController {
    private func configUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview()
            $0.top.equalTo(10)
        }

        mainStack.addArrangedSubviews([
            mainStack.padding(gap: 20),
            sourceTextField,
            mainStack.padding(gap: 10),
            speakerButton,
            mainStack.padding(gap: 10),
            translateResultView,
            mainStack.padding(gap: 10),
            buttonStack,
            mainStack.padding(gap: 10),
            saveButton,
            mainStack.padding(gap: 10),
        ])
        
        configSourceTextField()
        configTranslateResultView()
        layoutButtonStack()
        configSaveButton()
    }
    
    private func configSourceTextField() {
        sourceTextField.snp.makeConstraints { view in
            view.width.equalToSuperview().multipliedBy(0.8)
        }
        sourceTextField.delegate = self
    }
    
    private func configTranslateResultView() {
        translateResultView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(10)
            let screenHeight = UIScreen.main.bounds.height
            $0.height.equalTo(screenHeight * 0.3)
        }
        translateResultView.mainTranslate.delegate = self
    }
    
    private func layoutButtonStack() {
        buttonStack.axis = .horizontal
        buttonStack.spacing = 0
        buttonStack.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        buttonStack.addArrangedSubviews([
            buttonStack.padding(gap: 20),
            newListButton,
            buttonStack.padding(gap: 1),
            listButton,
            arrowDownButton,
            buttonStack.padding(gap: 20),
        ])
        
        newListButton.snp.makeConstraints {
            $0.size.equalTo(44)
        }
        
        newListButton.cornerRadius = 5
        newListButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        arrowDownButton.snp.makeConstraints {
            $0.size.equalTo(newListButton)
        }
        
        arrowDownButton.cornerRadius = 5
        arrowDownButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    private func configSaveButton() {
        saveButton.cornerRadius = 22
        saveButton.clipsToBounds = true
        saveButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
    }
    
    private func saveChanged(_ textField: UITextField) {
        if textField === sourceTextField {
            viewModel?.sentQueryRequest()
        } else if textField === translateResultView.mainTranslate {
            viewModel?.input.customTranslate.accept(textField.text)
        }
    }
}

// user action
extension VocabularyViewController {
    func bindActions() {
        listButtonAction()
        newListButtonAction()
        saveButtonAction()
        speakerButtonAction()
    }
    
    func listButtonAction() {
        [listButton, arrowDownButton].forEach {
            $0.rx.tap.subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showListPicker()
            }).disposed(by: disposeBag)
        }
    }
    
    func newListButtonAction() {
        newListButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.cerateNewListORM()
        }).disposed(by: disposeBag)
    }
    
    func saveButtonAction() {
        saveButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel?.saveVocabularyCard()
            
            // 創建UIImpactFeedbackGenerator
            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            // 開始震動
            impactFeedbackGenerator.prepare()
            impactFeedbackGenerator.impactOccurred()
            self.action.accept(.dismissWithAnimate)
        }).disposed(by: disposeBag)
    }
    
    func speakerButtonAction() {
        speakerButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            guard let source = self.sourceTextField.text else { return }
            Speaker.speak(source, language: .en_US)
        }).disposed(by: disposeBag)
    }
}

extension VocabularyViewController: UITextFieldDelegate {    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeBackgroundCloseView()
        saveChanged(textField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        addBackgroundCloseView(
            textField,
            disposeBag: disposeBag) { [weak self] in
                self?.saveChanged(textField)
            }
        return true
    }
}

// MARK: -
class TranslateResultView: UIStackView {
    let mainTranslate = QueryStringTextField().then {
        $0.font = .systemFont(ofSize: 17)
    }
    private let translateTextView = TranslateTextView().then {
        $0.font = .systemFont(ofSize: 17)
        $0.backgroundColorHex = "#F8F7F7"
        $0.isEditable = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 8
        alignment = .leading
        configUI()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func prepareForReuse() {
        mainTranslate.text = nil
    }
    
    func config(model: StarDictORM.ORM?) {
        prepareForReuse()
        mainTranslate.text = model?.getMainTranslation()?.localized()
        mainTranslate.updateUnderLineColor()
        translateTextView.config(model: model)
    }
    
    private func configUI() {
        addArrangedSubviews([
            mainTranslate,
            padding(gap: 10),
            translateTextView,
        ])
        translateTextView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
    }
}
