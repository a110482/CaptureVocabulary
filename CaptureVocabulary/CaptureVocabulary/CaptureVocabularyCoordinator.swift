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
import Then

// MARK: - Coordinator
class CaptureVocabularyCoordinator: Coordinator<UIViewController> {
    var viewController: CaptureVocabularyViewController!
    var viewModel: CaptureVocabularyViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = CaptureVocabularyViewController()
        observeAction(viewController)
        viewModel = CaptureVocabularyViewModel()
        viewController.bind(viewModel: viewModel)
    }
    
    private func observeAction(_ viewController: CaptureVocabularyViewController) {
        viewController.action.subscribe(onNext: { [weak self] action in
            switch action {
            case .selected(let vocabulary):
                self?.presentCreateVocabularyCoordinator(vocabulary)
            }
        }).disposed(by: disposeBag)
    }
    
    private func presentCreateVocabularyCoordinator(_ vocabulary: String) {
        let coordinator = CreateVocabularyCoordinator(rootViewController: viewController, vocabulary: vocabulary)
        startChild(coordinator: coordinator)
    }
}

// MARK: - VM
class CaptureVocabularyViewModel {
    struct Output {
        let identifyWord = BehaviorRelay<String?>(value: nil)
    }
    let output = Output()
    
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        guard observations.count > 0 else { return }
        let words = refineObservations(observations)
        DispatchQueue.main.async {
            self.output.identifyWord.accept(words.first)
        }
    }
}

private extension CaptureVocabularyViewModel {
    func refineObservations(_ observations: [VNRecognizedTextObservation]) -> [String] {
        // 改由圖片位置靠近中央處優先
        var refinedAlternateWords: [(word: String, distance: CGFloat)] = []
        
        for lineObservation in observations {
            if refinedAlternateWords.count >= 5 {
                return refinedAlternateWords.map { $0.word }
            }
            guard let textLine = lineObservation.topCandidates(1).first else { continue }
            let words = textLine.string.split{ $0.isWhitespace }.map{ String($0)}
            for word in words {
                guard word.count > 2 else { continue }
                if let wordRange = textLine.string.range(of: word),
                   let wordRect = try? textLine.boundingBox(for: wordRange)?.boundingBox{
                    // 座標是位置的百分比, 原點是左下角, 所以最接近中心點的就是 (0.5, 0.5)
                    let absoluteCenter = CGPoint(x: 0.5, y: 0.5)
                    let distance = absoluteCenter.distance(from: wordRect.center)
                    refinedAlternateWords.append((word: word, distance: distance))
                    refinedAlternateWords.sort(by: { $0.distance < $1.distance })
                    refinedAlternateWords = Array(refinedAlternateWords.prefix(5))
                }
            }
        }
        return refinedAlternateWords.map { $0.0 }
    }
}

// MARK: - VC
class CaptureVocabularyViewController: UIViewController {
    enum Action {
        case selected(vocabulary: String)
    }
    let action = PublishRelay<Action>()
    
    let captureViewController = VisionCaptureViewController()
    let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
    }
    let capContainerView = UIView()
    #warning("text delegate")
    let queryStringTextField = UITextField().then {
        $0.textAlignment = .center
        $0.backgroundColor = .lightGray
    }
    let scanButton = UIButton().then {
        $0.setTitle("scan", for: .normal)
        $0.backgroundColor = .gray
    }
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindAction()
        #if block//DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.action.accept(.selected(vocabulary: "shift"))
        }
        #endif
    }
    
    func bind(viewModel: CaptureVocabularyViewModel) {
        captureViewController.action.subscribe(onNext: { [weak viewModel] act in
            switch act {
            case .identifyText(let observations):
                viewModel?.handleObservations(observations)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output.identifyWord.subscribe(onNext: { [weak self] word in
            guard let self = self else { return }
            self.queryStringTextField.text = word
        }).disposed(by: disposeBag)
    }
    
    func bindAction() {
        scanButton.rx.controlEvent(.touchDown).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.captureViewController.setScanActiveState(isActive: true)
        }).disposed(by: disposeBag)
        
        scanButton.rx.controlEvent([.touchUpInside, .touchUpOutside]).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.captureViewController.setScanActiveState(isActive: false)
            if let text = self.queryStringTextField.text {
                self.action.accept(.selected(vocabulary: text))
            }
        }).disposed(by: disposeBag)
    }
}

// UI
extension CaptureVocabularyViewController {
    func configUI() {
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mainStackView.addArrangedSubviews([
            capContainerView,
            queryStringTextField,
            mainStackView.padding(gap: 30),
            scanButton,
            UIView()
        ])
        
        addCaptureViewController()
        configQueryStringLabel()
        
        scanButton.snp.makeConstraints {
            $0.size.equalTo(50)
        }
    }
    
    func addCaptureViewController() {
        capContainerView.snp.makeConstraints {
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(300)
        }
        
        addChildViewController(captureViewController, toContainerView: capContainerView)
        captureViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    func configQueryStringLabel() {
        queryStringTextField.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
}
