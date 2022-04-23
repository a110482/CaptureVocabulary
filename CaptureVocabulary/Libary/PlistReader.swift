//
//  PlistReader.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/24.
//

import Foundation

struct PlistReader {
    static func read<Model: Codable>(fileName: String, modelType: Model.Type) -> Model? {
        guard let keyPlistPath = Bundle.main.path(
            forResource: "key", ofType: "plist") else {
            return nil
        }
        guard let data = try? Data(
            contentsOf:URL(fileURLWithPath: keyPlistPath)) else { return nil }
        return try? PropertyListDecoder().decode(Model.self, from: data)
    }
}
