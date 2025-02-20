//
//  JsonReader.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/3/20.
//

import Foundation

struct JsonReader {
    static func read<Model: Codable>(fileName: String, modelType: Model.Type) -> Model? {
        guard let keyJsonPath = Bundle.main.path(
            forResource: fileName, ofType: "json") else {
            return nil
        }
        guard let data = try? Data(
            contentsOf:URL(fileURLWithPath: keyJsonPath)) else { return nil }
        return try? JSONDecoder().decode(modelType, from: data)
    }
}
