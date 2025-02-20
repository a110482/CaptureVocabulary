//
//  UserDefaultUtility.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/5/15.
//

import Foundation

extension UserDefaults {
    
    struct Key<T>: RawRepresentable {
        typealias RawValue = String
        
        var rawValue: Key.RawValue
        
        init(rawValue: Key.RawValue) {
            self.rawValue = rawValue
        }
    }
    
    subscript<T> (key: Key<T>) -> T? where T: Codable {
        get { codAble(forKey: key.rawValue, type: T.self) }
        set { setCodAble(newValue, forKey: key.rawValue)}
    }
    
    func codAble<T>(forKey key: String, type: T.Type) -> T? where T: Codable {
        guard let data = data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func setCodAble<T>(_ value: T?, forKey key: String) where T: Codable {
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: key)
    }
}


