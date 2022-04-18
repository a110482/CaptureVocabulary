//
//  Array+Ext.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/18.
//

import Foundation

extension Array {
    /// sort depend on distance with middle element
    /// e.x. let arr = [5, 3, 1, 2, 4, 6]
    /// result will be [1, 2, 3, 4, 5, 6]
    func sortedFromMiddle() -> Array<Element> {
        guard self.count > 0 else { return [] }
        guard self.count > 1 else { return self }
        
        var startIndex = self.count/2
        if self.count % 2 == 0 {
            startIndex -= 1
        }
        var newArray: Array<Element> = [self[startIndex]]
        var offSet = 1
        while newArray.count < self.count {
            if offSet > 0 {
                newArray.append(self[startIndex + offSet])
                offSet *= -1
            } else {
                newArray.append(self[startIndex + offSet])
                offSet *= -1
                offSet += 1
            }
        }
        return newArray
    }
}
