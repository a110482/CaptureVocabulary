//
//  OpenCCConverter.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/12/5.
//

import Foundation
import OpenCC

class OpenCCConverter {
    static let shared = OpenCCConverter()
    private(set) var converter: ChineseConverter? = nil
    
    private init() {
        changeLanguage()
    }
    
    func changeLanguage() {
        let preferredLanguages = Locale.preferredLanguages
        let hantIndex = preferredLanguages.firstIndex(where: { $0.contains("zh-Hant")})
        let hansIndex = preferredLanguages.firstIndex(where: { $0.contains("zh-Hans")})
        if hantIndex == nil && hansIndex == nil { return }
        
        if (hantIndex ?? Int.max) < (hansIndex ?? Int.max) {
            converter = try! ChineseConverter(options: [.traditionalize, .twStandard, .twIdiom])
        } else {
            converter = try! ChineseConverter(options: [.simplify, .twStandard, .twIdiom])
        }
    }
}
