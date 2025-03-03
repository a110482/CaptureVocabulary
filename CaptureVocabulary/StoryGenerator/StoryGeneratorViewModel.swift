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
    private let apiResponse = BehaviorRelay<Response?>(value: nil)
}

extension StoryGeneratorViewModel {
    class Output: RxOutput<StoryGeneratorViewModel> {
        var cellModels: [StoryGeneratorListSettingCellModel] { target.cellModels }
        var vocabularyAmount: Float { target.vocabularyAmount }
        var apiResponse: Observable<Response> { target.apiResponse.compactMap({ $0 }).asObservable() }
    }
    
    enum Response {
        case apiSuccess(story: StoryORM.ORM, queryVocabularies: [VocabularyCardORM.ORM])
        case apiFailure
    }
    
    func set(vocabularyAmount: Int) {
        self.vocabularyAmount = Float(vocabularyAmount)
    }
    
    /// 切換單字庫的選擇狀態
    func toggle(cellModel: StoryGeneratorListSettingCellModel) {
        guard let index = cellModels.firstIndex(where: { $0.id == cellModel.id }) else { return }
        cellModels[index].isSelected.toggle()
    }
    
    /// 點擊產生故事
    func pressStoryGenerateButton() {
        // 確定有觀看廣告的獎勵
        guard AdsManager.shared.output.isPresentInterstitialAdValue else { return }
        
        SwiftTask {
            guard let result = await sendStoryGeneratorApi() else {
                await sendFailureAction()
                return
            }
            await sendSuccessAction(result: result)
        }
    }
    
    func saveStory() {
        guard case let .apiSuccess(story, queryVocabularies) = apiResponse.value else { return }
        story.save(with: queryVocabularies)
        apiResponse.accept(nil)
    }
    
    func cancelStory() {
        apiResponse.accept(nil)
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
    
    func sendStoryGeneratorApi() async -> (story: StoryORM.ORM, queryVocabularies: [VocabularyCardORM.ORM])? {
        let allVocabularies = readAllVocabularies()
        let queryVocabularies = randomElements(array: allVocabularies, amount: Int(vocabularyAmount))
        guard isVocabularyValid(allVocabularies: queryVocabularies) else { return nil }
        let queryVocabulariesString = queryVocabularies.compactMap({ $0.normalizedSource })
        
        let request = StoryGeneratorApi(vocabularyList: queryVocabulariesString)
        let provider = MoyaProvider<StoryGeneratorApi>()
        let response = await provider.send(request: request)
        
        guard case let .success(model) = response else { return nil }
        let message = model.choices.first?.message.content ?? ""
        guard let messageModel = try? JSONDecoder().decode(StoryGeneratorApi.MessageModels.self, from: message.data(using: .utf8)!) else {
            return nil
        }
        
        guard let storyOrm = StoryORM.ORM(storyDataModel: messageModel) else {
            return nil
        }
        return (story: storyOrm, queryVocabularies: queryVocabularies)
    }
    
    @MainActor
    func sendFailureAction() {
        apiResponse.accept(.apiFailure)
    }

    @MainActor
    func sendSuccessAction(result: (story: StoryORM.ORM, queryVocabularies: [VocabularyCardORM.ORM])) {
        apiResponse.accept(.apiSuccess(story: result.story, queryVocabularies: result.queryVocabularies))
    }
}

// MARK: - 其他 model
