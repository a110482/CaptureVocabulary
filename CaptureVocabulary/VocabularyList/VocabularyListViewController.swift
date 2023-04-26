//
//  VocabularyListViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/10.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift


private enum DisplayModel {
    case normal
    case deleteMode
}

class VocabularyListViewController: UIViewController {
    enum Action {
        case selectedList(orm: VocabularyCardListORM.ORM)
    }
    
    let action = PublishRelay<Action>()
    
    private let tableView = UITableView()
    
    private let disposeBag = DisposeBag()
    
    private weak var viewModel: VocabularyListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "單字卡清單".localized()
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let add = UIBarButtonItem(title: "+新增".localized(),
                                  style: .plain,
                                  target: self,
                                  action: #selector(tapAddList))
        navigationItem.leftBarButtonItems = [add]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.loadList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc private func tapAddList() {
        viewModel?.cerateNewListORM()
    }
    
    private var cellModels: [VocabularyCardListORM.ORM] {
        viewModel?.output.cardListModels.value ?? []
    }
    
    func bind(_ viewModel: VocabularyListViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.cardListModels.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.output.showEditListNameAlert.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showEditListNameAlert()
        }).disposed(by: disposeBag)
        
        viewModel.output.needReloadTableview.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func showEditListNameAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertVC.title = "請輸入新的清單名稱".localized()
        alertVC.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.text = self.viewModel?.output.newVocabularyListORM.value?.name?.localized()
        }
        
        let cancel = UIAlertAction(title: "取消".localized(), style: .default) { [weak self] _ in
            self?.viewModel?.cancelNewListORM()
        }
        
        let ok = UIAlertAction(title: "確認".localized(),
                               style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newName = alertVC.textFields?.first?.text else { return }
            self.viewModel?.setListORMName(newName)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(ok)
        present(alertVC, animated: true, completion: {
            alertVC.textFields?.first?.selectAll(nil)
        })
    }
}

// UI
extension VocabularyListViewController {
    func configUI() {
        view.addSubview(tableView)
        configTable()
    }
    
    func configTable() {
        tableView.backgroundColor = UIColor(hexString: "#E5E5E5")
        tableView.register(cellWithClass: VocabularyListCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// delegate
extension VocabularyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: VocabularyListCell.self)
        let cellModel = cellModels[indexPath.row]
        cell.bind(cellModel)
        cell.delegate = viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        action.accept(.selectedList(orm: cellModel))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let cellModel = cellModels[indexPath.row]
        cellModel.delete()
        viewModel?.loadList()
    }
}
