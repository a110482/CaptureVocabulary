//
//  VersionCheck.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/5/15.
//

import Moya

struct VersionCheckModel: Codable {
    let version: String?
}

struct VersionCheck: Request {
    typealias ResponseModel = VersionCheckModel
    
    var parameters: [String : Any] = [:]
    
    var decisions: [Decision] = [
        StanderDecision()
    ]
    
    var path: String = ""
    
    var method: Moya.Method = .get
    
    var headers: [String : String]? = nil
    
    var baseURL: URL = URL(string: AppParameters.shared.model.versionUrl)!
    
    var task: Moya.Task {
        .requestPlain
    }
}
