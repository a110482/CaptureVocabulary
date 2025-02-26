//
//  StoryDisplayView.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/2/26.
//

import SwiftUI

struct StoryDisplayView: View {
    @ObservedObject var viewModel: StoryDisplayViewModel
    
    var body: some View {
        buildTitle()
        buildContent()
        Spacer()
    }
    

    init(viewModel: StoryDisplayViewModel) {
        self.viewModel = viewModel
    }
}

private extension StoryDisplayView {
    /// 標題
    @ViewBuilder
    func buildTitle() -> some View {
        Text(viewModel.storyDataModel.title.en)
            .font(.system(size: 20))
        if !viewModel.isTranslateHidden {
            Text(viewModel.storyDataModel.title.ch)
        }
    }
    
    /// 內文
    @ViewBuilder
    func buildContent() -> some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.storyDataModel.story.indices, id: \.self) { index in
                    let model = viewModel.storyDataModel.story[index]
                    let text = highlightedText(
                        source: model.article,
                        keys: viewModel.storyDataModel.vocabulary)
                    
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if !viewModel.isTranslateHidden {
                        Text(model.translate)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                    }
                }
            }.padding([.leading, .trailing], 16)
        }
    }

    func highlightedText(source: String, keys: [String]) -> AttributedString {
        var attributedString = AttributedString(source)
        for key in keys {
            var searchString = attributedString [attributedString.startIndex..<attributedString.endIndex]
            while let range = searchString.range(of: key, options: .caseInsensitive) {
                attributedString[range].foregroundColor = .blue
                attributedString[range].link = URL(string: "captureVocabulary://textLink/\(key)")
                searchString = attributedString[range.upperBound..<attributedString.endIndex]
            }
        }
        return attributedString
    }
}

class StoryDisplayViewModel: ObservableObject {
    @Published private(set) var storyDataModel: StoryDataModel
    @Published private(set) var isTranslateHidden: Bool = false
    let storyORM: StoryORM.ORM
    
    init?(storyORM: StoryORM.ORM) {
        self.storyORM = storyORM
        guard let storyDataModel = storyORM.getStoryDataModel() else { return nil }
        self.storyDataModel = storyDataModel
    }
    
    func set(isTranslateHidden: Bool) {
        self.isTranslateHidden = isTranslateHidden
    }
}

#Preview {
    let model = StoryDataModel.mock
    let storyORM = StoryORM.ORM(storyDataModel: model)!
    let viewModel = StoryDisplayViewModel(storyORM: storyORM)!
    StoryDisplayView(viewModel: viewModel)
}
