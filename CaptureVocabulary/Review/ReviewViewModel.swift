//
//  ReviewViewModel.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/16.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: -
class ReviewViewModel {
    struct Output {
        let _sentences = BehaviorRelay<[SimpleSentencesORM.ORM]?>(value: nil)
        fileprivate let _dictionaryData = BehaviorRelay<StarDictORM.ORM?>(value: nil)
        let scrollToIndex = PublishRelay<(indexRow: Int, animation: Bool)>()
        var dictionaryData: Driver<StarDictORM.ORM?> { _dictionaryData.asDriver() }
        var sentences: Driver<[SimpleSentencesORM.ORM]?> { _sentences.asDriver() }
        let needReloadDate = PublishRelay<Void>()
    }
    let output = Output()
    let indexCount = 200
    private(set) var isHiddenTranslateSwitchOn: Bool {
        get { UserDefaults.standard[UserDefaultsKeys.isHiddenTranslateSwitchOn] ?? false }
        set { UserDefaults.standard[UserDefaultsKeys.isHiddenTranslateSwitchOn] = newValue }
    }
    private lazy var lastReadCardTableIndex = { indexCount / 2 }() // 50
    private var lastReadCardId: Int? {
        get {
            UserDefaults.standard[UserDefaultsKeys.vocabularyCardReadId]
        }
        set {
            UserDefaults.standard[UserDefaultsKeys.vocabularyCardReadId] = newValue
        }
    }
    /// 記錄目前已按下提示的 cell
    private(set) var pressTipVocabulary: String? = nil
    private let disposeBag = DisposeBag()
    
    init() {
        SimpleSentenceService.shared.registerObserver(object: self)
    }
    
    func loadLastReadVocabularyCard() {
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex,
                                     animation: false))
        queryLocalDictionary()
        querySimpleSentences()
    }
    
    func queryVocabularyCard(index: Int) -> VocabularyCardORM.ORM? {
        let dataBaseIndex = getCardDatabaseIndexBy(tableIndex: index)
        let orm = VocabularyCardORM.ORM.get(by: dataBaseIndex, memorized: false)
        return orm
    }
    
    func updateLastReadCard(index: Int) {
        // 更新 id & index 給無限滾動機制
        guard let orm = queryVocabularyCard(index: index) else { return }
        guard let id = orm.id else { return }
        lastReadCardTableIndex = index
        lastReadCardId = Int(id)
        
        // 更新字典頁面
        queryLocalDictionary()
        querySimpleSentences()
    }
    
    /// 重新校正 index 以維持無線滾動維持在中央
    /// 整個無限滾動原理:
    /// 所有 cell 資料向 database 拿資料時, 都是基於 database 裡的排序
    /// collection index 是會映射到資料庫裡的某段順序
    /// 例如:                                                                ▼ 這就是 lastReadCardTableIndex
    /// collection index:                   [0      1     2     ... 50   ... 99   100 ]
    /// database Index: [0 1 2 ...      107  108 109 ... 157 ... 206 207 108 ... 500]
    /// 然後當 collection 滾動到第 52 筆資料時, 實際是向 database 取用第 52 + 107 = 159 筆資料
    func adjustIndex() {
        let tableIndexDelta = min(
            indexCount - lastReadCardTableIndex,
            lastReadCardTableIndex)
        
        // 位移不大不調整
        guard tableIndexDelta <= indexCount/3 else { return }
        // 重設參考點
        lastReadCardTableIndex = indexCount / 2
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex,
                                     animation: false))
    }
    
    private func queryLocalDictionary() {
        guard let cellModel = queryVocabularyCard(index: lastReadCardTableIndex) else {
            output._dictionaryData.accept(nil)
            output._sentences.accept(nil)
            return
        }
        guard let vocabulary = cellModel.normalizedSource else {
            output._dictionaryData.accept(nil)
            output._sentences.accept(nil)
            return
        }
        let response = StarDictORM.query(word: vocabulary)
        output._dictionaryData.accept(response)
        if response?.word != output._sentences.value?.first?.normalizedSource {
            output._sentences.accept(nil)
        }
    }
    
    private func querySimpleSentences() {
        guard let cellModel = queryVocabularyCard(index: lastReadCardTableIndex) else {
            return
        }
        guard let vocabulary = cellModel.normalizedSource else {
            return
        }
        guard let sentences = SimpleSentenceService.shared.querySentence(queryWord: vocabulary) else {
            output._sentences.accept(nil)
            return
        }
        output._sentences.accept(sentences)
    }
    
    private func getCardDatabaseIndexBy(tableIndex: Int) -> Int {
        let allVocabularyCount = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        guard allVocabularyCount > 0 else { return 0 }
        let lastReadDataBaseIndex = VocabularyCardORM.ORM.getIndex(by: lastReadCardId, memorized: false)
        let indexDelta = tableIndex - lastReadCardTableIndex
        var databaseIndex = lastReadDataBaseIndex + indexDelta
        while databaseIndex < 0 {
            databaseIndex += allVocabularyCount
        }
        while databaseIndex > (allVocabularyCount - 1) {
            databaseIndex -= allVocabularyCount
        }
        return databaseIndex
    }
    
    #warning("版本檢查函數, 目前沒有使用")
    private func versionCheck() {
        typealias Req = VersionCheck
        let api = Req()
        let request = RequestBuilder<Req>()
        request.result.subscribe(onNext: { model in
            print(model)
        }).disposed(by: disposeBag)
        request.send(req: api)
    }
}

// cell delegate
extension ReviewViewModel: ReviewCollectionViewCellDelegate {
    func tapMemorizedSwitchButton(cellModel: VocabularyCardORM.ORM) {
        let currentMemorized = cellModel.memorized ?? false
        var newCellModel = cellModel
        newCellModel.memorized = !currentMemorized
        newCellModel.update()
        output.scrollToIndex.accept((indexRow: lastReadCardTableIndex + 1,
                                     animation: true))
        output.needReloadDate.accept(())
    }
    
    func hiddenTranslateSwitchDidChanged(isOn: Bool) {
        isHiddenTranslateSwitchOn = isOn
        pressTipVocabulary = nil
        output.needReloadDate.accept(())
    }
    
    func didPressedTipIcon() {
        pressTipVocabulary = output._dictionaryData.value?.word
        output.needReloadDate.accept(())
    }
}

// 例句服務的 delegate
extension ReviewViewModel: SimpleSentenceServiceDelegate {
    func sentencesDidLoad(normalizedSource: String) {
        querySimpleSentences()
    }
}
