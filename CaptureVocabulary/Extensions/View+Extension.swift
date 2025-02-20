//
//  View+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/8/2.
//

import SwiftUI
import WidgetKit

extension View {
    /// 为视图添加小组件背景。
    ///
    /// 此方法根据系统版本为视图添加适当的背景。如果设备运行 iOS 17.0 或更高版本，
    /// 则使用 `containerBackground(for:)` 添加背景；否则使用 `background` 方法。
    ///
    /// - Parameter backgroundView: 要作为背景添加的视图。
    ///
    /// - Returns: 带有指定背景的视图。
    ///
    /// 示例:
    /// ```swift
    /// Text("Hello, World!")
    ///     .widgetBackground(Color.blue)
    /// ```
    ///
    /// - Note: 此方法使用了条件编译，因此需要在支持的 iOS 版本上测试以确保背景行为正确。
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
