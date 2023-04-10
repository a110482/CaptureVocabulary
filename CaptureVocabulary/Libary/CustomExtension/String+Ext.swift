//
//  String+Ext.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/1.
//

import Foundation
import OpenCC

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
    
    var normalized: String {
        let lowerCase = self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedString = regularMatches(for: "[a-z ]+", in: lowerCase).first
        return normalizedString ?? self
    }
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
    
    ///轉半形
    var halfWidth: String {
        transformFullWidthToHalfWidth(reverse: false)
    }
 
    ///轉全型
    var fullWidth: String {
        transformFullWidthToHalfWidth(reverse: true)
    }
 
    private func transformFullWidthToHalfWidth(reverse: Bool) -> String {
        let string = NSMutableString(string: self) as CFMutableString
        CFStringTransform(string, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return string as String
    }
}

// MARK: - 繁簡互換

extension String {
    #warning("製作緩存, 解決翻譯速度太慢")
    func localized() -> String {
        let preferredLanguages = Locale.preferredLanguages
        let hantIndex = preferredLanguages.firstIndex(where: { $0.contains("zh-Hant")})
        let hansIndex = preferredLanguages.firstIndex(where: { $0.contains("zh-Hans")})
        if hantIndex == nil && hansIndex == nil { return self }
        
        let converter: ChineseConverter
        if (hantIndex ?? Int.max) < (hansIndex ?? Int.max) {
            converter = try! ChineseConverter(options: [.traditionalize, .twStandard, .twIdiom])
        } else {
            converter = try! ChineseConverter(options: [.simplify, .twStandard, .twIdiom])
        }
        let res = converter.convert(self)
        return res
    }
    
    #warning("製作緩存, 解決翻譯速度太慢")
    func localized() async -> String {
        return await withCheckedContinuation({ result in
            Task {
                let preferredLanguages = Locale.preferredLanguages
                let hantIndex = preferredLanguages.firstIndex(where: { $0.contains("zh-Hant")})
                let hansIndex = preferredLanguages.firstIndex(where: { $0.contains("zh-Hans")})
                if hantIndex == nil && hansIndex == nil {
                    result.resume(returning: self)
                    return
                }
                let converter: ChineseConverter?
                if (hantIndex ?? Int.max) < (hansIndex ?? Int.max) {
                    converter = try? ChineseConverter(options: [.traditionalize, .twStandard, .twIdiom])
                } else {
                    converter = try? ChineseConverter(options: [.simplify, .twStandard, .twIdiom])
                }
                guard let converter = converter else { return }
                result.resume(returning: converter.convert(self))
            }
        })
    }
}
