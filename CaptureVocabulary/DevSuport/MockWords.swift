//
//  MockWords.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/20.
//

import RxSwift
import RxCocoa

private struct MockWordsModel: Codable {
    let mockWords: [String]
}

class MockWords {
    private static let shared = MockWords()
    private var resettableDisposeBag = DisposeBag()
    private var words: [String] = []
    
    /// 建立假單字卡資料
    static func makeDataBaseData() {
        shared.make()
    }
    
    private func make() {
        words = readMockWords()
        next()
    }
}

private extension MockWords {
    func readMockWords() -> [String] {
        let mockWords = JsonReader.read(
            fileName: "mockWords",
            modelType: MockWordsModel.self)
        return mockWords?.mockWords ?? []
    }
    
    func next() {
        guard words.count > 0 else { return }
        let nextWord = words.removeFirst()
        sendRequest(vocabulary: nextWord)
    }
    
    func sendRequest(vocabulary: String) {
        typealias Req = YDTranslateAPI
        resettableDisposeBag = DisposeBag()
        
        let normalized = vocabulary.normalized
        let queryModel = YDTranslateAPIQueryModel(queryString: normalized)
        
        guard Req.ResponseModel.load(queryModel: queryModel) == nil else {
            return
        }
        
        let request = Req(queryModel: queryModel)
        let api = RequestBuilder<Req>()
        api.result.subscribe(onNext: { [weak self] res in
            guard let self = self else { return }
            guard let res = res else { return }
            guard res.isWord ?? false else { return }
            Log.debug("mock words: ", vocabulary)
            res.create(nil)
            self.saveVocabularyCard(model: res)
            self.next()
        }).disposed(by: resettableDisposeBag)
        api.send(req: request)
        
    }
    
    func saveVocabularyCard(model: YDTranslateAPI.ResponseModel) {
        guard let translate = model.translation?.first else { return }
        guard let vocabulary = model.query else { return }
        guard var cardListObj = VocabularyCardListORM.ORM.lastEditList() else { return }
        
        var cardObj = VocabularyCardORM.ORM()
        cardObj.normalizedSource = vocabulary
        cardObj.normalizedTarget = translate
        cardObj.cardListId = cardListObj.id
        VocabularyCardORM.create(cardObj)
        cardListObj.timestamp = Date().timeIntervalSince1970
        VocabularyCardListORM.update(cardListObj)
    }
}




