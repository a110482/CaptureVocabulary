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
        present(viewController: viewController, animated: true)
    }
}
