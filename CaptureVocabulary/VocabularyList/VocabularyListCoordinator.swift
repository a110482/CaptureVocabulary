//
//  VocabularyListCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/8.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

class VocabularyListCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: UINavigationController!
    private(set) var viewModel: VocabularyListViewModel!
    private let disposeBag = DisposeBag()
    
    override func start() {
        guard !started else { return }
        let vc = VocabularyListViewController()
        viewController = UINavigationController(rootViewController: vc)
        viewModel = VocabularyListViewModel()
        vc.bind(viewModel)
        present(viewController: viewController)
        handleAction(vc)
        super.start()
    }
    
    private func handleAction(_ vc: VocabularyListViewController) {
        vc.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .selectedList(let orm):
                let coordinator = VocabularyCardsCoordinator(
                    rootViewController: self.viewController,
                    selectedList: orm)
                self.startChild(coordinator: coordinator)
            }
        }).disposed(by: disposeBag)
    }
}



