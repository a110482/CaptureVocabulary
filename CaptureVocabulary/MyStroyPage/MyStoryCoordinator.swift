//
//  MyStoryCoordinator.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/12/31.
//

import Foundation
import RxSwift
import RxCocoa

class MyStoryCoordinator: Coordinator<UIViewController> {
    private(set) var viewController: MyStoryViewController!
    private(set) var viewModel: MyStoryViewModel!
    private let disposeBag = DisposeBag()
    
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = MyStoryViewController()
        viewModel = MyStoryViewModel()
        viewController.bind(viewModel: viewModel)
        
    }
}
