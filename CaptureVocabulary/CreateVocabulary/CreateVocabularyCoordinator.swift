//
//  CreateVocabularyCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/24.
//

import UIKit
import SnapKit
import SwifterSwift
import Vision
import RxCocoa
import RxSwift
import Then


class CreateVocabularyCoordinator: Coordinator<UIViewController> {
    var viewController: PopupViewController!
    var viewModel: VocabularyViewModel!
    private let disposeBag = DisposeBag()
    
    private let vocabulary: String
    
    required init(rootViewController: UIViewController, vocabulary: String) {
        self.vocabulary = vocabulary
        super.init(rootViewController: rootViewController)
    }
    
    @available(*, unavailable)
    public required init(rootViewController: UIViewController) {
        fatalError("init(rootViewController:) has not been implemented")
    }
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = PopupViewController()
        viewModel = VocabularyViewModel(vocabulary: vocabulary)
        let vc = VocabularyViewController()
        handleAction(vc)
        vc.bind(viewModel)
        viewController.pop(viewController: vc)
        present(viewController: viewController)
    }
    
    override func stop() {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        super.stop()
    }
    
    private func handleAction(_ vc: VocabularyViewController) {
        vc.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .dismiss:
                self.stop()
            }
        }).disposed(by: disposeBag)
    }
}
