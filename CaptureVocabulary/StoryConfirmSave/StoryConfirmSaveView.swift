//
//  StoryConfirmSaveView.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/2/27.
//

import SwiftUI
import RxCocoa
import RxSwift

struct StoryConfirmSaveView: View {
    @ObservedObject var viewModel: StoryConfirmSaveViewModel
    let title = NSLocalizedString("StoryGeneratorViewController.title", comment: "故事生成器")
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
            Divider()
                .background("CBCBCB".color)
            StoryDisplayView(viewModel: viewModel.storyDisplayViewModel)
                .frame(maxHeight: .infinity)
                .padding(.top, 10)
                .background("F8F7F7".color)
                .padding(.leading, 24)
                .padding(.trailing, 24)
            buttonViews()
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
    
    init(viewModel: StoryConfirmSaveViewModel) {
        self.viewModel = viewModel
    }
}

private extension StoryConfirmSaveView {
    @ViewBuilder
    func buttonViews() -> some View {
        let saveString = NSLocalizedString(
            "VocabularyViewController.save",
            comment: "儲存")
        let cancelString = NSLocalizedString(
            "VocabularyListViewController.cancel",
            comment: "取消"
        )
        
        
        HStack {
            Spacer().frame(width: 34)
            
            Button(cancelString) {
                viewModel.pressCancelButton()
            }
            .font(.system(size: 13, weight: .bold))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background("667080".color)
            .foregroundStyle(Color.white)
            .cornerRadius(10)
            
            Spacer().frame(width: 27)
            
            Button(saveString) {
                viewModel.pressSaveButton()
            }
            .font(.system(size: 13, weight: .bold))
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background("3D5CFF".color)
            .foregroundStyle(Color.white)
            .cornerRadius(10)
            
            Spacer().frame(width: 34)
        }
    }
}

// MARK: - ViewModel
class StoryConfirmSaveViewModel: ObservableObject {
    @Published private(set) var storyDisplayViewModel: StoryDisplayViewModel
    private(set) lazy var output = Output(self)
    
    
    init(storyDisplayViewModel: StoryDisplayViewModel) {
        self.storyDisplayViewModel = storyDisplayViewModel
    }
    private let action = PublishRelay<Action>()
}

extension StoryConfirmSaveViewModel {
    enum Action {
        case pressSaveButton
        case pressCancelButton
    }
    
    class Output: RxOutput<StoryConfirmSaveViewModel> {
        var action: Observable<Action> {
            target.action.asObservable()
        }
    }
    
    @MainActor
    func pressSaveButton() {
        action.accept(.pressSaveButton)
    }
    
    @MainActor
    func pressCancelButton() {
        action.accept(.pressCancelButton)
    }
}

#Preview {
    let model = StoryDataModel.mock
    let storyORM = StoryORM.ORM(storyDataModel: model)!
    let storyDisplayViewModel = StoryDisplayViewModel(storyORM: storyORM)!
    let viewModel = StoryConfirmSaveViewModel(storyDisplayViewModel: storyDisplayViewModel)
    HStack {
        StoryConfirmSaveView(viewModel: viewModel)
            .background(Color.white)
            .frame(height: 600)
    }
    .frame(maxHeight: .infinity)
    .background(Color.black)
    .ignoresSafeArea()
}
