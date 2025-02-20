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
    private(set) lazy var output = Output(self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("VocabularyListViewController.flashcards", comment: "單字庫")
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let add = UIBarButtonItem(
            title: NSLocalizedString("VocabularyListViewController.addNew",
                                     comment: "+新增"),
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
    
    private let action = PublishRelay<Action>()
    
    private let tableView = UITableView()
    
    private let disposeBag = DisposeBag()
    
    private weak var viewModel: VocabularyListViewModel?
}

extension VocabularyListViewController {
    class Output: RxOutput<VocabularyListViewController> {
        var action: Observable<VocabularyListViewController.Action> {
            target.action.asObservable()
        }
    }
    
    enum Action {
        case selectedList(orm: VocabularyCardListORM.ORM)
    }
    
    func bind(_ viewModel: VocabularyListViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.cardListModels.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.output.showCreateNewListNameAlert.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            showCreateNewListNameAlert()
        }).disposed(by: disposeBag)
        
        viewModel.output.needReloadTableview.subscribe(onNext: { [weak self] in
            guard let self else { return }
            tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}


// MARK: - private functions
private extension VocabularyListViewController {
    var cellModels: [VocabularyCardListORM.ORM] {
        viewModel?.output.cardListModelsValue ?? []
    }
    
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
    
    @objc func tapAddList() {
        viewModel?.cerateNewListORM()
    }
    
    func showCreateNewListNameAlert() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertVC.title = NSLocalizedString("VocabularyListViewController.enterNewListName", comment: "請輸入新的清單名稱")
        alertVC.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.text = self.viewModel?.output.newVocabularyListORMValue?.name
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.cancel", comment: "取消"), style: .default) { [weak self] _ in
            self?.viewModel?.cancelNewListORM()
        }
        
        let ok = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"),
                               style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newName = alertVC.textFields?.first?.text else { return }
            self.viewModel?.setNewListORMName(newName)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(ok)
        present(alertVC, animated: true, completion: {
            alertVC.textFields?.first?.selectAll(nil)
        })
    }
    
    /// cell 左滑選項-刪除
    func cellDeleteOption(indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("VocabularyListViewController.delete", comment: "刪除")
        let deleteAction = UIContextualAction(style: .destructive, title: title) { [weak self] _, _, completionHandler in
            guard let self else { return }
            let cellModel = cellModels[indexPath.row]
            cellModel.delete()
            viewModel?.loadList()
            completionHandler(true) // 完成動作，左滑選項會自動收回
        }
        return deleteAction
    }
    
    /// cell 左滑選項  - 編輯
    func cellEditOption(indexPath: IndexPath) -> UIContextualAction {
        let title = NSLocalizedString("VocabularyListViewController.edit", comment: "編輯")
        let editAction = UIContextualAction(style: .normal, title: title) { _, _, completionHandler in
            self.showEditListNameAlert(indexPath: indexPath)
            completionHandler(true)
        }
        // 設定背景顏色
        editAction.backgroundColor = .gray
        return editAction
    }
    
    /// 顯示編輯現有的清單名稱
    func showEditListNameAlert(indexPath: IndexPath) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertVC.title = NSLocalizedString("VocabularyListViewController.enterNewListName", comment: "請輸入新的清單名稱")
        alertVC.addTextField { [weak self] textField in
            guard let self = self else { return }
            textField.text = self.viewModel?.getCurrentEditModelName(indexPath: indexPath)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.cancel", comment: "取消"), style: .default)
        
        let ok = UIAlertAction(title: NSLocalizedString("VocabularyListViewController.confirm", comment: "確認"),
                               style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newName = alertVC.textFields?.first?.text else { return }
            self.viewModel?.setCurrentEditModelName(indexPath: indexPath, newName: newName)
        }
        alertVC.addAction(cancel)
        alertVC.addAction(ok)
        present(alertVC, animated: true, completion: {
            alertVC.textFields?.first?.selectAll(nil)
        })
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
    
    // Delegate: 左滑動操作
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete Action
        let deleteAction = cellDeleteOption(indexPath: indexPath)
        
        // Edit Action
        let editAction = cellEditOption(indexPath: indexPath)
        
        // 加入動作到配置
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false // 禁止完全滑動觸發第一個動作
        
        return configuration
    }
}

