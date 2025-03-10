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
    private var viewController: StoryConfirmViewController!
    private var viewModel: StoryConfirmSaveViewModel!
    private(set) lazy var output = Output(self)
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
    
    override func stop() {
        super.stop()
        viewController.dismiss(animated: true)
    }
}

extension StoryConfirmCoordinator {
    class Output: RxOutput<StoryConfirmCoordinator> {
        var action: Observable<StoryConfirmSaveViewModel.Action> {
            target.viewModel.output.action
        }
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
