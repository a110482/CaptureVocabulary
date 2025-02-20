//
//  StringTranslateAPI.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/9/30.
//

import Foundation
import Moya
import SQLite

// MARK: query model
struct YDTranslateAPIQueryModel: Encodable {
    let q: String
    let from = "en"
    let to = "zh-CHS"
    let appKey = AppParameters.shared.model.YDAppKey
    let salt: String
    let signType = "v3"
    let curtime: String
    let sign: String
    
    init(queryString: String) {
        q = queryString
        let salt = UUID().uuidString
        self.salt = salt
        let time = String(Int(Date().timeIntervalSince1970))
        self.curtime = time
        let sign = YDService.shared.sing(
            query: queryString,
            uuid: salt,
            time: time)
        self.sign = sign
    }
}

// MARK: api
struct YDTranslateAPI: YDRequest {
    typealias ResponseModel = StringTranslateAPIResponse
    
    var path: String = "api"
    
    var method: Moya.Method = .post
    
    let queryModel: YDTranslateAPIQueryModel
    
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

// MARK: response model
struct StringTranslateAPIResponse: Codable {
    let dict: Dict?
    let translation: [String]?
    let query: String?
    let webdict: Dict?
    let basic: Basic?
    let tSpeakURL: String?
    let isWord: Bool?
    let requestID, l, errorCode: String?
    let web: [Web]?
    let speakURL: String?
    let returnPhrase: [String]?

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

struct Basic: Codable {
    let ukPhonetic: String?
    let wfs: [WfElement]?
    let ukSpeech, usSpeech: String?
    let examType: [String]?
    let usPhonetic, phonetic: String?
    let explains: [String]?

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

struct WfElement: Codable {
    let wf: WfWf?
}

struct WfWf: Codable {
    let name, value: String?
}

struct Dict: Codable {
    let url: String?
}

struct Web: Codable {
    let value: [String]?
    let key: String?
}

// MARK: sql
extension StringTranslateAPIResponse: ORMTranslateAble {
    typealias ORMModel = YDTranslateORM
    
    func create(_ foreignKey: Int64?) {
        guard let query = query else { return }
        let data = try? JSONEncoder().encode(self)
        let orm =  ORMModel.ORM(query: query,
                                data: data)
        ORMModel.create(orm)
    }
}

extension StringTranslateAPIResponse {
    static func load(queryModel: YDTranslateAPIQueryModel) -> StringTranslateAPIResponse? {
        let queryString = queryModel.q.normalized
        let query = ORMModel.table.filter(ORMModel.query == queryString).limit(1)
        guard let orms = ORMModel.prepare(query) else { return nil }
        guard let dataObject = orms.first else { return nil }
        guard let data = dataObject.data else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
