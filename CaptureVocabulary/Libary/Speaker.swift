//
//  Speaker.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/11.
//

import AVFoundation

class Speaker: NSObject {
    private override init() {}
    
    enum Language: String {
        case en_US = "en-US"
        case zh_TW = "zh-TW"
    }
    
    private static var sequences: [(string: String, language: Language)] = []

    private static let synth = AVSpeechSynthesizer()
    
    static func speak(_ string: String, language: Language) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        sequences = []
        synth.stopSpeaking(at: .immediate)
        synth.speak(utterance)
    }
    
    private(set) static var isSpeaking = false
    
    static func speakSequences(_ string: String, language: Language) {
        sequences.append((string, language))
        if !isSpeaking {
            speakSequences()
        }
    }
    
    fileprivate static func speakSequences() {
        synth.delegate = speakerDelegate
        isSpeaking = true
        guard sequences.count > 0 else {
            isSpeaking = false
            return
        }
        let pack = sequences.removeFirst()
        let utterance = AVSpeechUtterance(string: pack.string)
        #if DEBUG
        utterance.rate = 0.1
        utterance.postUtteranceDelay = 3
        #endif
        utterance.voice = AVSpeechSynthesisVoice(language: pack.language.rawValue)
        synth.pauseSpeaking(at: .immediate)
        synth.speak(utterance)
        print(#line, Date())
    }
    
    // call in app delegate
    static func setAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            assert(false)
        }
    }
}

private class SpeakerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Speaker.speakSequences()
        print(#line, Date())
    }
}

private let speakerDelegate = SpeakerDelegate()
