//
//  VocabularyCardsCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/8.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift
import MapKit

class VocabularyCardsCoordinator: Coordinator<UINavigationController> {
    private var viewController: VocabularyCardsViewController!
    private var viewModel: VocabularyCardsViewModel!
    private let selectedList: VocabularyCardListORM.ORM
    
    init(rootViewController: UINavigationController, selectedList: VocabularyCardListORM.ORM) {
        self.selectedList = selectedList
        super.init(rootViewController: rootViewController)
    }
    
    override func start() {
        guard !started else { return }
        viewController = VocabularyCardsViewController()
        viewModel = VocabularyCardsViewModel(selectedList: selectedList)
        viewController.bind(viewModel)
        show(viewController: viewController)
        super.start()
    }
    
    @available(*, unavailable)
    public required init(rootViewController: UINavigationController) {
        fatalError("init(rootViewController:) has not been implemented")
    }
}

// MARK: -
class VocabularyCardsViewModel {
    struct Output {
        let cards = BehaviorRelay<[VocabularyCardORM.ORM]>(value: [])
    }
    let output = Output()
    
    let selectedList: VocabularyCardListORM.ORM
    
    init(selectedList: VocabularyCardListORM.ORM) {
        self.selectedList = selectedList
        loadCards()
    }
    
    func loadCards() {
        guard let listId = selectedList.id else { return }
        let cards = VocabularyCardORM.ORM.allList(listId: listId) ?? []
        output.cards.accept(cards)
    }
}

// MARK: -
class VocabularyCardsViewController: UITableViewController {
    
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
    
    //delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let cellModel = cellModels[indexPath.row]
        cell.textLabel?.text = "\(cellModel.normalizedSource ?? "") | \(cellModel.normalizedTarget ?? "")"
        return cell
    }
}

//UI
extension VocabularyCardsViewController {
    func configUI() {
        tableView.register(cellWithClass: UITableViewCell.self)
    }
}
