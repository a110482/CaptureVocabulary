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
        let normalizedString = regularMatches(for: "[a-z -]+", in: lowerCase).first
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
    func localized() -> String {
        if let cache = TranslateCache.getCache(key: self) {
            return cache
        }
        guard let converter = OpenCCConverter.shared.converter else { return self }
        let res = converter.convert(self)
        TranslateCache.setCache(key: self, value: res)
        return res
    }
    
    func localized() async -> String {
        return await withCheckedContinuation({ result in
            Task {
                if let cache = TranslateCache.getCache(key: self) {
                    result.resume(returning: cache)
                    return
                }
                
                guard let converter = OpenCCConverter.shared.converter else { 
                    result.resume(returning: self)
                    return
                }
                let convertResult = converter.convert(self)
                TranslateCache.setCache(key: self, value: convertResult)
                result.resume(returning: convertResult)
            }
        })
    }
}

fileprivate actor TranslateCache {
    private static var cache = NSCache<NSString, NSString>()
    
    static func setCache(key: String, value: String) {
        guard key.count < 30 else { return }
        cache.setObject(value.nsString, forKey: key.nsString)
    }
    
    static func getCache(key: String) -> String? {
        guard key.count < 30 else { return nil }
        return cache.object(forKey: key.nsString) as String?
    }
}
