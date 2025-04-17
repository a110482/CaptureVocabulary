//
//  FuzzyEquatable.swift
//  sport-iOS
//
//  Created by ElijahTan on 2024/5/13.
//

import Foundation

/// 實現對 enum 的模糊比對
/// 例如:
/// enum MyEnum: FuzzyEquatable {
///     case example(val: Int)
/// }
/// let foo = MyEnum.example(val: 1)
/// let bar = MyEnum.example(val: 0)
/// foo == bar 不能直接比對
/// 透過 fuzzyEqual 會 return true 因為他只比對 enum 前面的 case
protocol FuzzyEquatable {
    static func fuzzyEqual(lhs: Self, rhs: Self) -> Bool
}

extension FuzzyEquatable {
    /// 實現對 enum 的模糊比對
    /// 例如:
    /// enum MyEnum: FuzzyEquatable {
    ///     case example(val: Int)
    /// }
    /// let foo = MyEnum.example(val: 1)
    /// let bar = MyEnum.example(val: 0)
    /// foo == bar 不能直接比對
    /// 透過 fuzzyEqual 會 return true 因為他只比對 enum 前面的 case
    static func fuzzyEqual(lhs: Self, rhs: Self) -> Bool {
        let lhsCaseKey = "\(lhs)".split(separator: "(").first
        let rhsCaseKey = "\(rhs)".split(separator: "(").first
        return lhsCaseKey == rhsCaseKey
    }
    
    /// 實現對 enum 的模糊比對
    /// 例如:
    /// enum MyEnum: FuzzyEquatable {
    ///     case example(val: Int)
    /// }
    /// let foo = MyEnum.example(val: 1)
    /// let bar = MyEnum.example(val: 0)
    /// foo == bar 不能直接比對
    /// 透過 fuzzyEqual 會 return true 因為他只比對 enum 前面的 case
    func fuzzyEqual(_ rhs: Self) -> Bool {
        let lhsCaseKey = "\(self)".split(separator: "(").first
        let rhsCaseKey = "\(rhs)".split(separator: "(").first
        return lhsCaseKey == rhsCaseKey
    }
}

extension Array where Element: FuzzyEquatable {
    /// 模糊比對 array 裡的物件
    func fuzzyContains(_ element: Element) -> Bool {
        return contains(where: { Element.fuzzyEqual(lhs: $0, rhs: element) })
    }
}
