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
    private let speakerButton = UIButton().then {
        $0.setImage(UIImage(systemName: "speaker.wave.3"), for: .normal)
    }
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
        
        viewModel.inout.translateData.subscribe(onNext: { [weak self] translateData in
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
        
        translateResultView.customTranslate
            .bind(to: viewModel.input.customTranslate)
            .disposed(by: disposeBag)
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
            self.action.accept(.dismiss)
            
            // 創建UIImpactFeedbackGenerator
            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            // 開始震動
            impactFeedbackGenerator.prepare()
            impactFeedbackGenerator.impactOccurred()
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
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        viewModel?.sentQueryRequest()
    }
}

// MARK: -
class TranslateResultView: UIStackView {
    private let phonetic = UILabel()
    let translate = UITextField()
    private let explainsTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 17)
        $0.backgroundColorHex = "#F8F7F7"
        $0.isEditable = false
    }
    let customTranslate = BehaviorRelay<String?>(value: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 8
        configUI()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
    func prepareForReuse() {
        explainsTextView.text = nil
        phonetic.text = nil
        translate.text = nil
        explainsTextView.contentOffset = .zero
    }
    
    func config(model: StringTranslateAPIResponse?) {
        prepareForReuse()
        if let usPhonetic = model?.basic?.usPhonetic {
            phonetic.text = "[US] \(usPhonetic)"
        }
        
        if let explains = model?.basic?.explains {
            let partOfSpeech = explains.map { $0.halfWidth.split(separator: ";") }
            for speech in partOfSpeech {
                explainsTextView.text = speech.reduce(explainsTextView.text ?? "", {
                    $0 + ($0.isEmpty ? "" : "\n") + String($1).trimmed
                })
                explainsTextView.text = (explainsTextView.text ?? "") + "\n\n"
            }
            
            Task {
                explainsTextView.text = await explainsTextView.text.localized()
            }
        }
        
        if let translation = model?.translation?.first {
            translate.text = translation.localized()
        }
    }
    
    private func configUI() {
        addArrangedSubviews([
            phonetic,
            translate,
            explainsTextView
        ])
        translate.delegate = self
    }
}

extension TranslateResultView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        translate.resignFirstResponder()
        customTranslate.accept(textField.text)
        return true
    }
}

