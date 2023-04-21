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
        let lastDatabaseVersion: Int
        let adUnitID: String
    }
    let model: Model
    static let shared = AppParameters()
    private init() {
        #if DEBUG
        let fileName = "appParametersDev"
        #else
        let fileName = "appParametersProd"
        #endif
        let model = PlistReader.read(fileName: fileName,
                                   modelType: Model.self)
        self.model = model!
    }
}


