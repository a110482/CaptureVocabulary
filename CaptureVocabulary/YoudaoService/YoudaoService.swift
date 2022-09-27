//
//  YoudaoService.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/9/27.
//

import Foundation
import SwifterSwift


class YoudaoService {
    static let shared = YoudaoService()
    let appKey: String
    private let secret: String
    
    private init() {
        let key = PlistReader.read(fileName: "key", modelType: KeyPlistModel.self)
        appKey = key?.YDAppKey ?? ""
        secret = key?.YDSecret ?? ""
        if key?.YDAppKey == nil || key?.YDSecret == nil {
            assert(false, "key.plist can not read value")
        }
    }
    
    func sing(query: String, uuid: String, time: String) -> String {
        let singStr = appKey + truncate(query) + uuid + time + secret
        return singStr.sha256()
    }
}

private extension YoudaoService {
    func truncate(_ query: String) -> String {
        guard query.count > 20 else {
            return query
        }
        return String(query.prefix(10) + query.suffix(10))
    }
}




