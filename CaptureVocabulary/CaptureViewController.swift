//
//  CaptureViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/16.
//

import UIKit
import SnapKit
import AVFoundation

class CaptureViewController: UIViewController {
    var captureSession: AVCaptureSession!
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        setupAndStartCaptureSession()
        setupInputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPreviewLayer()
    }
    
    func setupAndStartCaptureSession(){
        DispatchQueue.global(qos: .userInitiated).async{
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
    }
    
    func setupInputs(){
            //get back camera
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                backCamera = device
            } else {
                //handle this appropriately for production purposes
                fatalError("no back camera")
            }
            
            //get front camera
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                frontCamera = device
            } else {
                fatalError("no front camera")
            }
            
            //now we need to create an input objects from our devices
            guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
                fatalError("could not create input device from back camera")
            }
            backInput = bInput
            if !captureSession.canAddInput(backInput) {
                fatalError("could not add back camera input to capture session")
            }
            
            guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
                fatalError("could not create input device from front camera")
            }
            frontInput = fInput
            if !captureSession.canAddInput(frontInput) {
                fatalError("could not add front camera input to capture session")
            }
            
            //connect back camera input to session
            captureSession.addInput(backInput)
        }
    
    func setupPreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.layer.frame
        previewLayer.videoGravity = .resizeAspectFill
    }
}
