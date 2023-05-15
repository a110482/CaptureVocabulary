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




// MARK: - 開 mail 的程式碼
// import MessageUI
//if MFMailComposeViewController.canSendMail() {
//    let mailComposeViewController = MFMailComposeViewController()
//    mailComposeViewController.setToRecipients(["example@example.com"])
//    mailComposeViewController.setSubject("Example Subject")
//    mailComposeViewController.setMessageBody("Example Message", isHTML: false)
//    self.present(mailComposeViewController, animated: true, completion: nil)
//}
