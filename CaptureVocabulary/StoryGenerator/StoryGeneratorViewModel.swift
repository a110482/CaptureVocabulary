//
//  StoryGeneratorViewModel.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import Foundation

class StoryGeneratorViewModel {
    let vocabularyAmountRange: ClosedRange<Float> = Float(10) ... Float(50)
    private(set) lazy var output = Output(self)
    
    init() {
        storyStyleOptions = Self.setStoryStyleOptions()
        cellModels = Self.loadVocabularyCard()
    }
    
    private var storyStyleOptions: [StoryStyleOption]
    private var cellModels: [StoryGeneratorListSettingCellModel]
    private lazy var vocabularyAmount: Float = vocabularyAmountRange.average
}

extension StoryGeneratorViewModel {
    class Output: RxOutput<StoryGeneratorViewModel> {
        var storyStyleOptions: [StoryStyleOption] { target.storyStyleOptions }
        var cellModels: [StoryGeneratorListSettingCellModel] { target.cellModels }
        var vocabularyAmount: Float { target.vocabularyAmount }
    }
    
    func setSelected(option: StoryStyleOption) {
        storyStyleOptions.inoutForEach({
            $0.isSelected = $0 == option
        })
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
    static func setStoryStyleOptions() -> [StoryStyleOption] {
        var options = [
            StoryStyleOption(key: NSLocalizedString("StoryGenerator.fairyTales", comment: "童話")),
            StoryStyleOption(key: NSLocalizedString("StoryGenerator.conversation", comment: "對話")),
            StoryStyleOption(key: NSLocalizedString("StoryGenerator.news", comment: "新聞"))
        ]
        
        options[0].isSelected.toggle()
        return options
    }
    
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
