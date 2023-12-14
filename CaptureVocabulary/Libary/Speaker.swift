//
//  Speaker.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/11.
//

import AVFoundation

fileprivate let synth = AVSpeechSynthesizer()

class Speaker: NSObject {
    static let shared = Speaker()
    
    private override init() {
        AVSpeechSynthesisVoice.speechVoices()
        synth.delegate = speakerDelegate
    }
    
    enum Language: String {
        case en_US = "en-US"
        case zh_TW = "zh-TW"
    }
    
    private var sequences: [(string: String, language: Language)] = []
    
    
    /// speak immediate, it will clean speak sequences
    func speak(_ string: String, language: Language) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        sequences = []
        synth.stopSpeaking(at: .immediate)
        synth.speak(utterance)
    }
    
    func stop() {
        synth.stopSpeaking(at: .immediate)
    }
    
    private(set) var isSpeaking = false
    
    func speakSequences(_ string: String, language: Language) {
        sequences.append((string, language))
        if !isSpeaking {
            speakSequences()
        }
    }
    
    fileprivate func speakSequences() {
        isSpeaking = true
        guard sequences.count > 0 else {
            isSpeaking = false
            return
        }
        let pack = sequences.removeFirst()
        let utterance = AVSpeechUtterance(string: pack.string)
//        #if DEBUG
//        // 可設定語速
//        utterance.rate = 0.1
//        utterance.postUtteranceDelay = 3
//        #endif
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

// MARK: - SpeakerDelegate
fileprivate class SpeakerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Speaker.shared.speakSequences()
    }
}

fileprivate let speakerDelegate = SpeakerDelegate()
