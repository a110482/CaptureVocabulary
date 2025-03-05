//
//  MyStoryCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/31.
//

import Foundation
import RxSwift
import RxCocoa

class MyStoryCoordinator: Coordinator<UIViewController> {
    private(set) var navigationViewController: UINavigationController!
    private(set) var viewController: MyStoryViewController!
    private(set) var viewModel: MyStoryViewModel!
    private let disposeBag = DisposeBag()
    
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = MyStoryViewController()
        viewModel = MyStoryViewModel()
        viewController.bind(viewModel: viewModel)
        handle(action: viewModel.output.action)
        navigationViewController = UINavigationController(rootViewController: viewController)
        
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.popStoryGenerator()
        })
#endif
    }
}

private extension MyStoryCoordinator {
    func handle(action: Observable<MyStoryViewModel.Action>) {
        action.subscribe(onNext: { [weak self] action in
            guard let self else { return }
            switch action {
            case .newStory:
                popStoryGenerator()
            }
        }).disposed(by: disposeBag)
    }
    
    /// 彈出設定新故事的頁面
    func popStoryGenerator() {
        let coordinator = StoryGeneratorCoordinator(rootViewController: navigationViewController)
        startChild(coordinator: coordinator)
        coordinator.delegate = self
    }
}

extension MyStoryCoordinator: StoryGeneratorCoordinatorDelegate {
    func storyDidSave() {
        viewModel.loadStories()
    }
}
