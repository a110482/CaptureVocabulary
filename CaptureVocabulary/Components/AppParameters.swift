//
//  AppParameters.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/13.
//

import Foundation


class AppParameters {
    struct Model: Codable {
        let azureKey: String
        let YDAppKey: String
        let YDSecret: String
        
        init(azureKey: String = "", YDAppKey: String = "", YDSecret: String = "") {
            self.azureKey = azureKey
            self.YDAppKey = YDAppKey
            self.YDSecret = YDSecret
        }
    }
    let model: Model
    static let shared = AppParameters()
    private init() {
        let fileName = "appParametersDev"
        let model = PlistReader.read(fileName: fileName,
                                   modelType: Model.self)
        self.model = model!
    }
}


