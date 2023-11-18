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
    enum Action {
        case dismiss
        case saved
    }
    let action = PublishRelay<Action>()
    var viewController: PopupViewController!
    var viewModel: VocabularyViewModel!
    private let disposeBag = DisposeBag()
    
    private let vocabulary: String
    
    /// init
    /// - Parameters:
    ///   - rootViewController: rootViewController
    ///   - vocabulary: word that you want to query
    required init(rootViewController: UIViewController,
                  vocabulary: String) {
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
        viewController.delegate = self
        viewModel = VocabularyViewModel(vocabulary: vocabulary)
        let vc = VocabularyViewController()
        handleAction(vc)
        vc.bind(viewModel)
        viewController.pop(viewController: vc)
        present(viewController: viewController)
    }
    
    override func stop() {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
        super.stop()
    }
    
    private func handleAction(_ vc: VocabularyViewController) {
        vc.action.subscribe(onNext: { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .dismiss:
                self.stop()
                self.action.accept(.dismiss)
            case .saved:
                self.dismissAnimation()
                self.action.accept(.saved)
            }
        }).disposed(by: disposeBag)
    }
    
    private func dismissAnimation() {
        guard let view = viewController.children.first?.view else {
            self.stop()
            return
        }
        guard let tabBar = rootViewController.tabBarController?.tabBar else {
            self.stop()
            return
        }
        
        let screenHeight = UIScreen.main.bounds.height
        let y = screenHeight - tabBar.bounds.height - 10
        // 共有三個 item 要取第一個的中心點
        let x = tabBar.bounds.width/3/2
        
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            view.frame.origin = CGPoint(x: x, y: y)
        }) { _ in
            self.stop()
        }
    }
}

extension CreateVocabularyCoordinator: PopupViewControllerDelegate {
    func tapBackground() {
        stop()
        self.action.accept(.dismiss)
    }
}

