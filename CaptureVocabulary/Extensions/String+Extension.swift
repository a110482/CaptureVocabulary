//
//  String+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/3/4.
//

import Foundation
import SwifterSwift

extension String {
    var color: UIColor {
        guard let color = UIColor(hexString: self) else {
            assertionFailure()
            return .clear
        }
        return color
    }
}
