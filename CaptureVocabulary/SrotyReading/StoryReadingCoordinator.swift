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
    private var viewModel: StoryDisplayViewModel!
    
    required init(rootViewController: UINavigationController,
                  storyModel: StoryORM.ORM) {
        viewModel = StoryDisplayViewModel(storyORM: storyModel)
        assert(viewModel != nil)
        super.init(rootViewController: rootViewController)
    }
    
    override func start() {
        guard !started else { return }
        super.start()
        let view = StoryDisplayView(viewModel: viewModel)
        viewController = StoryReadingViewController(rootView: view)
        viewController.hidesBottomBarWhenPushed = true
        show(viewController: viewController)
    }
    
    @available(*, unavailable)
    required init(rootViewController: UIViewController) {
        fatalError()
    }
}

class StoryReadingViewController: UIHostingController<StoryDisplayView> {
    
}
