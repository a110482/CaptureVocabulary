//
//  Log.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/13.
//

import Foundation
import Log

// 設定
let Log = Logger()

class Debug {
    static func print(_ items: Any...) {
        Swift.print(">>>", terminator: " ")
        Swift.print(items)
    }
}
