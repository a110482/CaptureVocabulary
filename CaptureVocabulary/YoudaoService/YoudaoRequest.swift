//
//  YoudaoRequest.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/9/29.
//

import Foundation
import Moya


protocol YoudaoRequest: Request {
    
}

extension YoudaoRequest {
    var baseURL: URL { URL(string: "https://openapi.youdao.com/api/")! }
    
    var headers: [String : String]? { nil }
    
    var parameters: [String : Any] {
        [:]
    }
    
    var decisions: [Decision] { [StanderDecision()] }
}

// MARK: -
struct StringTranslateAPIQueryModel: Encodable {
    let q: String
    let from = "en"
    let to = "zh-CHT"
    let appKey = Self.key?.YDAppKey ?? ""
    let salt: String
    let signType = "v3"
    let curttime: String
    let sign: String
    
    static private let key: KeyPlistModel? = {
        PlistReader.read(fileName: "key", modelType: KeyPlistModel.self)
    }()
    init(queryString: String) {
        q = queryString
        let salt = UUID().uuidString
        self.salt = salt
        let time = String(Int(Date().timeIntervalSince1970))
        self.curttime = time
        let sign = YoudaoService.shared.sing(
            query: queryString,
            uuid: salt,
            time: time)
        self.sign = sign
    }
}


struct StringTranslateAPI: YoudaoRequest {
    typealias ResponseModel = EmptyResponse
    
    var path: String = "api"
    
    var method: Moya.Method = .post
    
    var task: Task {
        let queryModel = StringTranslateAPIQueryModel(queryString: "hello")
        let data = try! JSONEncoder().encode(queryModel)
        return .requestCompositeData(bodyData: data, urlParameters: parameters)
    }
}
