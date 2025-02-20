//
//  CaptureVocabularyViewModel.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/11/3.
//

import RxCocoa
import RxSwift
import Vision

class CaptureVocabularyViewModel {
    struct Output {
        var identifyWord: Driver<RecognizedItem?> { model.identifyWord.asDriver() }
        var isUserEnableCamera: Driver<Bool> { model.isUserEnableCamera.asDriver() }
        var isOtherProgressNeedBlockCamera: Driver<Bool> { model.isOtherProgressNeedBlockCamera.asDriver() }
        
        private weak var model: CaptureVocabularyViewModel!
        init(_ model: CaptureVocabularyViewModel!) {
            self.model = model
        }
    }
    private(set) lazy var output = Output(self)
    
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        guard observations.count > 0 else {
            identifyWord.accept(nil)
            return
        }
        let identifyWord = refineObservations(observations)
        DispatchQueue.main.async {
            self.identifyWord.accept(identifyWord)
        }
    }
    
    func setOtherProgressNeedBlockCamera(_ isNeed: Bool) {
        isOtherProgressNeedBlockCamera.accept(isNeed)
    }
    
    func setUserEnableCamera(_ isEnable: Bool) {
        isUserEnableCamera.accept(isEnable)
        UserDefaults.standard[UserDefaultsKeys.isUserEnableCamera] = isEnable
    }
    
    private let identifyWord = BehaviorRelay<RecognizedItem?>(value: nil)
    private let isCameraUseable = BehaviorRelay<Bool>(value: true)
    /// 用戶是否允許使用相機
    private let isUserEnableCamera = BehaviorRelay<Bool>(value: UserDefaults.standard[UserDefaultsKeys.isUserEnableCamera] ?? true)
    /// 程序是否需要阻擋相機使用
    private var isOtherProgressNeedBlockCamera = BehaviorRelay<Bool>(value: false)
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
