//
//  VocabularyListCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/8.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

class VocabularyListCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: UINavigationController!
    private(set) var viewModel: VocabularyListViewModel!
    private let disposeBag = DisposeBag()
    
    override func start() {
        guard !started else { return }
        let vc = VocabularyListViewController()
        viewController = UINavigationController(rootViewController: vc)
        viewModel = VocabularyListViewModel()
        vc.bind(viewModel)
        present(viewController: viewController)
        handleAction(vc)
        super.start()
    }
    
    private func handleAction(_ vc: VocabularyListViewController) {
        vc.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .selectedList(let orm):
                let coordinator = VocabularyCardsCoordinator(
                    rootViewController: self.viewController,
                    selectedList: orm)
                self.startChild(coordinator: coordinator)
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: -
private enum DisplayModel {
    case normal
    case deleteMode
}

class VocabularyListViewController: UITableViewController {
    enum Action {
        case selectedList(orm: VocabularyCardListORM.ORM)
    }
    
    let action = PublishRelay<Action>()
    
    private let disposeBag = DisposeBag()
    
    private weak var viewModel: VocabularyListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "單字卡清單".localized()
        configTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let add = UIBarButtonItem(title: "+新增".localized(),
                                  style: .plain,
                                  target: self,
                                  action: #selector(tapAddList))
        
        let deleteMode = UIBarButtonItem(title: "刪除模式".localized(), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItems = [add]
        navigationItem.rightBarButtonItems = [deleteMode]
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
        viewModel?.output.allList.value ?? []
    }
    
    func bind(_ viewModel: VocabularyListViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.allList.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
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
        
        alertVC.addAction(ok)
        alertVC.addAction(cancel)
        present(alertVC, animated: true, completion: {
            alertVC.textFields?.first?.selectAll(nil)
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let cellModel = cellModels[indexPath.row]
        cell.textLabel?.text = cellModel.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        action.accept(.selectedList(orm: cellModel))
    }
}

// UI
extension VocabularyListViewController {
    func configTable() {
        tableView.register(cellWithClass: UITableViewCell.self)
    }
}

// MARK: -
class VocabularyListViewModel {
    struct Output {
        let allList = BehaviorRelay<[VocabularyCardListORM.ORM]>(value: [])
        let vocabularyListORM = BehaviorRelay<VocabularyCardListORM.ORM?>(value: nil)
        let showEditListNameAlert = PublishRelay<Void>()
    }
    
    let output = Output()
    
    init() {
        loadList()
    }
    
    func loadList() {
        let allList = VocabularyCardListORM.ORM.allList() ?? []
        output.allList.accept(allList)
    }
    
    func setListORMName(_ name: String) {
        guard var orm = output.vocabularyListORM.value else { return }
        orm.name = name
        VocabularyCardListORM.update(orm)
        output.vocabularyListORM.accept(orm)
        loadList()
    }
    
    func cancelNewListORM() {
        output.vocabularyListORM.value?.delete()
        output.vocabularyListORM.accept(nil)
        loadList()
    }
    
    func cerateNewListORM() {
        let newORM = VocabularyCardListORM.ORM.newList()
        output.vocabularyListORM.accept(newORM)
        output.showEditListNameAlert.accept(())
        loadList()
    }
}
