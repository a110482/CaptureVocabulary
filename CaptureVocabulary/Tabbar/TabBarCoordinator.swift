//
//  TabBarCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/8.
//

import UIKit
import SnapKit
import SwifterSwift
import RxCocoa
import RxSwift


class TabBarCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: TabBarViewController!
    
    override func start() {
        guard !started else { return }
        viewController = TabBarViewController()
        viewController.viewControllers = [
            vocabularyList(),
            DemoViewController(),
            captureVocabulary(),
        ]
        super.start()
        present(viewController: viewController, animated: false)
    }
    
    private func captureVocabulary() -> UIViewController {
        let coordinator = CaptureVocabularyCoordinator(rootViewController: viewController)
        startChild(coordinator: coordinator)
        coordinator.viewController.tabBarItem = UITabBarItem(
            title: "捕捉".localized(),
            image: UIImage(systemName: "camera.on.rectangle"),
            tag: 2)
        return coordinator.viewController
    }
    
    private func vocabularyList() -> UIViewController {
        let coordinator = VocabularyListCoordinator(rootViewController: viewController)
        startChild(coordinator: coordinator)
        coordinator.viewController.tabBarItem = UITabBarItem(
            title: "單字卡".localized(),
            image: UIImage(systemName: "list.bullet.indent"),
            tag: 0)
        return coordinator.viewController
    }
}


// MARK: -
class TabBarViewController: UITabBarController {
    override var shouldAutorotate: Bool { false } 
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        tabBar.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - Demo
class DemoViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 100)
        view.backgroundColor = .random
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
