//
//  Array+Extension.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/3.
//

import Foundation

extension Array {
    mutating func inoutForEach(_ body: (inout Element) -> Void) {
        for index in indices {
            body(&self[index])
        }
    }
}
