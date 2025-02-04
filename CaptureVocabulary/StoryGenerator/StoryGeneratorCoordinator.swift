//
//  StoryGeneratorCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import UIKit
import RxSwift
import RxCocoa

class StoryGeneratorCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: StoryGeneratorViewController!
    private(set) var viewModel: StoryGeneratorViewModel!
    private let disposeBag = DisposeBag()
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = StoryGeneratorViewController()
        viewModel = StoryGeneratorViewModel()
        viewController.bind(viewModel: viewModel)
        bind(action: viewModel.output.action)
        present(viewController: viewController, animated: true)
    }
}

private extension StoryGeneratorCoordinator {
    func bind(action: Observable<StoryGeneratorViewModel.Action>) {
        action.subscribe(onNext: {[weak self] action in
            guard let self else { return }
            handle(action: action)
        }).disposed(by: disposeBag)
    }
    
    func handle(action: StoryGeneratorViewModel.Action) {
        switch action {
        case .apiFailure:
            break
        case let .apiSuccess(story, queryVocabularies):
            break
        }
    }
}
