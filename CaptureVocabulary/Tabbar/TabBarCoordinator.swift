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
            review(),
            captureVocabulary(),
        ]
        super.start()
        present(viewController: viewController, animated: false)
        #if block//DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.viewController.selectedIndex = 2
        }
        #endif
    }
    
    private func captureVocabulary() -> UIViewController {
        let coordinator = CaptureVocabularyCoordinator(rootViewController: viewController)
        startChild(coordinator: coordinator)
        coordinator.viewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("TabBarCoordinator.capture", comment: "捕捉"),
            image: UIImage(systemName: "camera.on.rectangle"),
            tag: 2)
        return coordinator.viewController
    }
    
    private func review() -> UIViewController {
        let coordinator = ReviewCoordinator(rootViewController: viewController)
        startChild(coordinator: coordinator)
        coordinator.viewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("TabBarCoordinator.review", comment: "複習"),
            image: UIImage(systemName: "doc.text"),
            tag: 1)
        return coordinator.viewController
    }
    
    private func vocabularyList() -> UIViewController {
        let coordinator = VocabularyListCoordinator(rootViewController: viewController)
        startChild(coordinator: coordinator)
        coordinator.viewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("TabBarCoordinator.flashcards", comment: "單字卡"),
            image: UIImage(systemName: "list.bullet.indent"),
            tag: 0)
        return coordinator.viewController
    }
}


// MARK: -
class TabBarViewController: UITabBarController {
    override var shouldAutorotate: Bool { false }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedIndex = 1
    }
    
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
