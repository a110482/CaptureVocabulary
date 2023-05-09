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
        $0.alignment = .center
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
    private let explainsTextView = TranslateTextView().then {
        $0.font = .systemFont(ofSize: 17)
        $0.backgroundColorHex = "#F8F7F7"
        $0.isEditable = false
    }
    private var adBannerView = UIView()
    private weak var viewModel: ReviewViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData {
            self.viewModel?.loadLastReadVocabularyCard()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AdsManager.shared.rootViewController = self
    }
    
    func bind(viewModel: ReviewViewModel) {
        self.viewModel = viewModel
        
        viewModel.output.scrollToIndex
            .debounce(.microseconds(100), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (indexRow, animation) in
                guard let self = self else { return }
                self.scrollCellTo(index: indexRow, animated: animation)
            }).disposed(by: disposeBag)
        
        viewModel.output.needReloadDate.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.output.dictionaryData.subscribe(onNext: { [weak self] (dictionaryData) in
            guard let self = self else { return }
            self.explainsTextView.config(model: dictionaryData)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubviews([
            headerView,
            collectionView,
            mainStackView.padding(gap: 20),
            explainsTextView,
            mainStackView.padding(gap: 20),
            adBannerView
        ])
        
        configHeaderView()
        configCollectionView()
        configExplainsTextView()
        configAdView()
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
            $0.width.equalToSuperview()
        }
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        collectionView.register(cellWithClass: ReviewCollectionViewCell.self)
    }
    
    func configExplainsTextView() {
        explainsTextView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.95)
        }
    }
    
    func configAdView() {
        let height = AdsManager.shared.adSize.size.height
        adBannerView.snp.makeConstraints {
            $0.height.equalTo(height)
            $0.width.equalToSuperview()
        }
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
        cell.delegate = viewModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.width * 0.85, height: collectionView.height)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollCellTo(index: centralCellIndex())
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollCellTo(index: centralCellIndex())
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateLastReadCard()
        adjustIndex()
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
    
    private func updateLastReadCard() {
        guard let index = centralCellIndex() else { return }
        viewModel?.updateLastReadCard(index: index)
    }
    
    private func adjustIndex() {
        viewModel?.adjustIndex()
    }
    
    private func scrollCellTo(index: Int?, animated: Bool = true) {
        let centralIndexPath = IndexPath(row: index ?? 0, section: 0)
        collectionView.scrollToItem(at: centralIndexPath,
                                    at: .centeredHorizontally,
                                    animated: animated)
    }
}

// google ad
extension ReviewViewController: AdSimpleBannerPowered {
    var placeholder: UIView? {
        adBannerView
    }
}
