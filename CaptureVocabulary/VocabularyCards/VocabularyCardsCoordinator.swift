//
//  VocabularyCardsCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/8.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift
import MapKit
import Then

class VocabularyCardsCoordinator: Coordinator<UINavigationController> {
    private var viewController: VocabularyCardsViewController!
    private var viewModel: VocabularyCardsViewModel!
    private let selectedList: VocabularyCardListORM.ORM
    private let disposeBag = DisposeBag()
    private var childActionDisposeBag: DisposeBag? = DisposeBag()
    
    init(rootViewController: UINavigationController, selectedList: VocabularyCardListORM.ORM) {
        self.selectedList = selectedList
        super.init(rootViewController: rootViewController)
    }
    
    override func start() {
        guard !started else { return }
        viewController = VocabularyCardsViewController()
        viewController.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .selectedCell(let cardModel):
                presentCreateVocabularyCoordinator(cardModel: cardModel)
            }
        }).disposed(by: disposeBag)
        viewModel = VocabularyCardsViewModel(selectedList: selectedList)
        viewController.bind(viewModel)
        show(viewController: viewController)
        super.start()
    }
    
    @available(*, unavailable)
    public required init(rootViewController: UINavigationController) {
        fatalError("init(rootViewController:) has not been implemented")
    }
}

private extension VocabularyCardsCoordinator {
    func presentCreateVocabularyCoordinator(cardModel: VocabularyCardORM.ORM) {
        let coordinator = EditVocabularyCardsCoordinator(
            rootViewController: viewController,
            cardModel: cardModel
        )
        startChild(coordinator: coordinator)
        childActionDisposeBag = DisposeBag()
        coordinator.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            self.childActionDisposeBag = nil
            switch action {
            case .dismiss:
                break
            case .saved:
                viewModel.loadCards()
            }
        }).disposed(by: childActionDisposeBag!)
    }
}
