//
//  AzureDictionary.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/23.
//

import Foundation
import Moya

struct AzureDictionary: AzureRequest {
    typealias ResponseModel = [AzureDictionaryModel]
    
    let queryModel: QueryModel
    
    var path: String {
        "dictionary/lookup"
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

struct AzureDictionaryModel: Codable {
    let normalizedSource: String?
    let translations: [Translation]?
    let displaySource: String?
    
    struct Translation: Codable {
        let posTag: PosTag?
        let backTranslations: [BackTranslation]?
        let prefixWord, displayTarget: String?
        let confidence: Double?
        let normalizedTarget: String?
    }

    struct BackTranslation: Codable {
        let frequencyCount, numExamples: Int?
        let displayText, normalizedText: String?
    }
    
    enum PosTag: String, Codable {
        case ADJ
        case ADV
        case CONJ
        case DET
        case MODAL
        case NOUN
        case PREP
        case PRON
        case VERB
        case OTHER
        
        var string: String {
            switch self {
            case .ADJ:
                return "形容詞"
            case .ADV:
                return "副詞"
            case .CONJ:
                return "連接詞"
            case .DET:
                return "限定詞"
            case .MODAL:
                return "動詞"
            case .NOUN:
                return "名詞"
            case .PREP:
                return "介系詞"
            case .PRON:
                return "代名詞"
            case .VERB:
                return "動詞"
            case .OTHER:
                return "其他"
            }
        }
    }
}
