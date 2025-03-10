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
        words.forEach({ writeIntoDatabase(word: $0)})
    }
}

private extension MockWords {
    func readMockWords() -> [String] {
        let mockWords = JsonReader.read(
            fileName: "mockWords",
            modelType: MockWordsModel.self)
        return mockWords?.mockWords ?? []
    }
    
    func writeIntoDatabase(word: String) {
        let vocabularyViewModel = VocabularyViewModel(vocabulary: word)
        let _ = vocabularyViewModel.saveVocabularyCard()
    }
}




