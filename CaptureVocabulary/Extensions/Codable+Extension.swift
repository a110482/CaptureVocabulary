//
//  Codable+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/24.
//

import Foundation


extension Encodable {
    /// 輸出成 json 格式的純文字
    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // 可選，讓 JSON 格式更易讀
        do {
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            assertionFailure("error: \(error)")
            return nil
        }
    }
}
