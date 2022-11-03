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
        let identifyWord = BehaviorRelay<RecognizedItem?>(value: nil)
    }
    let output = Output()
    
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        guard observations.count > 0 else { return }
        let identifyWord = refineObservations(observations)
        DispatchQueue.main.async {
            self.output.identifyWord.accept(identifyWord)
        }
    }
}

struct RecognizedItem {
    let word: String
    let observation: VNRectangleObservation
}

private extension CaptureVocabularyViewModel {
    var scanCanter: CGRect {
        let pointSize: Double = 0.04
        return CGRect(x: (1 - pointSize)/2, y: (1 - pointSize)/2, width: pointSize, height: pointSize)
    }
    
    func refineObservations(_ observations: [VNRecognizedTextObservation]) -> RecognizedItem? {
        guard let recognizedText = searchByContains(observations) else {
            return nil
        }
        
        let words = recognizedText.string.split{ $0.isWhitespace }.map{ String($0)}
        for word in words {
            guard word.count > 2 else { continue }
            if let wordRange = recognizedText.string.range(of: word),
               let observation = try? recognizedText.boundingBox(for: wordRange),
               let wordRect = try? recognizedText.boundingBox(for: wordRange)?.boundingBox{
                // 座標是位置的百分比, 原點是左下角, 所以最接近中心點的就是 (0.5, 0.5)
                if wordRect.intersects(scanCanter) {
                    return RecognizedItem(word: word, observation: observation)
                }
            }
        }
        return nil
    }
    
    func searchByContains(_ observations: [VNRecognizedTextObservation]) -> VNRecognizedText? {
        return observations.first(where: {
            $0.boundingBox.intersects(scanCanter)
        })?.topCandidates(1).first
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
        
        viewModel.output.identifyWord.subscribe(onNext: { [weak self] recognizedItem in
            guard let self = self else { return }
            self.removeMarking()
            guard let recognizedItem = recognizedItem else { return }
            self.queryStringTextField.text = recognizedItem.word
            self.drawMarking(recognizedItem.observation)
        }).disposed(by: disposeBag)
    }
    
    private func removeMarking() {
        capContainerView.layer.sublayers?.filter { $0.isKind(of: CAShapeLayer.self) }.forEach {
            $0.removeFromSuperlayer()
        }
    }
    
    private func drawMarking(_ observation: VNRectangleObservation) {
        let c = capContainerView
        let transform = CGAffineTransform.identity
            .scaledBy(x: 1, y: -1)
            .translatedBy(x: 0, y: -c.bounds.size.height)
            .scaledBy(x: c.bounds.size.width, y: c.bounds.size.height)
        
        
        let path = UIBezierPath()
        path.move(to: observation.topLeft.applying(transform))
        path.addLine(to: observation.topRight.applying(transform))
        path.addLine(to: observation.bottomRight.applying(transform))
        path.addLine(to: observation.bottomLeft.applying(transform))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.green.withAlphaComponent(0.3).cgColor
        c.layer.addSublayer(shapeLayer)
    }
    
    private func bindAction() {
        scanButton.rx.controlEvent(.touchDown).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.captureViewController.setScanActiveState(isActive: true)
            self.captureViewController.startAutoFocus()
        }).disposed(by: disposeBag)
        
        scanButton.rx.controlEvent([.touchUpInside, .touchUpOutside]).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.captureViewController.setScanActiveState(isActive: false)
            if let text = self.queryStringTextField.text, !text.isEmpty {
                self.action.accept(.selected(vocabulary: text))
            }
            self.captureViewController.stopAutoFocus()
            self.removeMarking()
        }).disposed(by: disposeBag)
        
        queryStringTextField.delegate = self
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
            mainStackView.padding(gap: 70),
            scanButton,
            UIView()
        ])
        
        addCaptureViewController()
        configQueryStringLabel()
        
        scanButton.snp.makeConstraints {
            $0.size.equalTo(150)
        }
        #if DEBUG
        queryStringTextField.alpha = 0.5
        #endif
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

extension CaptureVocabularyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if let text = self.queryStringTextField.text, !text.isEmpty {
            self.action.accept(.selected(vocabulary: text))
        }
        return true
    }
}
