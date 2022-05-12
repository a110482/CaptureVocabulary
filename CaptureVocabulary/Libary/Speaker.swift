//
//  Speaker.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/11.
//

import AVFoundation

class Speaker {
    enum Language: String {
        case en_US = "en-US"
        case zh_TW = "zh-TW"
    }
    private static let queue = DispatchQueue(label: "Speaker")
    private static let synth = AVSpeechSynthesizer()
    static func speak(_ string: String, language: Language) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        queue.async {
            synth.stopSpeaking(at: .immediate)
            synth.speak(utterance)
        }
    }
}
