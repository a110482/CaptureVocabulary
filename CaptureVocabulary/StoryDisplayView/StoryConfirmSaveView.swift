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
    
    var body: some View {
        VStack(spacing: 10) {
            StoryDisplayView(viewModel: viewModel.storyDisplayViewModel)
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
            Spacer()
            Button(cancelString) {
                viewModel.pressCancelButton()
            }
            .frame(width: 100, height: 50)
            .background(Color.gray)
            .foregroundStyle(Color.white)
            .cornerRadius(10)
            Spacer()
            Button(saveString) {
                viewModel.pressSaveButton()
            }
            .frame(width: 100, height: 50)
            .background(Color.green)
            .foregroundStyle(Color.white)
            .cornerRadius(10)
            Spacer()
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
