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
        let scrollToIndex = PublishRelay<(index: Int, animated: Bool)>()
        let dictionaryData = BehaviorRelay<StringTranslateAPIResponse?>(value: nil)
    }
    let output = Output()
    let indexCount = max(VocabularyCardORM.ORM.cardNumbers() * 3, 100)
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
        let index = VocabularyCardORM.ORM.getIndex(by: lastReadCardId, memorized: false)
        output.scrollToIndex.accept((index + middleIndex, false))
    }
    
    func queryVocabularyCard(index: Int) -> VocabularyCardORM.ORM? {
        let cellModelsCount = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        guard cellModelsCount > 0 else { return nil }
        var absIndex = (index - middleIndex)
        while absIndex < 0 {
            absIndex += cellModelsCount
        }
        absIndex = absIndex % cellModelsCount
        let orm = VocabularyCardORM.ORM.get(by: absIndex, memorized: false)
        return orm
    }
    
    func updateLastReadCardId(index: Int) {
        guard let orm = queryVocabularyCard(index: index) else { return }
        guard let id = orm.id else { return }
        lastReadCardId = Int(id)
    }
    
    func updateTranslateData(vocabulary: String) {
        
    }
    
    /// 重新校正 index 以維持無線滾動維持在中央
    func adjustIndex(index: Int) {
        let cellModelsCount = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        guard cellModelsCount > 0 else { return }
        var newIndex = index
        while (newIndex - middleIndex) > cellModelsCount {
            newIndex -= cellModelsCount
        }
        while (middleIndex - newIndex) > cellModelsCount {
            newIndex += cellModelsCount
        }
        output.scrollToIndex.accept((newIndex, newIndex == index))
    }
    
    func queryLocalDictionary(vocabulary: String) {
        let queryModel = YDTranslateAPIQueryModel(queryString: vocabulary)
        let response = StringTranslateAPIResponse.load(queryModel: queryModel)
        output.dictionaryData.accept(response)
    }
}

// MARK: -
class ReviewViewController: UIViewController {
    private static let cellGape = CGFloat(12)
    private let topBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(hexString: "5669FF")
    }
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }
    private let headerView = UIView().then {
        $0.backgroundColor = .clear
    }
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = cellGape
        flowLayout.minimumInteritemSpacing = cellGape
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private weak var viewModel: ReviewViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData {
            self.viewModel?.loadVocabularyCard()
            self.displayCurrentCellVocabularyTranslate()
        }
    }
    
    func bind(viewModel: ReviewViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.scrollToIndex
            .debounce(.microseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (indexRow, animated) in
            guard let self = self else { return }
            self.collectionView.scrollToItem(at: IndexPath(row: indexRow, section: 0),
                                             at: .centeredHorizontally,
                                             animated: animated)
        }).disposed(by: disposeBag)
    }
}

// UI
private extension ReviewViewController {
    func configUI() {
        view.backgroundColor = UIColor(hexString: "E5E5E5")
        configTopBackground()
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.bottom.equalToSuperview()
        }
        
        mainStackView.addArrangedSubviews([
            headerView,
            collectionView,
            UIView()
        ])
        
        configHeaderView()
        configCollectionView()
    }
    
    func configTopBackground() {
        view.addSubview(topBackgroundView)
        topBackgroundView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(222)
        }
    }
    
    func configHeaderView() {
        headerView.snp.makeConstraints {
            $0.height.equalTo(108)
        }
    }
    
    func configCollectionView() {
        collectionView.snp.makeConstraints {
            $0.height.equalTo(140)
        }
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
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
        CGSize(width: collectionView.width * 0.7, height: collectionView.height)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            getIndexOfCentralCell()
            adjustIndex()
            displayCurrentCellVocabularyTranslate()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getIndexOfCentralCell()
        adjustIndex()
        displayCurrentCellVocabularyTranslate()
    }
    
    private func centralCellIndex() -> Int? {
        let cells = collectionView.visibleCells
        guard cells.count > 0 else { return nil }
        var centralCell: UICollectionViewCell? = nil
        var centralDistance = CGFloat.greatestFiniteMagnitude
        for cell in cells {
            let c = collectionView.convert(cell.center, to: nil)
            let dis = collectionView.center.distance(from: c)
            if dis < centralDistance {
                centralCell = cell
                centralDistance = dis
            }
        }
        
        guard let index = collectionView.indexPath(for: centralCell!) else { return nil }
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
    
    private func displayCurrentCellVocabularyTranslate() {
        guard let currentCell = collectionView.visibleCells.first else { return }
        guard let index = collectionView.indexPath(for: currentCell) else { return }
        guard let cellModel = viewModel?.queryVocabularyCard(index: index.row) else { return }
        guard let vocabulary = cellModel.normalizedSource else { return }
        viewModel?.queryLocalDictionary(vocabulary: vocabulary)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [sourceLabel, translateLabel].forEach { $0.text = nil }
    }
    
    private func configUI() {
        contentView.backgroundColor = .white
        contentView.addSubview(mainStackView)
        contentView.cornerRadius = 12
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
