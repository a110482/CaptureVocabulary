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
    
    private let captureViewController = VisionCaptureViewController()
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
    }
    private let capContainerView = UIView()
    private let queryStringStackView = UIStackView()
    private let queryStringButtonLine = UIView()
    private let queryStringTextField = UITextField()
    private let queryButton = UIButton()
    private let versionLabel = UILabel().then {
        let appVersion = AppInfo.versino
        $0.text = "ver: \(appVersion)"
        $0.backgroundColor = .gray
        $0.isHidden = true
    }
    
    private let shapeLayer = CAShapeLayer()
    
    
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
            self.drawMarking(recognizedItem?.observation)
            guard let recognizedItem = recognizedItem else { return }
            guard !self.queryStringTextField.isFirstResponder else { return }
            self.queryStringTextField.text = recognizedItem.word
            self.updateQueryStringButtonLineColor()
        }).disposed(by: disposeBag)
    }

    /// 標示掃描到的文字區域
    private func drawMarking(_ observation: VNRectangleObservation?) {
        guard let observation = observation else {
            shapeLayer.removeFromSuperlayer()
            return
        }

        let transform = CGAffineTransform.identity
            .scaledBy(x: 1, y: -1)
            .translatedBy(x: 0, y: -capContainerView.bounds.size.height)
            .scaledBy(x: capContainerView.bounds.size.width, y: capContainerView.bounds.size.height)
        
        let offsetDistance = CGFloat(5)
        let path = UIBezierPath()
        path.move(to: observation.bottomRight
            .applying(transform).offset(x: -offsetDistance, y: -offsetDistance))
        path.addLine(to: observation.bottomLeft
            .applying(transform).offset(x: offsetDistance, y: -offsetDistance))
        path.addLine(to: observation.topLeft
            .applying(transform).offset(x: offsetDistance, y: offsetDistance))
        path.addLine(to: observation.topRight
            .applying(transform).offset(x: -offsetDistance, y: offsetDistance))
        
        path.close()
        
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.green.withAlphaComponent(0.3).cgColor
        capContainerView.layer.addSublayer(shapeLayer)
    }
    
    private func bindAction() {
        captureViewController.startAutoFocus()
        
        queryButton.rx.controlEvent([.touchUpInside, .touchUpOutside]).subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if let text = self.queryStringTextField.text, !text.isEmpty {
                self.action.accept(.selected(vocabulary: text))
            }
        }).disposed(by: disposeBag)
        
        queryStringTextField.delegate = self
    }
    
    func setScanActiveState(isActive: Bool) {
        captureViewController.setScanActiveState(isActive: isActive)
    }
}

// UI
extension CaptureVocabularyViewController {
    func configUI() {
        view.backgroundColor = .white
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.left.right.equalToSuperview()
        }
        
        mainStackView.addArrangedSubviews([
            capContainerView,
            mainStackView.padding(gap: 20),
            queryStringStackView,
            queryStringButtonLine,
            UIView(),
            queryButton,
            mainStackView.padding(gap: 20),
            versionLabel,
            mainStackView.padding(gap: 30)
        ])
        
        addCaptureViewController()
        configQueryStringStackView()
        configQueryButton()
        
        queryButton.snp.makeConstraints {
            $0.width.equalTo(150)
            $0.height.equalTo(60)
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
    
    func configQueryStringStackView() {
        queryStringStackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(40)
        }
        
        
        queryStringStackView.axis = .horizontal
        queryStringStackView.alignment = .bottom
        
        let textFiledImageView = UIImageView(image: UIImage(named: "textFiledPan"))
        textFiledImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        queryStringTextField.textAlignment = .center
        queryStringTextField.textColor = .black
        queryStringTextField.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        queryStringStackView.addArrangedSubviews([
            queryStringTextField, textFiledImageView
        ])
        
        Task {
            queryStringTextField.placeholder = await "輸入查詢".localized()
        }
        
        // 底線
        queryStringButtonLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.width.equalTo(queryStringStackView.snp.width)
        }
        updateQueryStringButtonLineColor()
    }
    
    func configQueryButton() {
        Task {
            let title = await "查詢".localized()
            queryButton.setTitle(title, for: .normal)
        }
        
        queryButton.hexColorString = "3D5CFF"
        queryButton.cornerRadius = 5
    }
    
    /// 查詢欄位的底線顏色
    func updateQueryStringButtonLineColor() {
        let colorString: String
        if let text = queryStringTextField.text, !text.isEmpty {
            colorString = "#5669FF"
        } else {
            colorString = "#BDBDBD"
        }
        queryStringButtonLine.backgroundColor = UIColor(hexString: colorString)
    }
}

extension CaptureVocabularyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        queryStringTextField.resignFirstResponder()
        if let text = self.queryStringTextField.text, !text.isEmpty {
            self.action.accept(.selected(vocabulary: text))
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let closeGestureView = UIView()
        closeGestureView.backgroundColor = .clear
        view.addSubview(closeGestureView)
        closeGestureView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        let gesture = UITapGestureRecognizer()
        closeGestureView.addGestureRecognizer(gesture)
        gesture.rx.event.subscribe(onNext: { [weak self] event in
            guard let self = self else { return }
            guard event.state == .ended else { return }
            closeGestureView.removeFromSuperview()
            self.queryStringTextField.resignFirstResponder()
            
        }).disposed(by: disposeBag)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateQueryStringButtonLineColor()
    }
}
