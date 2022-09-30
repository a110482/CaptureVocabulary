//
//  YoudaoRequest.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/9/29.
//

import Foundation
import Moya


protocol YDRequest: Request {
    
}

extension YDRequest {
    var baseURL: URL { URL(string: "https://openapi.youdao.com/")! }
    
    var headers: [String : String]? { nil }
    
    var parameters: [String : Any] {
        [:]
    }
    
    var decisions: [Decision] { [StanderDecision()] }
}
