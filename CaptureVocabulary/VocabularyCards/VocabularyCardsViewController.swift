//
//  VocabularyCardsViewController.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/12.
//

import RxCocoa
import RxSwift
import UIKit

class VocabularyCardsViewController: UIViewController {
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
    }
    
    private let tableView = UITableView()
    
    private weak var viewModel: VocabularyCardsViewModel?
    
    private var cellModels: [VocabularyCardORM.ORM] {
        viewModel?.output.cards.value ?? []
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel?.selectedList.name
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        let deleteMode = UIBarButtonItem(title: "刪除模式".localized(), style: .plain, target: nil, action: nil)
        
        navigationItem.rightBarButtonItems = [deleteMode]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.loadCards()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func bind(_ viewModel: VocabularyCardsViewModel) {
        self.viewModel = viewModel
        viewModel.output.cards.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

//UI
extension VocabularyCardsViewController {
    func configUI() {
        view.addSubview(mainStackView)
        configMainStack()
        mainStackView.addArrangedSubviews([
            tableView
        ])
        configTableView()
    }
    
    func configMainStack() {
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configTableView() {
        tableView.register(cellWithClass: VocabularyCardCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexString: "#E5E5E5")
    }
}

// Delegate
extension VocabularyCardsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: VocabularyCardCell.self)
        let cellModel = cellModels[indexPath.row]
        cell.bind(cellModel: cellModel)
        cell.delegate = self.viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let cellModel = cellModels[indexPath.row]
        cellModel.delete()
        viewModel?.loadCards()
    }
}
