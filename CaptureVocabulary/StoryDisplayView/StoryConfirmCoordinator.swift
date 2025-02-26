//
//  StoryConfirmCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/2/27.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa

/// 確認是否要儲存此故事
class StoryConfirmCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: StoryConfirmViewController!
    private(set) var viewModel: StoryConfirmSaveViewModel!
    private let storyORM: StoryORM.ORM
    private let disposeBag = DisposeBag()
    
    
    /// 特殊自定義 init
    /// - Parameters:
    ///   - rootViewController: 前一個畫面的 vc
    ///   - storyORM: 故事資料的 orm
    required init?(rootViewController: UIViewController, storyORM: StoryORM.ORM) {
        self.storyORM = storyORM
        super.init(rootViewController: rootViewController)
        guard let storyDisplayViewModel = StoryDisplayViewModel(storyORM: storyORM) else {
            return nil
        }
        let viewModel = StoryConfirmSaveViewModel(storyDisplayViewModel: storyDisplayViewModel)
        self.viewModel = viewModel
        let view = StoryConfirmSaveView(viewModel: viewModel)
        let viewController = StoryConfirmViewController(rootView: view)
        self.viewController = viewController
        present(viewController: viewController, animated: true)
    }
    
    
    @available(*, unavailable)
    required init(rootViewController: UIViewController) {
        fatalError()
    }
    
    override func start() {
        guard !started else { return }
        super.start()
        
    }
}

// MARK: -
class StoryConfirmViewController: UIHostingController<StoryConfirmSaveView> {
    override init(rootView: StoryConfirmSaveView) {
        super.init(rootView: rootView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
