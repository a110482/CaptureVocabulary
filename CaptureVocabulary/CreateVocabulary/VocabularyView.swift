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
    
    private let disposeBag = DisposeBag()
    
    init(vocabulary: String) {
        `inout`.vocabulary.accept(vocabulary)
        sentQueryRequest()
    }
    
    // 等按 return 再查詢, 不然流量太兇～
    func sentQueryRequest() {
        guard let vocabulary = `inout`.vocabulary.value else { return }
        typealias Req = AzureDictionary
        let request = Req(queryModel: .init(Text: vocabulary))
        let api = RequestBuilder<Req>()
        api.send(req: request)
        api.result.subscribe(onNext: { [weak self] response in
            guard let self = self else { return }
            guard let response = response else { return }
            guard let translateData = response.first else { return }
            self.setDefaultTranslate(translateData)
            self.`inout`.translateData.accept(translateData)
        }).disposed(by: disposeBag)
    }
    
    func setDefaultTranslate(_ translateData: AzureDictionaryModel) {
        let translate = translateData.translations?.first?.displayTarget
        self.inout.translate.accept(translate)
    }
}

// MARK: - View
class VocabularyView: UIView {
    private let mainStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }
    private let sourceTextField = UITextField()
    private let translateTextField = UITextField()
    private let tableView = UITableView()
    private var cellDatas: [AzureDictionaryModel.Translation]? {
        viewModel?.inout.translateData.value?.translations
    }
    
    private let disposeBag = DisposeBag()
    init() {
        super.init(frame: .zero)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private weak var viewModel: VocabularyViewModel?
    func bind(_ viewModel: VocabularyViewModel) {
        self.viewModel = viewModel
        sourceTextField.text = viewModel.inout.vocabulary.value
        sourceTextField.rx.text.bind(to: viewModel.inout.vocabulary).disposed(by: disposeBag)
        
        viewModel.inout.translate.bind(to: translateTextField.rx.text).disposed(by: disposeBag)
        translateTextField.rx.text.bind(to: viewModel.inout.translate).disposed(by: disposeBag)
        
        viewModel.inout.translateData.subscribe(onNext: { [weak self] translateData in
            guard let self = self else { return }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func configUI() {
        addEmptyGestureBackgroundView()
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
        addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview()
            $0.top.equalTo(10)
        }
        
        let separateLine = UIView().then {
            $0.backgroundColor = .black
        }
        
        mainStack.addArrangedSubviews([
            sourceTextField,
            separateLine,
            translateTextField,
            tableView
        ])
        
        separateLine.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(1)
        }
        [sourceTextField, translateTextField].forEach {
            $0.snp.makeConstraints { view in
                view.width.equalToSuperview()
            }
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 25)
            $0.textColor = .black
        }
        sourceTextField.delegate = self
        configTableView()
    }
    
    private func addEmptyGestureBackgroundView() {
        let backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        let emptyGesture = UITapGestureRecognizer()
        backgroundView.addGestureRecognizer(emptyGesture)
    }
    
    private func configTableView() {
        tableView.snp.makeConstraints {
            $0.height.equalTo(UIScreen.main.bounds.height*0.5)
            $0.width.equalToSuperview()
        }
        tableView.register(cellWithClass: UITableViewCell.self)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension VocabularyView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.sentQueryRequest()
    }
}

extension VocabularyView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDatas?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        guard let cellModel = cellDatas?[safe: indexPath.row] else { return cell }
        cell.textLabel?.textColor = .black
        cell.contentView.backgroundColor = .white
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
