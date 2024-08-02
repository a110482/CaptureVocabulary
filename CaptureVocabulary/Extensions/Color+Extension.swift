//
//  Color+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/8/2.
//

import SwiftUI

extension Color {
    /// 初始化方法，通过十六进制字符串创建一个颜色。
    ///
    /// 这个初始化方法将接受一个表示颜色的十六进制字符串，并将其转换为 `Color` 实例。
    ///
    /// - Parameter hex: 一个表示颜色的六位或八位十六进制字符串（例如，`"#RRGGBB"` 或 `"#RRGGBBAA"`）。支持前缀 `#`。
    ///
    /// 示例:
    /// ```swift
    /// let color = Color(hex: "#FF5733")
    /// ```
    ///
    /// - Note: 如果提供的字符串格式不正确或值超出范围，颜色可能无法正确初始化。
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
