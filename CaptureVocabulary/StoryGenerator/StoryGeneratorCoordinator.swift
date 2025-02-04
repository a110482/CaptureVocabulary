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
    private(set) lazy var output = Output(self)
    private(set) var viewController: StoryGeneratorViewController!
    private(set) var viewModel: StoryGeneratorViewModel!
    private let disposeBag = DisposeBag()
    private let action = PublishRelay<StoryGeneratorViewModel.Action>()
    
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

extension StoryGeneratorCoordinator {
    class Output: RxOutput<StoryGeneratorCoordinator> {
        var action: Observable<StoryGeneratorViewModel.Action> { target.action.asObservable() }
    }
}

private extension StoryGeneratorCoordinator {
    func bind(action: Observable<StoryGeneratorViewModel.Action>) {
        action.bind(to: self.action).disposed(by: disposeBag)
    }
}
