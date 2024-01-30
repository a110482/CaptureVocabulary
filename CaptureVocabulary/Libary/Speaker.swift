//
//  Speaker.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/11.
//

import AVFoundation

fileprivate let synth = AVSpeechSynthesizer()

protocol SpeakerDelegate: AnyObject {
    func sequencesDidFinish()
    func sequencesDidInterrupt()
}

class Speaker: NSObject {
    static let shared = Speaker()
    
    weak var delegate: SpeakerDelegate?
    
    private override init() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory (
            AVAudioSession.Category.playback,
            options: AVAudioSession.CategoryOptions.duckOthers
        )
        synth.delegate = speakerDelegate
    }
    
    enum Language: CustomStringConvertible {
        case en_US
        case zh_TW
        case pause(time: Int)
        
        var description: String {
            switch self {
            case .en_US:
                return "en-US"
            case .zh_TW:
                return "zh-TW"
            case .pause(_):
                return ""
            }
        }
    }
    
    private var sequences: [(string: String, language: Language)] = []
    
    
    /// speak immediate, it will clean speak sequences
    func speak(_ string: String, language: Language) {
        if case .pause(_) = language {
            return
        }
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: language.description)
        delegate?.sequencesDidInterrupt()
        sequences = []
        synth.stopSpeaking(at: .immediate)
        synth.speak(utterance)
    }
    
    func stop() {
        delegate?.sequencesDidInterrupt()
        sequences = []
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
            delegate?.sequencesDidFinish()
            isSpeaking = false
            return
        }
        let pack = sequences.removeFirst()
        
        // 暫停
        if case .pause(let time) = pack.language {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time), execute: {
                self.speakSequences()
            })
            return
        }
        
        // 發音
        let utterance = AVSpeechUtterance(string: pack.string)
//        #if DEBUG
//        // 可設定語速
//        utterance.rate = 0.1
//        utterance.postUtteranceDelay = 3
//        #endif
        utterance.voice = AVSpeechSynthesisVoice(language: pack.language.description)
        synth.pauseSpeaking(at: .immediate)
        synth.speak(utterance)
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
fileprivate class SpeakerSpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Speaker.shared.speakSequences()
    }
}

fileprivate let speakerDelegate = SpeakerSpeechSynthesizerDelegate()
