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
    
    private lazy var dataSource: EditableTableViewDiffableDataSource = {
        let dataSource = EditableTableViewDiffableDataSource(
            tableView: self.tableView) { (tableView, indexPath, cellModel) in
                let cell = tableView.dequeueReusableCell(withClass: VocabularyCardCell.self)
                cell.bind(cellModel: cellModel)
                cell.delegate = self.viewModel
                return cell
            }
        return dataSource
    }()
    
    private var snapshot: NSDiffableDataSourceSnapshot<Int, VocabularyCardORM.ORM> = {
        var snapshot = NSDiffableDataSourceSnapshot<Int, VocabularyCardORM.ORM>()
        snapshot.appendSections([0])
        return snapshot
    }()
    
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
        viewModel.output.cards.subscribe(onNext: { [weak self] cellModels in
            guard let self = self else { return }
            self.snapshot.deleteAllItems()
            self.snapshot.appendSections([0])
            self.snapshot.appendItems(cellModels)
            self.dataSource.apply(self.snapshot, animatingDifferences: false)
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
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hexString: "#E5E5E5")
        dataSource.delegate = self
    }
}

// Delegate
extension VocabularyCardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension VocabularyCardsViewController: DataSourceDelegate {
    func deleteCell(at indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        cellModel.delete()
        viewModel?.loadCards()
    }
}

/// 為了 data span shot
extension VocabularyCardORM.ORM: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(memorized)
    }
    
    static func == (lhs: VocabularyCardORM.ORM, rhs: VocabularyCardORM.ORM) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

protocol DataSourceDelegate: AnyObject {
    func deleteCell(at indexPath: IndexPath)
}

class EditableTableViewDiffableDataSource: UITableViewDiffableDataSource<Int, VocabularyCardORM.ORM> {
    weak var delegate: DataSourceDelegate?
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        delegate?.deleteCell(at: indexPath)
    }
}
