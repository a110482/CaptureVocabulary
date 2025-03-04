//
//  StoryGeneratorCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import UIKit
import RxSwift
import RxCocoa

protocol StoryGeneratorCoordinatorDelegate: AnyObject {
    func storyDidSave()
}

class StoryGeneratorCoordinator: Coordinator<UIViewController> {
    private var viewController: StoryGeneratorViewController!
    private var viewModel: StoryGeneratorViewModel!
    private let disposeBag = DisposeBag()
    weak var delegate: StoryGeneratorCoordinatorDelegate?
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = StoryGeneratorViewController()
        viewModel = StoryGeneratorViewModel()
        viewController.bind(viewModel: viewModel)
        handle(response: viewModel.output.apiResponse)
        present(viewController: viewController, animated: true)
    }
    
    override func stop() {
        super.stop()
        viewController.dismiss(animated: true)
    }
}

private extension StoryGeneratorCoordinator {
    /// 處理產生文章結果
    func handle(response: Observable<StoryGeneratorViewModel.Response>) {
        response.subscribe(onNext: {[weak self] response in
            guard let self else { return }
            switch response {
            case let .apiSuccess(story, _):
                popStoryConfirmSave(story: story)
            case .apiFailure:
                Log.debug("api failure")
                break
            }
        }).disposed(by: disposeBag)
    }
    
    /// 處理是否要儲存文章的按鈕
    func handle(action: Observable<StoryConfirmSaveViewModel.Action>) {
        action.subscribe(onNext: { [weak self] action in
            guard let self else { return }
            switch action {
            case .pressCancelButton:
                viewModel.cancelStory()
                stopChildren()
            case .pressSaveButton:
                viewModel.saveStory()
                delegate?.storyDidSave()
                stop()
            }
        }).disposed(by: disposeBag)
    }
    
    func popStoryConfirmSave(story: StoryORM.ORM) {
        guard let coordinator = StoryConfirmCoordinator(
            rootViewController: viewController,
            storyORM: story) else { return }
        startChild(coordinator: coordinator)
        handle(action: coordinator.output.action)
    }
}
