//
//  ReviewCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/15.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift

class ReviewCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: ReviewViewController!
    private(set) var viewModel: ReviewViewModel!
    
    override func start() {
        guard !started else { return }
        viewController = ReviewViewController()
        viewModel = ReviewViewModel()
        viewController.bind(viewModel: viewModel)
        super.start()
    }
}





// MARK: -

