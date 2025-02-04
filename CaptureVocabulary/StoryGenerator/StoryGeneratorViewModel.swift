//
//  StoryGeneratorViewModel.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class StoryGeneratorViewModel {
    let vocabularyAmountRange: ClosedRange<Float> = Float(10) ... Float(50)
    private(set) lazy var output = Output(self)
    
    init() {
        cellModels = Self.loadVocabularyCard()
    }
    
    private var cellModels: [StoryGeneratorListSettingCellModel]
    private lazy var vocabularyAmount: Float = vocabularyAmountRange.average
    private let action = PublishRelay<Action>()
}

extension StoryGeneratorViewModel {
    class Output: RxOutput<StoryGeneratorViewModel> {
        var cellModels: [StoryGeneratorListSettingCellModel] { target.cellModels }
        var vocabularyAmount: Float { target.vocabularyAmount }
        var action: Observable<Action> { target.action.asObservable() }
    }
    
    enum Action {
        case apiSuccess(story: StoryORM.ORM, queryVocabularies: [VocabularyCardORM.ORM])
        case apiFailure
    }
    
    func set(vocabularyAmount: Int) {
        self.vocabularyAmount = Float(vocabularyAmount)
    }
    
    func toggle(cellModel: StoryGeneratorListSettingCellModel) {
        guard let index = cellModels.firstIndex(where: { $0.id == cellModel.id }) else { return }
        cellModels[index].isSelected.toggle()
    }
    
    func sendStoryGeneratorApi() {
        let allVocabularies = readAllVocabularies()
        let queryVocabularies = randomElements(array: allVocabularies, amount: Int(vocabularyAmount))
        guard isVocabularyValid(allVocabularies: queryVocabularies) else { return }
        let queryVocabulariesString = queryVocabularies.compactMap({ $0.normalizedSource })
        
        let request = StoryGeneratorApi(vocabularyList: queryVocabulariesString)
        let provider = MoyaProvider<StoryGeneratorApi>()
        provider.send(request: request) { [weak self] result in
            guard let self else { return }
            guard case .success(let model) = result else {
                action.accept(.apiFailure)
                return
            }
            let message = model.choices.first?.message.content ?? ""
            guard let messageModel = try? JSONDecoder().decode(StoryGeneratorApi.MessageModels.self, from: message.data(using: .utf8)!) else {
                action.accept(.apiFailure)
                return
            }
            guard let storyOrm = StoryORM.ORM(storyDataModel: messageModel) else {
                action.accept(.apiFailure)
                return
            }
            action.accept(.apiSuccess(story: storyOrm, queryVocabularies: queryVocabularies))
        }
    }
}

private extension StoryGeneratorViewModel {
    static func loadVocabularyCard() -> [StoryGeneratorListSettingCellModel] {
        let cards = VocabularyCardListORM.ORM.allList()
        let cellModels = cards?.map({ StoryGeneratorListSettingCellModel(orm: $0) })
        return cellModels ?? []
    }
    
    func isVocabularyValid(allVocabularies: [VocabularyCardORM.ORM]) -> Bool {
        return !allVocabularies.isEmpty
    }
    
    func readAllVocabularies() -> [VocabularyCardORM.ORM] {
        let selectedModels = cellModels.filter({ $0.isSelected })
        let cardListOrmIds = selectedModels.compactMap({ $0.orm.id })
        let allVocabularies = cardListOrmIds.flatMap({
            return VocabularyCardORM.ORM.allList(listId: $0) ?? []
        })
        return allVocabularies
    }
    
    func randomElements<Element>(array: [Element], amount: Int) -> [Element] {
        guard amount > 0 else { return [] }
        let countToFetch = min(amount, array.count) // Ensure we don't exceed the array's count
        return Array(array.shuffled().prefix(countToFetch))
    }
}

// MARK: - 其他 model
