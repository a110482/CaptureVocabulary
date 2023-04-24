//
//  UIView+Ext.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/24.
//

import UIKit

extension UIView {
    var backgroundColorHex: String? {
        set {
            guard let str = newValue,
                let color = UIColor(hexString: str) else { return }
            backgroundColor = color
        }
        get {
            let color = backgroundColor
            return color?.hexString
        }
    }
}
