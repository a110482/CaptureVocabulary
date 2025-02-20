//
//  Int+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/10/4.
//

import Foundation

/// 建立一個限制範圍的 Int
/// e.x. @LimitedInt(range: 0 ... 3) 表示範圍設定給他只會返回 0 ~ 3 的範圍
@propertyWrapper
struct LimitedInt {
    private var value: Int
    private let range: ClosedRange<Int>
    
    init(wrappedValue: Int, range: ClosedRange<Int>) {
        // 保存範圍
        self.range = range
        // 初始化值檢查範圍
        self.value = Self.set(value: wrappedValue, in: range)
    }
    
    var wrappedValue: Int {
        get { value }
        set {
            value = Self.set(value: newValue, in: range)
        }
    }
    
    static private func set(value: Int, in range: ClosedRange<Int>) -> Int {
        if value > range.upperBound {
            return range.upperBound
        } else if value < range.lowerBound {
            return range.lowerBound
        } else {
            return value
        }
    }
}
