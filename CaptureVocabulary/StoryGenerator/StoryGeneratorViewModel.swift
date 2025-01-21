//
//  StoryGeneratorViewModel.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import Foundation
import Moya

class StoryGeneratorViewModel {
    let vocabularyAmountRange: ClosedRange<Float> = Float(10) ... Float(50)
    private(set) lazy var output = Output(self)
    
    init() {
        cellModels = Self.loadVocabularyCard()
#if block//DEBUG
        let demoVoca: [String] = [
            "Analyze",
            "Benevolent",
            "Contribute",
            "Diligent",
            "Empathy",
            "Formulate",
            "Hypothesis",
            "Integrate",
            "Jeopardize",
            "Knowledgeable",
            "Lucrative",
            "Magnify",
            "Navigate",
            "Oblivious",
            "Perception",
            "Quantify",
            "Resilient",
            "Substantiate",
            "Thrive",
            "Ubiquitous"
        ]
        let req = StoryGeneratorApi(vocabularyList: demoVoca)
        
        let provider = MoyaProvider<StoryGeneratorApi>()
        provider.send(request: req) { result in
            guard case .success(let model) = result else {
                return
            }
            let message = model.choices.first?.message.content ?? ""
            guard let messageModel = try? JSONDecoder().decode(StoryGeneratorApi.MessageModels.self, from: message.data(using: .utf8)!) else {
                return
            }
            print(messageModel)
        }
#endif
    }
    
    private var cellModels: [StoryGeneratorListSettingCellModel]
    private lazy var vocabularyAmount: Float = vocabularyAmountRange.average
}

extension StoryGeneratorViewModel {
    class Output: RxOutput<StoryGeneratorViewModel> {
        var cellModels: [StoryGeneratorListSettingCellModel] { target.cellModels }
        var vocabularyAmount: Float { target.vocabularyAmount }
    }
    
    func set(vocabularyAmount: Int) {
        self.vocabularyAmount = Float(vocabularyAmount)
    }
    
    func toggle(cellModel: StoryGeneratorListSettingCellModel) {
        guard let index = cellModels.firstIndex(where: { $0.id == cellModel.id }) else { return }
        cellModels[index].isSelected.toggle()
    }
    
    func sendStoryGeneratorApi() {
        
    }
}

private extension StoryGeneratorViewModel {
    static func loadVocabularyCard() -> [StoryGeneratorListSettingCellModel] {
        let cards = VocabularyCardListORM.ORM.allList()
        let cellModels = cards?.map({ StoryGeneratorListSettingCellModel(orm: $0) })
        return cellModels ?? []
    }
}

// MARK: - 其他 model
struct StoryStyleOption: Equatable {
    let key: String
    var isSelected = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.key == rhs.key
    }
}
