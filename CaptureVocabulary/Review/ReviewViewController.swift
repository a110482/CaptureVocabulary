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
import MediaPlayer


// MARK: -
class ReviewViewController: UIViewController {
    enum Action {
        case settingPage
        case feedback
    }
    let action = PublishRelay<Action>()
    private static let cellGape = CGFloat(12)
    private let topBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(hexString: "5669FF")
    }
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .center
    }
    private let headerView = UIView()
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
            self.explainsTextView.update(
                isHiddenTranslateSwitchOn: viewModel.isHiddenTranslateSwitchOn,
                pressTipVocabulary: viewModel.pressTipVocabulary)
        }).disposed(by: disposeBag)
        
        Driver.combineLatest(
            viewModel.output.dictionaryData,
            viewModel.output.sentences).debounce(.milliseconds(100)).drive(onNext: { [weak self] (dictionaryData, sentences) in
                guard let self = self else { return }
                self.explainsTextView.config(
                    model: dictionaryData,
                    sentences: sentences,
                    isHiddenTranslateSwitchOn: viewModel.isHiddenTranslateSwitchOn,
                    pressTipVocabulary: viewModel.pressTipVocabulary)
            }).disposed(by: disposeBag)
    }
}

// UI
private extension ReviewViewController {
    func configUI() {
        view.backgroundColor = UIColor(hexString: "E5E5E5")
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubviews([
            headerView,
            explainsTextView,
            mainStackView.padding(gap: 20),
            collectionView,
            mainStackView.padding(gap: 20),
            adBannerView
        ])
        
        configHeaderView()
        configCollectionView()
        configExplainsTextView()
        configAdView()
        
        view.insertSubview(topBackgroundView, belowSubview: mainStackView)
        configTopBackground()
    }
    
    func configTopBackground() {
        topBackgroundView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(collectionView.snp.centerY)
        }
    }
    
    func configHeaderView() {
        headerView.backgroundColor = .clear
        headerView.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview().multipliedBy(0.85)
        }
        let leftButton = gearButton()
        headerView.addSubview(leftButton)
        leftButton.snp.makeConstraints {
            $0.left.centerY.equalToSuperview()
        }
        
        let titleLabel = UILabel().then {
            $0.text = NSLocalizedString("ReviewViewController.review", comment: "複習")
            $0.font = .systemFont(ofSize: 20)
            $0.textColor = .white
        }
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        let rightButton = feedbackButton()
        headerView.addSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.right.centerY.equalToSuperview()
        }
        
    }
    
    func configCollectionView() {
        collectionView.snp.makeConstraints {
            $0.height.equalTo(view.snp.height).multipliedBy(0.2)
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
            $0.width.equalToSuperview().multipliedBy(0.85)
        }
    }
    
    func configAdView() {
        let height = AdsManager.shared.adSize.size.height
        adBannerView.snp.makeConstraints {
            $0.height.equalTo(height)
            $0.width.equalToSuperview()
        }
    }
    
    func gearButton() -> UIButton {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "gearshape.fill")
        config.baseBackgroundColor = .clear
        let gearButton = UIButton(configuration: config)
        gearButton.snp.makeConstraints {
            $0.size.equalTo(44)
        }
        gearButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.action.accept(.settingPage)
        }).disposed(by: disposeBag)
        return gearButton
    }
    
    func feedbackButton() -> UIButton {
        let feedbackButton = UIButton()
        feedbackButton.setTitle(NSLocalizedString("ReviewViewController.feedback", comment: "意見回饋"), for: .normal)
        feedbackButton.setTitleColor(.white, for: .normal)
        feedbackButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.action.accept(.feedback)
        }).disposed(by: disposeBag)
        return feedbackButton
    }
}

extension ReviewViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.indexCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ReviewCollectionViewCell.self, for: indexPath)
        guard let orm = viewModel?.queryVocabularyCard(index: indexPath.row) else { return cell }
        let cellModel = ReviewCollectionViewCellModel(
            orm: orm,
            isHiddenTranslateSwitchOn: viewModel?.isHiddenTranslateSwitchOn ?? true,
            pressTipVocabulary: viewModel?.pressTipVocabulary,
            isAudioModeOn: viewModel?.isAudioModeOn ?? false)
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

// MARK: -
import AVFoundation

fileprivate var player: AVAudioPlayer?

class MP3Player: NSObject {
    static let shared = MP3Player()
    
    private override init() {
        super.init()
        
        if player == nil {
            guard let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") else { return }
            player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        }
    }
    
    func playSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            guard let player = player else { return }
            player.delegate = self
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        player?.stop()
    }
}

extension MP3Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playSound()
    }
}
