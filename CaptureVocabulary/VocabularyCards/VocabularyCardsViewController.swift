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
    enum Action {
        case selectedCell(cardModel: VocabularyCardORM.ORM)
    }
    
    let action = PublishRelay<Action>()
    
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
    }
    
    private let tableView = UITableView()
    
    private let filterView = SegmentedView()
    
    private weak var viewModel: VocabularyCardsViewModel?
    
    private var cellModels: [VocabularyCardORM.ORM] = []
    
    private var sortingOptions: [VocabularyCardsSortingOption] = []
    
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
            guard let self else { return }
            self.cellModels = cellModels
            snapshot.deleteAllItems()
            snapshot.appendSections([0])
            snapshot.appendItems(cellModels)
            dataSource.apply(self.snapshot, animatingDifferences: false)
        }).disposed(by: disposeBag)
        
        viewModel.output.sortingOptions.subscribe(onNext: { [weak self] sortingOptions in
            guard let self else { return }
            self.sortingOptions = sortingOptions
            filterView.reloadData()
        }).disposed(by: disposeBag)
        
        filterView.setSelected(index: viewModel.defaultSelectedIndex)
    }
}

//UI
extension VocabularyCardsViewController {
    func configUI() {
        view.backgroundColor = "E5E5E5".uicolor
        view.addSubview(mainStackView)
        configMainStack()
        mainStackView.addArrangedSubviews([
            filterView,
            tableView
        ])
        configTableView()
        configFilterView()
    }
    
    func configMainStack() {
        mainStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func configFilterView() {
        filterView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        filterView.delegate = self
        filterView.dataSource = self
        filterView.backgroundColor = .clear
        filterView.configuration.optionWidth = SegmentedViewConfiguration.equalWidth
        filterView.configuration.optionBottomBarIsHidden = false
        filterView.configuration.selectedOptionsColor = .clear
        filterView.configuration.defaultOptionsColor = .clear
        filterView.configuration.optionBottomBarColor = "3D5CFF".uicolor
    }
    
    func configTableView() {
        tableView.register(cellWithClass: VocabularyCardCell.self)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        dataSource.delegate = self
    }
}

// MARK: - Delegate
extension VocabularyCardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellModel = cellModels[safe: indexPath.row] else {
            fatalError("index out of range")
        }
        action.accept(.selectedCell(cardModel: cellModel))
    }
}

extension VocabularyCardsViewController: DataSourceDelegate {
    func deleteCell(at indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        cellModel.delete()
        viewModel?.loadCards()
    }
}

extension VocabularyCardsViewController: SegmentedViewDataSource, SegmentedViewDelegate {
    func segmentedView(_ view: SegmentedView, titleForOptionAt index: Int) -> SegmentedOptionView {
        let segment = VocabularyCardsSortingOptionView()
        segment.config(filterOption: sortingOptions[index])
        return segment
    }
    
    func numberOfOptions(in view: SegmentedView) -> Int {
        sortingOptions.count
    }
    
    func segmentedView(_ view: SegmentedView, didSelectOptionAt index: Int) {
        viewModel?.didSelectFilterOption(at: index)
    }
}

// MARK: - 為了 data span shot
extension VocabularyCardORM.ORM: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(memorized)
        hasher.combine(normalizedSource)
        hasher.combine(normalizedTarget)
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
