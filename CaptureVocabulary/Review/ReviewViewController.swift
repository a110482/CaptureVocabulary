//
//  ReviewViewController.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/16.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

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
        collectionView.decelerationRate = .fast
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
        cell.set(cellModel: cellModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.width * 0.85, height: collectionView.height)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            didEndSwapCollectionView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndSwapCollectionView()
    }
    
    // 結束拖曳單字卡之後的流程
    private func didEndSwapCollectionView() {
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
