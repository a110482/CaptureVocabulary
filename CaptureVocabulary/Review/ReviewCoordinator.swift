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
import MessageUI

class ReviewCoordinator: Coordinator<UIViewController> {
    private(set) var navController: UINavigationController!
    private var viewController: ReviewViewController!
    private(set) var viewModel: ReviewViewModel!
    private let disposeBag = DisposeBag()
    private let mailDelegator = MailDelegator()
    
    override func start() {
        guard !started else { return }
        viewController = ReviewViewController()
        viewModel = ReviewViewModel()
        viewController.bind(viewModel: viewModel)
        bindAction(viewController: viewController)
        navController = UINavigationController(rootViewController: viewController)
        super.start()
    }
}

// actions
private extension ReviewCoordinator {
    func bindAction(viewController: ReviewViewController) {
        viewController.action
            .subscribe(onNext: { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .settingPage:
                    self.settingPage()
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///  轉跳設定頁面
    func settingPage() {
        let coordinator = SettingPageCoordinator(rootViewController: navController)
        startChild(coordinator: coordinator)
    }
}



// MARK: - mail delegate
private class MailDelegator: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}
