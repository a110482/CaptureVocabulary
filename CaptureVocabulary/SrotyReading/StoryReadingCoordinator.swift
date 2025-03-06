//
//  StoryReadingCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/3/7.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa

class StoryReadingCoordinator: Coordinator<UINavigationController> {
    private var viewController: StoryReadingViewController!
    private var viewModel: StoryReadingViewModel!
    
    required init(rootViewController: UINavigationController,
                  storyModel: StoryORM.ORM) {
        viewModel = StoryReadingViewModel(storyModel: storyModel)
        assert(viewModel != nil)
        super.init(rootViewController: rootViewController)
    }
    
    override func start() {
        guard !started else { return }
        super.start()
        let view = StoryReadingView(viewModel: viewModel)
        viewController = StoryReadingViewController(rootView: view)
        viewController.hidesBottomBarWhenPushed = true
        show(viewController: viewController)
    }
    
    @available(*, unavailable)
    required init(rootViewController: UIViewController) {
        fatalError()
    }
}

class StoryReadingViewController: UIHostingController<StoryReadingView> {
    
}

// MARK: -
struct StoryReadingView: View {
    @ObservedObject var viewModel: StoryReadingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            StoryDisplayView(viewModel: viewModel.storyDisplayViewModel)
        }
    }
}

class StoryReadingViewModel: ObservableObject {
    let storyModel: StoryORM.ORM
    let storyDisplayViewModel: StoryDisplayViewModel
    init?(storyModel: StoryORM.ORM) {
        self.storyModel = storyModel
        guard let storyDisplayViewModel = StoryDisplayViewModel(storyORM: storyModel) else {
            return nil
        }
        self.storyDisplayViewModel = storyDisplayViewModel
    }
}

#Preview {
    let model = StoryDataModel.mock
    let storyORM = StoryORM.ORM(storyDataModel: model)!
    let viewModel = StoryReadingViewModel(storyModel: storyORM)!
    
    HStack {
        StoryReadingView(viewModel: viewModel)
            .background(Color.white)
            .frame(height: 700)
    }
    .frame(maxHeight: .infinity)
    .background(Color.black)
    .ignoresSafeArea()
}
