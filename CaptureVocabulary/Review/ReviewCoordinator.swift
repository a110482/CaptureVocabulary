//
//  ReviewCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/15.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

class ReviewCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: ReviewViewController!
    private(set) var viewModel: ReviewViewModel!
    
    override func start() {
        guard !started else { return }
        viewController = ReviewViewController()
        viewModel = ReviewViewModel()
        viewController.bind(viewModel: viewModel)
        super.start()
    }
}

// MARK: -
class ReviewViewModel {
    struct Output {
        let scrollToIndex = PublishRelay<Int>()
    }
    let output = Output()
    let indexCount = VocabularyCardORM.ORM.cardNumbers(memorized: false) * 5
    private var middleIndex: Int { indexCount/2 }
    private var lastReadCardId: Int? {
        get {
            UserDefaults.standard[UserDefaultsKeys.vocabularyCardReadId]
        }
        set {
            UserDefaults.standard[UserDefaultsKeys.vocabularyCardReadId] = newValue
        }
    }
    
    func loadVocabularyCard() {
        let index = VocabularyCardORM.ORM.getIndex(by: lastReadCardId)
        output.scrollToIndex.accept(index + middleIndex)
        print(index + middleIndex)
    }
    
    func queryVocabularyCard(index: Int) -> VocabularyCardORM.ORM? {
        let cellModelsCount = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        var absIndex = (index - middleIndex)
        while absIndex < 0 {
            absIndex += cellModelsCount
        }
        absIndex = absIndex % cellModelsCount
        let orm = VocabularyCardORM.ORM.get(by: absIndex)
        return orm
    }
    
    func updateLastReadCardId(index: Int) {
        guard let orm = queryVocabularyCard(index: index) else { return }
        guard let id = orm.id else { return }
//        print("index: \(index - middleIndex), id: \(id)")
        lastReadCardId = Int(id)
//        print(lastReadCardId)
    }
    
    /// 重新校正 index 以維持無線滾動維持在中央
    func adjustIndex(index: Int) {
        let cellModelsCount = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        var newIndex = index
        while (newIndex - middleIndex) > cellModelsCount {
            newIndex -= cellModelsCount
        }
        while (middleIndex - newIndex) > cellModelsCount {
            newIndex += cellModelsCount
        }
        guard newIndex != index else { return }
        output.scrollToIndex.accept(newIndex)
    }
}

// MARK: -
class ReviewViewController: UIViewController {
    
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
    }
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private weak var viewModel: ReviewViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 100)
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.viewModel?.loadVocabularyCard()
        }
        
    }
    
    func bind(viewModel: ReviewViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.scrollToIndex.subscribe(onNext: { [weak self] indexRow in
            guard let self = self else { return }
            self.collectionView.scrollToItem(at: IndexPath(row: indexRow, section: 0),
                                             at: .centeredHorizontally,
                                             animated: false)
        }).disposed(by: disposeBag)
    }
}

// UI
private extension ReviewViewController {
    func configUI() {
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.bottom.equalToSuperview()
        }
        
        mainStackView.addArrangedSubviews([
            collectionView,
            UIView().then { $0.backgroundColor = .gray }
        ])
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(view).multipliedBy(0.35)
        }
        
        configCollectionView()
    }
    
    func configCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(cellWithClass: ReviewCollectionViewCell.self)
    }
}

extension ReviewViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.indexCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ReviewCollectionViewCell.self, for: indexPath)
        guard let cellModel = viewModel?.queryVocabularyCard(index: indexPath.row) else { return cell }
        cell.sourceLabel.text = cellModel.normalizedSource
        cell.translateLabel.text = cellModel.normalizedTarget
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.width, height: collectionView.height)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            getIndexOfCentralCell()
            adjustIndex()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getIndexOfCentralCell()
        adjustIndex()
    }
    
    private func centralCellIndex() -> Int? {
        guard let cell = collectionView.visibleCells.first else { return nil }
        guard let index = collectionView.indexPath(for: cell) else { return nil }
        return index.row
    }
    
    private func getIndexOfCentralCell() {
        guard let index = centralCellIndex() else { return }
        viewModel?.updateLastReadCardId(index: index)
    }
    
    private func adjustIndex() {
        guard let index = centralCellIndex() else { return }
        viewModel?.adjustIndex(index: index)
    }
}

// MARK: -

class ReviewCollectionViewCell: UICollectionViewCell {
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 10
    }
    // 暫時開放, 等ＵＩ設計完成再封裝
    let sourceLabel = UILabel()
    let translateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configUI() {
        contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        let padding = mainStackView.padding(gap: 1).then {
            $0.backgroundColor = .gray
        }
        
        mainStackView.addArrangedSubviews([
            sourceLabel,
            padding,
            translateLabel
        ])
        
        padding.snp.makeConstraints {
            $0.width.equalTo(contentView).multipliedBy(0.8)
        }
    }
}
