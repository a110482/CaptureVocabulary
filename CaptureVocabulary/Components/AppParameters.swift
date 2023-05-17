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
        let versionUrl: String
        let feedbackEmail: String
    }
    let model: Model
    static let shared = AppParameters()
    private init() {
        let fileName = "appParameters"
        let model = PlistReader.read(fileName: fileName,
                                   modelType: Model.self)
        self.model = model!
    }
}


