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
        let scrollToIndex = PublishRelay<(index: Int, animated: Bool)>()
        let dictionaryData = BehaviorRelay<StringTranslateAPIResponse?>(value: nil)
    }
    let output = Output()
    let indexCount = max(VocabularyCardORM.ORM.cardNumbers() * 3, 30)
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
        
        output.scrollToIndex.accept((index, true))
        if newIndex != index {
            // 重新校正 index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
                self.output.scrollToIndex.accept((newIndex, false))
            }
        }
    }
    
    func queryLocalDictionary(vocabulary: String) {
        let queryModel = YDTranslateAPIQueryModel(queryString: vocabulary)
        let response = StringTranslateAPIResponse.load(queryModel: queryModel)
        output.dictionaryData.accept(response)
    }
}
