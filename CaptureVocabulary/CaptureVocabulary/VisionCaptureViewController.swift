//
//  CaptureViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/16.
//

import UIKit
import SnapKit
import AVFoundation
import SwifterSwift
import Vision
import RxCocoa
import RxSwift


class VisionCaptureViewController: UIViewController {
    enum Action {
        case identifyText(observations: [VNRecognizedTextObservation])
    }
    
    let action = PublishRelay<Action>()
    
    let capturedImageView = UIImageView()
    
    let cameraView = UIView()
    
    private let mask = UIView()
    
    var captureSession: AVCaptureSession!
    
    var videoOutput : AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    let textRecognitionWorkQueue =  DispatchQueue (label: "TextRecognitionQueue", qos: .userInitiated , attributes: [], autoreleaseFrequency: .workItem )
    
    var textRecognitionRequest =  VNRecognizeTextRequest (completionHandler: nil )
    
    var takePicture = false
    
    lazy var identifyArea: CGRect = {
        let width: CGFloat = cameraView.bounds.width * 0.8
        let height: CGFloat = 100
        return CGRect(origin: cameraView.center.offset(x: -width/2, y: -height/2),
                      size: CGSize(width: width, height: height))
    }()
    
    let loadQueue = DispatchQueue(label: "loadQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadQueue.async {
            self.setupInputAndOutput()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadQueue.async {
            self.dismissInputAndOutput()
        }
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
    
    private let avInput: AVCaptureDeviceInput? = {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return nil
        }
        guard let avInput = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }
        return avInput
    }()
    
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
    
    func dismissInputAndOutput() {
        guard let avInput = avInput else {
            return
        }
        captureSession.removeInput(avInput)
        captureSession.removeOutput(videoOutput)
    }
    
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = self.cameraView.layer.frame
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([self.textRecognitionRequest])
            } catch {
                print(error)
            }
        }
    }
    
    private func setTextRecognitionRequest() {
        textRecognitionRequest = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            self?.action.accept(.identifyText(observations: observations))
        }
    }
}

// UI
extension VisionCaptureViewController {
    func configUI() {
        view.addSubview(cameraView)
        cameraView.snp.makeConstraints { $0.edges.equalToSuperview() }
        #if DEBUG
        setPreviewImage()
        #endif
    }
    
    func makeMask() {
        mask.borderColor = .red
        mask.borderWidth = 2
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

    #if DEBUG
    func setPreviewImage() {
        capturedImageView.borderColor = .green
        capturedImageView.borderWidth = 2
        capturedImageView.backgroundColor = .gray
        capturedImageView.contentMode = .scaleAspectFit
        capturedImageView.clipsToBounds = true
        view.addSubview(capturedImageView)
        capturedImageView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    #endif
}

extension VisionCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !takePicture else { return }
        connection.videoOrientation = .portrait
        takePicture = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.takePicture = false
        }
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
            self.recognizeTextInImage(croppedImage)
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
