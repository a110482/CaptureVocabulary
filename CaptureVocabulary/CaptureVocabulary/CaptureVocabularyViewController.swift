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
import SwifterSwift


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
    private let queryStringTextField = QueryStringTextField()
    private let sliderStackView = UIStackView()
    private let slider = UISlider()
    private let queryButton = UIButton()
    private let versionLabel = UILabel().then {
        let appVersion = AppInfo.versino
        $0.text = "ver: \(appVersion)"
        $0.backgroundColor = .gray
        $0.isHidden = true
    }
    private var adBannerView = UIView()
    
    private let shapeLayer = CAShapeLayer()
    
    private weak var viewModel: CaptureVocabularyViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        bindAction()
        #if block //DEBUG
        //查詢單字
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.action.accept(.selected(vocabulary: "qqqqqqqqqqqq"))
        }
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AdsManager.shared.rootViewController = self
    }
    
    func bind(viewModel: CaptureVocabularyViewModel) {
        self.viewModel = viewModel
        captureViewController.action.subscribe(onNext: { [weak viewModel] act in
            switch act {
            case .identifyText(let observations):
                viewModel?.handleObservations(observations)
            case .videoZoomFactorChanged(let factor):
                self.slider.value = Float(factor)
            case .changeCameraSwitch(let isOn):
                self.viewModel.setUserEnableCamera(isOn)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output.identifyWord.drive(onNext: { [weak self] recognizedItem in
            guard let self = self else { return }
            self.drawMarking(recognizedItem?.observation)
            guard let recognizedItem = recognizedItem else { return }
            guard !self.queryStringTextField.isFirstResponder else { return }
            self.queryStringTextField.text = recognizedItem.word
            self.queryStringTextField.updateUnderLineColor()
        }).disposed(by: disposeBag)
        
        captureViewController.bind(
            isOtherProgressNeedBlockCamera:
                viewModel.output.isOtherProgressNeedBlockCamera
        )
        
        captureViewController.bind(isUserEnableCamera: viewModel.output.isUserEnableCamera)
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
            GAManager.select(item: .visionPageQueryButton)
        }).disposed(by: disposeBag)
        
        queryStringTextField.delegate = self
    }
    
    private func sendQuery() {
        if let text = self.queryStringTextField.text, !text.isEmpty {
            self.action.accept(.selected(vocabulary: text))
        }
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
            queryStringTextField,
            UIView(),
            sliderStackView,
            mainStackView.padding(gap: 30),
            queryButton,
            mainStackView.padding(gap: 20),
            versionLabel,
            mainStackView.padding(gap: 30),
            adBannerView,
        ])
        
        addCaptureViewController()
        configQueryStringTextField()
        configSlider()
        configQueryButton()
        configAdView()
        
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
    
    func configQueryStringTextField() {
        queryStringTextField.delegate = self
        queryStringTextField.textAlignment = .center
        queryStringTextField.textColor = .black
        queryStringTextField.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalToSuperview().multipliedBy(0.7)
        }
        
        queryStringTextField.placeholder = NSLocalizedString("CaptureVocabularyViewController.enterQuery", comment: "輸入查詢")
        
    }
    
    func configSlider() {
        let zoomIn = UIImageView(image: UIImage(systemName: "plus.magnifyingglass"))
        let zoomOut = UIImageView(image: UIImage(systemName: "minus.magnifyingglass"))
        sliderStackView.axis = .horizontal
        sliderStackView.alignment = .center
        sliderStackView.addArrangedSubviews([
            zoomOut,
            sliderStackView.padding(gap: 5),
            slider,
            sliderStackView.padding(gap: 5),
            zoomIn
        ])
        
        [zoomIn, zoomOut].forEach { icon in
            icon.snp.makeConstraints { make in
                make.size.equalTo(20)
            }
            icon.tintColor = .lightGray
        }
        
        slider.minimumValue = 1
        slider.maximumValue = 15
        slider.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(view).multipliedBy(0.6)
        }
        
        slider.rx.value.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            let cgFloat = value.cgFloat
            self.captureViewController.setCurrentVideoZoomFactor(factor: cgFloat)
        }).disposed(by: disposeBag)
        
    }
    
    func configQueryButton() {
        let title = NSLocalizedString("CaptureVocabularyViewController.search", comment: "查詢")
        queryButton.setTitle(title, for: .normal)
        
        queryButton.backgroundColorHex = "3D5CFF"
        queryButton.layer.cornerRadius = 5
        queryButton.layer.masksToBounds = true
    }
    
    func configAdView() {
        let height = AdsManager.shared.adSize.size.height
        adBannerView.snp.makeConstraints {
            $0.height.equalTo(height)
            $0.width.equalToSuperview()
        }
    }
}

extension CaptureVocabularyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeBackgroundCloseView()
        queryStringTextField.resignFirstResponder()
        sendQuery()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        addBackgroundCloseView(
            textField,
            disposeBag: disposeBag)
        return true
    }
}

// google ad
extension CaptureVocabularyViewController: AdSimpleBannerPowered {
    var placeholder: UIView? {
        adBannerView
    }
}
