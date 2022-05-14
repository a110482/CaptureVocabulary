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


// MARK: - ViewModel
class VocabularyViewModel {
    struct Inout {
        let vocabulary = BehaviorRelay<String?>(value: nil)
        let translate = BehaviorRelay<String?>(value: nil)
        let translateData = BehaviorRelay<AzureDictionaryModel?>(value: nil)
    }
    let `inout` = Inout()
    
    struct Output {
        let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
    }
    
    let output = Output()
    
    private let disposeBag = DisposeBag()
    
    init(vocabulary: String) {
        `inout`.vocabulary.accept(vocabulary)
        sentQueryRequest()
        getVocabularyListObject()
    }
    
    // 等按 return 再查詢, 不然流量太兇
    func sentQueryRequest() {
        guard let vocabulary = `inout`.vocabulary.value else { return }
        typealias Req = AzureDictionary

        let normalized = vocabulary.normalized
        if let savedModel = AzureDictionaryModel.load(normalizedSource: normalized).first {
            updateData(model: savedModel)
        } else {
            let request = Req(queryModel: .init(Text: vocabulary))
            let api = RequestBuilder<Req>()
            api.send(req: request)
            api.result.subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else { return }
                guard let translateData = response.first else { return }
                translateData.create()
                self.updateData(model: translateData)
            }).disposed(by: disposeBag)
        }
    }
    
    private func updateData(model: AzureDictionaryModel) {
        setDefaultTranslate(model)
        setNormalizedSource(model)
        `inout`.translateData.accept(model)
    }
    
    // 建立新的清單
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        output.vocabularyListORM.accept(newORM)
        output.showEditListNameAlert.accept(())
    }
    
    // 刪除當前清單
    func cancelNewListORM() {
        output.vocabularyListORM.value?.delete()
        output.vocabularyListORM.accept(nil)
        getVocabularyListObject()
    }
    
    func setListORMName(_ name: String) {
        guard var orm = output.vocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        output.vocabularyListORM.accept(orm)
    }
    
    func selected(orm: VocabularyCardListORM.ORM) {
        output.vocabularyListORM.accept(orm)
    }
    
    func getAllList() -> [VocabularyCardListORM.ORM] {
        return VocabularyCardListORM.ORM.allList() ?? []
    }
    
    func saveVocabularyCard() {
        guard let vocabulary = `inout`.vocabulary.value,
              let translate = `inout`.translate.value,
              let groupId = output.vocabularyListORM.value?.id
        else { return }
        var cardObj = VocabularyCardORM.ORM()
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.groupId = groupId
        VocabularyCardORM.create(cardObj)
        guard var listObj = output.vocabularyListORM.value else { return }
        listObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(listObj)
    }
    
    private func setDefaultTranslate(_ translateData: AzureDictionaryModel) {
        let translate = translateData.translations?.first?.displayTarget
        self.inout.translate.accept(translate)
    }
    
    private func setNormalizedSource(_ translateData: AzureDictionaryModel) {
        let normalizedSource = translateData.normalizedSource
        `inout`.vocabulary.accept(normalizedSource)
    }
    
    private func getVocabularyListObject() {
        let lastEditList = VocabularyCardListORM.ORM.lastEditList()
        output.vocabularyListORM.accept(lastEditList)
    }
}

extension VocabularyCardListORM.ORM: UIPickerViewModelProtocol {
    var title: String {
        return name ?? ""
    }
}

// MARK: - View
class VocabularyViewController: UIViewController {
    enum Action {
        case dismiss
    }
    let action = PublishRelay<Action>()
    
    private let mainStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 20
    }
    private let buttonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 1
    }
    private let newListButton = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle("+", for: .normal)
    }
    private let listButton = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle(" ", for: .normal)
    }
    private let sourceTextField = UITextField().then {
        $0.textColor = UILabel().textColor
        $0.font = .systemFont(ofSize: 25)
        $0.textAlignment = .center
    }
    private let translateTextField = UITextField().then {
        $0.textColor = UILabel().textColor
        $0.font = .systemFont(ofSize: 25)
        $0.textAlignment = .center
    }
    private let speakerButton = UIButton().then {
        $0.setImage(UIImage(systemName: "speaker.wave.3"), for: .normal)
    }
    private let tableView = UITableView()
    private let saveButton = UIButton().then {
        $0.setTitle("儲存".localized(), for: .normal)
        $0.setTitleColor(UILabel().textColor, for: .normal)
    }
    private var cellDatas: [AzureDictionaryModel.Translation]? {
        viewModel?.inout.translateData.value?.translations
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel?.output.vocabularyListORM.value == nil {
            viewModel?.cerateNewListORM()
        }
    }
    
    private weak var viewModel: VocabularyViewModel?
    
    func bind(_ viewModel: VocabularyViewModel) {
        self.viewModel = viewModel
        viewModel.inout.vocabulary.bind(to: sourceTextField.rx.text).disposed(by: disposeBag)
        sourceTextField.rx.text.bind(to: viewModel.inout.vocabulary).disposed(by: disposeBag)
        
        viewModel.inout.translate.bind(to: translateTextField.rx.text).disposed(by: disposeBag)
        translateTextField.rx.text.bind(to: viewModel.inout.translate).disposed(by: disposeBag)
        
        viewModel.inout.translateData.subscribe(onNext: { [weak self] translateData in
            guard let self = self else { return }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.output.vocabularyListORM.subscribe(onNext: { [weak self] orm in
            guard let self = self else { return }
            self.listButton.setTitle(orm?.name, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.output.showEditListNameAlert.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showEditListNameAlert()
        }).disposed(by: disposeBag)
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
        
        let separateLine = UIView().then {
            $0.backgroundColor = UILabel().textColor
        }
        
        mainStack.addArrangedSubviews([
            buttonStack,
            sourceTextField,
            separateLine,
            translateTextField,
            speakerButton,
            tableView,
            saveButton
        ])
        buttonStack.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        separateLine.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(1)
        }
        [sourceTextField, translateTextField].forEach {
            $0.snp.makeConstraints { view in
                view.width.equalToSuperview()
            }
        }
        sourceTextField.delegate = self
        configTableView()
        layoutButtonStack()
    }
    
    private func layoutButtonStack() {
        buttonStack.addArrangedSubviews([
            listButton, newListButton
        ])
        newListButton.snp.makeConstraints {
            $0.width.equalTo(50)
        }
    }
    
    private func configTableView() {
        tableView.snp.makeConstraints {
            $0.height.equalTo(UIScreen.main.bounds.height*0.3)
            $0.width.equalToSuperview()
        }
        tableView.register(cellWithClass: UITableViewCell.self)
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
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
        listButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showListPicker()
        }).disposed(by: disposeBag)
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

extension VocabularyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        guard let cellModel = cellDatas?[safe: indexPath.row] else { return cell }
        var text = "\(cellModel.posTag?.string ?? ""): "
        text += "\(cellModel.displayTarget ?? "")"
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellModel = cellDatas?[safe: indexPath.row] else { return }
        guard let displayTarget = cellModel.displayTarget else { return }
        viewModel?.inout.translate.accept(displayTarget)
    }
}
