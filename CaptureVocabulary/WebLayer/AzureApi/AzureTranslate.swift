//
//  AzureTranslate.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/23.
//

import Foundation
import Moya

struct AzureTranslateModel: Codable {
    let translations: [Translation]?
    
    struct Translation: Codable {
        let to, text: String?
    }
}

struct AzureTranslate: AzureRequest {
    typealias ResponseModel = [AzureTranslateModel]
    
    let queryModel: QueryModel
    
    var path: String {
        "translate"
    }
    
    var method: Moya.Method = .post
    
    struct QueryModel: Codable {
        let Text: String
    }
    
    var task: Task {
        let data = try! JSONEncoder().encode([queryModel])
        return .requestCompositeData(bodyData: data, urlParameters: parameters)
    }
}
