//
//  UIInsetLabel.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/3/6.
//

import UIKit

class UIInsetLabel: UILabel {
    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
