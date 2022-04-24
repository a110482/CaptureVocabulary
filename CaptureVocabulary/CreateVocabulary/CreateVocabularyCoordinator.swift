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
        let view = VocabularyView()
        view.bind(viewModel)
        viewController.pop(view: view)
        present(viewController: viewController)
    }
}
