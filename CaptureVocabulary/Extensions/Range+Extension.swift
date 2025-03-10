//
//  Range+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import Foundation

extension ClosedRange where Bound: FloatingPoint {
    var average: Bound {
        return (lowerBound + upperBound) / 2
    }
}
