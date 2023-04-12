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
    
    init(rootViewController: UINavigationController, selectedList: VocabularyCardListORM.ORM) {
        self.selectedList = selectedList
        super.init(rootViewController: rootViewController)
    }
    
    override func start() {
        guard !started else { return }
        viewController = VocabularyCardsViewController()
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
