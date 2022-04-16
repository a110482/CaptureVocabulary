//
//  ViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/13.
//

import UIKit
import SnapKit
import SwifterSwift
import VisionKit
import Vision


class ViewController: UIViewController {
//    let scannerViewController = VNDocumentCameraViewController()
//    var textRecognitionRequest =  VNRecognizeTextRequest (completionHandler: nil )
//    let textRecognitionWorkQueue =  DispatchQueue (label: "TextRecognitionQueue", qos: .userInitiated , attributes: [], autoreleaseFrequency: .workItem )

    let cap = CaptureViewController()
    let capContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view
        view.addSubview(capContainerView)
        capContainerView.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.height.equalTo(300)
        }
        
        addChildViewController(cap, toContainerView: capContainerView)
        cap.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        view.backgroundColor = .gray
//        scannerViewController.delegate = self
//        setTextRecognitionRequest()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.present(self.scannerViewController, animated: true, completion: nil)
//        }
//    }
//
//    func setTextRecognitionRequest() {
//        textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//            var detectedText = ""
//            for observation in observations {
//                guard let topCandidate = observation.topCandidates(1).first else { return }
//                detectedText += topCandidate.string
//                detectedText += "\n"
//            }
//            print(detectedText)
//        }
//    }
//
//    private func recognizeTextInImage(_ image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        textRecognitionWorkQueue.async {
//            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//            do {
//                try requestHandler.perform([self.textRecognitionRequest])
//            } catch {
//                print(error)
//            }
//        }
//    }
}

//extension ViewController: VNDocumentCameraViewControllerDelegate {
//    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
//        for pageNumber in 0..<scan.pageCount {
//            let image = scan.imageOfPage(at: pageNumber)
//            recognizeTextInImage(image)
//        }
//    }
//
//    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
//
//    }
//}
