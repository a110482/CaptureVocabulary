//
//  SettingPageCoordinator.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2024/2/22.
//

import UIKit
import RxCocoa
import RxSwift

class SettingPageCoordinator: Coordinator<UINavigationController> {
    private(set) var viewController: SettingPageViewController!
    private(set) var viewModel: SettingPageViewModel!
    private let disposeBag = DisposeBag()
    
    
    override func start() {
        super.start()
        viewController = SettingPageViewController()
        viewController.title = NSLocalizedString("SettingPageViewController.title", comment: "設定")
        viewModel = SettingPageViewModel()
        viewController.bind(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        show(viewController: viewController)
    }
}

