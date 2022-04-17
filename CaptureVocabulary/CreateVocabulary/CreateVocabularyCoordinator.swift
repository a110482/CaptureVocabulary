//
//  CreateVocabularyCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/18.
//

import UIKit
import SnapKit
import SwifterSwift
import Vision
import RxCocoa
import RxSwift

// MARK: - Coordinator
class CreateVocabularyCoordinator: Coordinator<UIViewController> {
    var viewController: CreateVocabularyViewController!
    var viewModel: CreateVocabularyViewModel!
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = CreateVocabularyViewController()
        viewModel = CreateVocabularyViewModel()
        viewController.bind(viewModel: viewModel)
        present(viewController: viewController)
    }
}

// MARK: - VM
class CreateVocabularyViewModel {
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        #if DEBUG
        #endif
    }
    
}

// MARK: - VC
class CreateVocabularyViewController: UIViewController {
    let captureViewController = CaptureViewController()
    let capContainerView = UIView()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func bind(viewModel: CreateVocabularyViewModel) {
        captureViewController.action.subscribe(onNext: { [weak viewModel] act in
            switch act {
            case .identifyText(let observations):
                viewModel?.handleObservations(observations)
            }
        }).disposed(by: disposeBag)
    }
}

// UI
extension CreateVocabularyViewController {
    func configUI() {
        addCaptureViewController()
    }
    
    func addCaptureViewController() {
        view.addSubview(capContainerView)
        capContainerView.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.height.equalTo(300)
        }
        
        addChildViewController(captureViewController, toContainerView: capContainerView)
        captureViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
    }
}
