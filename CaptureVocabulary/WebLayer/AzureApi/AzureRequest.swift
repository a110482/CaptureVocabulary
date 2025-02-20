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
        let azureKey = AppParameters.shared.model.azureKey
        return ["Ocp-Apim-Subscription-Key": azureKey,
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



