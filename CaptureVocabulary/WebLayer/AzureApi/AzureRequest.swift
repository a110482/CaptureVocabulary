//
//  AzureRequest.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/23.
//

import Foundation
import Moya


protocol AzureRequest: Request {
    
}

extension AzureRequest {
    var baseURL: URL { URL(string: "https://api.cognitive.microsofttranslator.com/")! }
    
    var headers: [String : String]? {
        let key = PlistReader.read(fileName: "key", modelType: KeyPlistModel.self)
        
        return ["Ocp-Apim-Subscription-Key": key?.azureKey ?? "",
         "Ocp-Apim-Subscription-Region": "eastasia",
         "Content-type": "application/json"
        ]
    }
    
    var parameters: [String : Any] {
        ["api-version" : "3.0",
         "from": "en",
         "to": "zh"
        ]
    }
    
    var decisions: [Decision] { [StanderDecision()] }
}

struct EmptyResponse: Codable {
    
}

// NARK: --

struct AzureTranslate: AzureRequest {
    typealias ResponseModel = EmptyResponse
    
    let text: String
    
    var path: String {
        "translate"
    }
    
    var method: Moya.Method = .post
    
    private var queryModel: [String: Any] {
        ["Text": "I would really like to drive your car around the block a few times."
        ]
    }
    struct QueryModel: Codable {
        let Text: String
    }
    
    var task: Task {
        let data = try! JSONEncoder().encode([QueryModel(Text: text)])
        return .requestCompositeData(bodyData: data, urlParameters: parameters)
    }
}
