//
//  CaptureViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/16.
//

import UIKit
import SnapKit
import AVFoundation
import Vision
import RxCocoa
import RxSwift


class VisionCaptureViewController: UIViewController {
    enum Action {
        case identifyText(observations: [VNRecognizedTextObservation])
        case videoZoomFactorChanged(factor: CGFloat)
    }
    
    let action = PublishRelay<Action>()
    
    private let isScanActive = BehaviorRelay<Bool>(value: true)
    
    private let capturedImageView = UIImageView()
    
    private let cameraView = UIView()
    
    private let mask = UIView()
    
    private var captureSession: AVCaptureSession!
    
    private var videoOutput : AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
    private var previewLayer : AVCaptureVideoPreviewLayer!
    
    private let textRecognitionWorkQueue = DispatchQueue (label: "TextRecognitionQueue", qos: .userInteractive , attributes: [], autoreleaseFrequency: .workItem )
    
    private var textRecognitionRequest = VNRecognizeTextRequest (completionHandler: nil )
    
    private var isIdentifyingImage = false
    
    private var identifyImageCompletedTime = Date().timeIntervalSince1970
    
    private lazy var identifyArea: CGRect = {
        let width: CGFloat = cameraView.bounds.width * 0.8
        let height: CGFloat = 100
        return CGRect(origin: cameraView.center.offset(x: -width/2, y: -height/2),
                      size: CGSize(width: width, height: height))
    }()
    
    private let loadQueue = DispatchQueue(label: "loadQueue", qos: .userInteractive)
    
    private let disposeBag = DisposeBag()
    
    private var timer: DispatchSourceTimer? = nil
    
    private var device: AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInTelephotoCamera,
            .builtInWideAngleCamera,
        ]
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back)
        return session.devices.first
    }
    
    private var currentVideoZoomFactor: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVideoQueue()
        configUI()
        addPinchGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadQueue.async {
            self.captureSession.stopRunning()
        }
    }
    
    private var avInput: AVCaptureDeviceInput? {
        guard let device = self.device else {
            return nil
        }
        guard let avInput = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }
        return avInput
    }
    
    func setScanActiveState(isActive: Bool) {
        isScanActive.accept(isActive)
    }
    
    func startAutoFocus() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        timer?.setEventHandler(handler: {
            self.focusPoint()
        })
        timer?.activate()
    }
    
    func stopAutoFocus() {
        timer?.cancel()
    }
    
    func setCurrentVideoZoomFactor(factor: CGFloat) {
        currentVideoZoomFactor = factor
        zoom(videoZoomFactor: currentVideoZoomFactor)
    }

    private func recognizeTextInImage(_ image: UIImage, req: VNRecognizeTextRequest) {
        textRecognitionWorkQueue.async {
            guard let cgImage = image.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? requestHandler.perform([req])
        }
    }
    
    private func setTextRecognitionRequest() {
        textRecognitionRequest = VNRecognizeTextRequest { [weak self] (request, error)
            in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.action.accept(.identifyText(observations: observations))
                self.isIdentifyingImage = false
                self.identifyImageCompletedTime = Date().timeIntervalSince1970
            }
        }
        textRecognitionRequest.recognitionLevel = .fast
    }
    
    private func focusPoint() {
        do {
            let focusPoint = CGPoint(x: 0.5, y: 0.5)
            guard let device = self.device else {
                return
            }
            
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.autoFocus) {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }

            if device.isExposureModeSupported(.autoExpose) {
                device.exposurePointOfInterest = focusPoint
                // 曝光量调节
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {}
    }
}

// UI
private extension VisionCaptureViewController {
    func configUI() {
        view.addSubview(cameraView)
        cameraView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cameraView.layer.cornerRadius = 10
        cameraView.layer.masksToBounds = true
        #if block //DEBUG
        setPreviewImage()
        #endif
    }
    
    func makeMask() {
        isScanActive.subscribe(onNext: { [weak self] isScanActive in
            guard let self = self else { return }
            self.mask.layer.borderColor = (isScanActive ? UIColor.red : UIColor.gray).cgColor
        }).disposed(by: disposeBag)
        
        mask.layer.cornerRadius = 10
        mask.layer.masksToBounds = true
        mask.layer.borderWidth = 2
        mask.frame = identifyArea
        let plusImage = UIImage(systemName: "plus")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        let plus = UIImageView(image: plusImage)
        mask.addSubview(plus)
        plus.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        cameraView.addSubview(mask)
    }
    
    func croppedImage(image: UIImage) -> UIImage? {
        // 先調整長寬比
        let rate = cameraView.bounds.width/image.size.width
        let originY = (image.size.height - cameraView.bounds.height/rate)/2
        let rect = CGRect(origin: CGPoint(x: 0, y: originY),
                          size: CGSize(width: cameraView.bounds.width/rate, height: cameraView.bounds.height/rate))
        let image2 = image.cropped(to: rect)
        // 再調整至辨識範圍
        let rate2 = cameraView.bounds.width/image2.size.width
        let rect2 = CGRect(
            origin: CGPoint(x: identifyArea.origin.x/rate2,
                            y: identifyArea.origin.y/rate2),
            size: CGSize(width: identifyArea.width/rate2, height: identifyArea.height/rate2))
        
        let image3 = image2.cropped(to: rect2)
        return image3
    }
    
    func zoom(videoZoomFactor: CGFloat) {
        guard let device = self.device else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = videoZoomFactor
            device.unlockForConfiguration()
        } catch {}
    }

    #if DEBUG
    func setPreviewImage() {
        capturedImageView.layer.borderColor = UIColor.green.cgColor
        capturedImageView.layer.borderWidth = 2
        capturedImageView.backgroundColor = .gray
        capturedImageView.contentMode = .scaleAspectFit
        capturedImageView.alpha = 0.7
        capturedImageView.clipsToBounds = true
        view.addSubview(capturedImageView)
        capturedImageView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.snp.bottom)
        }
    }
    #endif
}

// video
private extension VisionCaptureViewController {
    // 設置專用線程處理影像
    func configVideoQueue() {
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        loadQueue.async {
            self.setupAndStartCaptureSession()
            DispatchQueue.global().async {
                self.setTextRecognitionRequest()
            }
        }
        
        loadQueue.async {
            self.setupInputAndOutput()
        }
        
        loadQueue.async {
            DispatchQueue.main.async {
                self.setupPreviewLayer()
                self.makeMask()
            }
        }
    }
    
    // 啟動鏡頭
    func setupInputAndOutput(){
        guard let avInput = avInput else {
            return
        }
        if captureSession.canAddInput(avInput) {
            captureSession.addInput(avInput)
        }
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    // 預覽
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.cameraView.layer.bounds
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func setupAndStartCaptureSession(){
        //init session
        self.captureSession = AVCaptureSession()
        //start configuration
        self.captureSession.beginConfiguration()
        
        //session specific configuration
        //before setting a session presets, we should check if the session supports it
        if self.captureSession.canSetSessionPreset(.photo) {
            self.captureSession.sessionPreset = .photo
        }
        self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        
        //commit configuration
        self.captureSession.commitConfiguration()
        //start running it
        self.captureSession.startRunning()
    }
    
    func addPinchGesture() {
        let pinch = UIPinchGestureRecognizer()
        cameraView.addGestureRecognizer(pinch)
        pinch.rx.event.subscribe(onNext: { [weak self] recognizer in
            guard let self = self else { return }
            guard let device = self.device else { return }
            switch recognizer.state {
            case .began:
                self.currentVideoZoomFactor = device.videoZoomFactor
            case .changed:
                let newFactor = self.currentVideoZoomFactor * recognizer.scale
                let factor = min(20, max(1, newFactor))
                self.zoom(videoZoomFactor: factor)
                self.action.accept(.videoZoomFactorChanged(factor: factor))
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
    func isAllowedNextImage() -> Bool {
        let now = Date().timeIntervalSince1970
        return !isIdentifyingImage &&
        (now - identifyImageCompletedTime) > 0.5
    }
}

extension VisionCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanActive.value else { return }
        guard isAllowedNextImage() else { return }
        connection.videoOrientation = .portrait
        isIdentifyingImage = true
        
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        let context = CIContext()
        guard let ref = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: ref)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let croppedImage = self.croppedImage(image: uiImage) else { return }
            self.capturedImageView.image = croppedImage
            self.setTextRecognitionRequest()
            self.recognizeTextInImage(croppedImage, req: self.textRecognitionRequest)
        }
    }
}

private prefix func - (right: CGPoint) -> CGPoint {
    return CGPoint(x: -right.x, y: -right.y)
}

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x,
                       y: self.y + y)
    }
}

extension UIView {
    var image: UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image
    }
}
