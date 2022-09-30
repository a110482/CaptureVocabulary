//
//  StringTranslateAPI.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/9/30.
//

import Foundation
import Moya

struct StringTranslateAPIQueryModel: Encodable {
    let q: String
    let from = "en"
    let to = "zh-CHS"
    let appKey = Self.key?.YDAppKey ?? ""
    let salt: String
    let signType = "v3"
    let curtime: String
    let sign: String
    
    static private let key: KeyPlistModel? = {
        PlistReader.read(fileName: "key", modelType: KeyPlistModel.self)
    }()
    init(queryString: String) {
        q = queryString
        let salt = UUID().uuidString
        self.salt = salt
        let time = String(Int(Date().timeIntervalSince1970))
        self.curtime = time
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
    
    let queryModel = StringTranslateAPIQueryModel(queryString: "hello")
    
    var task: Task {
        var multipartData = [MultipartFormData]()
        
        guard let dict = try? queryModel.asDictionary() else {
            return .uploadMultipart(multipartData)
        }
        
        for (key, value) in dict {
            if let data = (value as? String)?.data(using: .utf8) {
                let d = MultipartFormData(
                    provider: .data(data),
                    name: key)
                multipartData.append(d)
            }
        }
                     
        return .uploadMultipart(multipartData)
    }
}


struct StringTranslateAPIResponse: Codable {
    let dict: Dict
    let translation: [String]
    let query: String
    let webdict: Dict
    let basic: Basic
    let tSpeakURL: String
    let isWord: Bool
    let requestID, l, errorCode: String
    let web: [Web]
    let speakURL: String
    let returnPhrase: [String]

    enum CodingKeys: String, CodingKey {
        case dict, translation, query, webdict, basic
        case tSpeakURL = "tSpeakUrl"
        case isWord
        case requestID = "requestId"
        case l, errorCode, web
        case speakURL = "speakUrl"
        case returnPhrase
    }
}

// MARK: - Basic
struct Basic: Codable {
    let ukPhonetic: String
    let wfs: [WfElement]
    let ukSpeech, usSpeech: String
    let examType: [String]
    let usPhonetic, phonetic: String
    let explains: [String]

    enum CodingKeys: String, CodingKey {
        case ukPhonetic = "uk-phonetic"
        case wfs
        case ukSpeech = "uk-speech"
        case usSpeech = "us-speech"
        case examType = "exam_type"
        case usPhonetic = "us-phonetic"
        case phonetic, explains
    }
}

// MARK: - WfElement
struct WfElement: Codable {
    let wf: WfWf
}

// MARK: - WfWf
struct WfWf: Codable {
    let name, value: String
}

// MARK: - Dict
struct Dict: Codable {
    let url: String
}

// MARK: - Web
struct Web: Codable {
    let value: [String]
    let key: String
}
