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
        let identifyWord = BehaviorRelay<RecognizedItem?>(value: nil)
    }
    let output = Output()
    
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        guard observations.count > 0 else {
            output.identifyWord.accept(nil)
            return
        }
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
