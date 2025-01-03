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
        storyStyleOptions = StoryGeneratorViewModel.setStoryStyleOptions()
    }
    
    private var storyStyleOptions: [StoryStyleOption]
    private lazy var vocabularyAmount: Float = vocabularyAmountRange.average
}

extension StoryGeneratorViewModel {
    class Output: RxOutput<StoryGeneratorViewModel> {
        var storyStyleOptions: [StoryStyleOption] { target.storyStyleOptions }
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
}

// MARK: - 其他 model
struct StoryStyleOption: Equatable {
    let key: String
    var isSelected = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.key == rhs.key
    }
}
