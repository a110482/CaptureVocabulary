//
//  AppInfo.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/13.
//

import Foundation

class AppInfo {
    static var versino: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknow"
    }
    
    static var developers: [String] = [
        "Elijah Tan",
        "Joanna Chen",
        "Michelle Wu"
    ]
}
