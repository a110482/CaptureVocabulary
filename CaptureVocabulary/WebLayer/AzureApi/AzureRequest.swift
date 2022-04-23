//
//  AzureRequest.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/23.
//

import Foundation
import Moya


struct KeyPlistModel: Codable {
    let azureKey: String?
}

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



