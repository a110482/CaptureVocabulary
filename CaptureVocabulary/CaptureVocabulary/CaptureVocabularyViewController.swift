//
//  CaptureVocabularyViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/11/3.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Vision

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
    
    /// 標示掃描到的文字區域
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
        captureViewController.setScanActiveState(isActive: true)
        captureViewController.startAutoFocus()
        
//        scanButton.rx.controlEvent(.touchDown).subscribe(onNext: { [weak self] _ in
//            guard let self = self else { return }
//            self.captureViewController.setScanActiveState(isActive: true)
//            self.captureViewController.startAutoFocus()
//        }).disposed(by: disposeBag)
        
        scanButton.rx.controlEvent([.touchUpInside, .touchUpOutside]).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
//            self.captureViewController.setScanActiveState(isActive: false)
            if let text = self.queryStringTextField.text, !text.isEmpty {
                self.action.accept(.selected(vocabulary: text))
            }
//            self.captureViewController.stopAutoFocus()
//            self.removeMarking()
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
