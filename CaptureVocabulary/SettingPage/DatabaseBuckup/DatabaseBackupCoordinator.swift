//
//  DatabaseBackupCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/26.
//

import UIKit
import RxCocoa
import RxSwift

class DatabaseBackupCoordinator: Coordinator<UINavigationController> {
    private(set) var viewController: DatabaseBackupViewController!
    private(set) var viewModel: DatabaseBackupViewModel!
    private let disposeBag = DisposeBag()
    
    override func start() {
        super.start()
        viewController = DatabaseBackupViewController()
        viewController.title = NSLocalizedString("SettingPageViewController.cell.databaseBackup", comment: "備份資料庫")
        viewModel = DatabaseBackupViewModel()
        viewController.bind(viewModel: viewModel)
        show(viewController: viewController)
    }
}
