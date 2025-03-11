//
//  String+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/3/4.
//

import Foundation
import SwiftUI
import SwifterSwift

extension String {
    var uicolor: UIColor {
        guard let color = UIColor(hexString: self) else {
            assertionFailure()
            return .clear
        }
        return color
    }
    
    var color: Color {
        return Color(uiColor: self.uicolor)
    }
}
