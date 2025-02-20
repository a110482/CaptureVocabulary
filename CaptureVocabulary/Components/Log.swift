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
    static func print(_ items: Any..., filePath: String = #file, line: Int = #line) {
        let fileName = filePath.split(separator: "/").last ?? ""
        Swift.print("\(fileName):\(line) >>>>", terminator: " ")
        items.forEach { item in
            Swift.print(item, terminator: " ")
        }
        Swift.print("")
    }
}
