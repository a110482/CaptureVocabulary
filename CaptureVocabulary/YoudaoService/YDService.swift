//
//  YDService.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/9/27.
//

import Foundation
import SwifterSwift


class YDService {
    static let shared = YDService()

    private init() {}
    
    func sing(query: String, uuid: String, time: String) -> String {
        let appKey = AppParameters.shared.model.YDAppKey
        let secret = AppParameters.shared.model.YDSecret
        let singStr = appKey + truncate(query) + uuid + time + secret
        return singStr.sha256()
    }
}

private extension YDService {
    func truncate(_ query: String) -> String {
        guard query.count > 20 else {
            return query
        }
        return String(query.prefix(10) + query.suffix(10))
    }
}
