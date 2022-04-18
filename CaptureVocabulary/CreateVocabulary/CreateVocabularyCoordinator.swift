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
    struct Output {
        let identifyWords = BehaviorRelay<[String]>(value: [])
    }
    let output = Output()
    
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        guard observations.count > 0 else { return }
        let words = refineObservations(observations)
        output.identifyWords.accept(words)
    }
    
}

private extension CreateVocabularyViewModel {
    func refineObservations(_ observations: [VNRecognizedTextObservation]) -> [String] {
        var words = observations.compactMap { $0.topCandidates(1).first?.string }
        words = words.flatMap { $0.components(separatedBy: " ")}
        words = words.filter { $0.count > 2 }
        words = words.sortedFromMiddle()
        return words
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
