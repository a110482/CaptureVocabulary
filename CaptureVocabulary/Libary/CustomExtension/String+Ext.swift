//
//  String+Ext.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/1.
//

import Foundation

extension String {
    func regularMatches(for regex: String, in text: String? = nil) -> [String] {
        let text = text ?? self
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            let errMsg = "invalid regex: \(error.localizedDescription)"
            assert(false, errMsg)
            return []
        }
    }
    
    var normalized: String? {
        let lowerCase = self.lowercased()
        let normalizedString = regularMatches(for: "[a-z]+", in: lowerCase).first
        return normalizedString
    }
    
    
}
