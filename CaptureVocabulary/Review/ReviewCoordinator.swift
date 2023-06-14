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
    private(set) var viewController: ReviewViewController!
    private(set) var viewModel: ReviewViewModel!
    private let disposeBag = DisposeBag()
    private let mailDelegator = MailDelegator()
    
    override func start() {
        guard !started else { return }
        viewController = ReviewViewController()
        viewModel = ReviewViewModel()
        viewController.bind(viewModel: viewModel)
        bindAction(viewController: viewController)
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
                case .feedback:
                    self.feedback()
                }
            })
            .disposed(by: disposeBag)
    }
    
    #warning("TODO: - 設定頁面")
    func settingPage() {
        
    }
    
    func feedback() {
        guard MFMailComposeViewController.canSendMail() else {
            alertEmailNotSetting()
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.setToRecipients([AppParameters.shared.model.feedbackEmail])
        mailVC.setSubject(NSLocalizedString("ReviewCoordinator.feedback", comment: "[意見回饋]"))
        viewController.present(mailVC, animated: true, completion: nil)
        mailVC.mailComposeDelegate = mailDelegator
    }
    
    func alertEmailNotSetting() {
        let alert = UIAlertController(
            title: NSLocalizedString("ReviewCoordinator.emailFailure", comment: "無法使用郵件"),
            message: NSLocalizedString("ReviewCoordinator.setUpYourEmailAccount", comment: "請先設定郵件帳號"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("ReviewCoordinator.ok", comment: "確定"),
            style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}



// MARK: - mail delegate
private class MailDelegator: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true)
    }
}
