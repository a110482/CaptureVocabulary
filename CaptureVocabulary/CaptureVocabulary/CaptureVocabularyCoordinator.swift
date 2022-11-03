//
//  CreateVocabularyCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/18.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - Coordinator
class CaptureVocabularyCoordinator: Coordinator<UIViewController> {
    var viewController: CaptureVocabularyViewController!
    var viewModel: CaptureVocabularyViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = CaptureVocabularyViewController()
        observeAction(viewController)
        viewModel = CaptureVocabularyViewModel()
        viewController.bind(viewModel: viewModel)
    }
    
    private func observeAction(_ viewController: CaptureVocabularyViewController) {
        viewController.action.subscribe(onNext: { [weak self] action in
            switch action {
            case .selected(let vocabulary):
                self?.presentCreateVocabularyCoordinator(vocabulary)
            }
        }).disposed(by: disposeBag)
    }
    
    private func presentCreateVocabularyCoordinator(_ vocabulary: String) {
        let coordinator = CreateVocabularyCoordinator(rootViewController: viewController, vocabulary: vocabulary)
        startChild(coordinator: coordinator)
    }
}

