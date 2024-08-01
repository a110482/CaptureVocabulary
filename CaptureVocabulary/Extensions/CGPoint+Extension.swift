//
//  CGPoint+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/8/1.
//

import Foundation

extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x,
                       y: self.y + y)
    }
}
