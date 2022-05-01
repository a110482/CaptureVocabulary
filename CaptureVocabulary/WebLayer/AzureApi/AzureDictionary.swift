//
//  AzureDictionary.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/23.
//

import Foundation
import Moya
import SQLite

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
        let prefixWord: String?
        let displayTarget: String?
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

extension AzureDictionaryModel: ORMTranslateAble {
    typealias ORMModel = AzureDictionaryORM
    
    func save(_ foreignKey: Int64? = nil) {
        // 存主詞
        guard let normalizedSource = normalizedSource,
              let displaySource = displaySource else { return }
        let orm = ORMModel.ORM(normalizedSource: normalizedSource, displaySource: displaySource)
        ORMModel().create(orm)
        // 存解釋
        guard let translations = translations else { return }
        let query = ORMModel.table
//            .select(ORMModel().id, ORMModel().normalizedSource, ORMModel().displaySource)
            .filter(ORMModel().normalizedSource == normalizedSource)
            .limit(1)
        guard let foreignKey = ORMModel().prepare(query)?.first?.id else { return }
        for translation in translations {
            translation.save(foreignKey)
        }
        
    }
}

extension AzureDictionaryModel.Translation: ORMTranslateAble {
    typealias ORMModel = AzureDictionaryTranslationORM
    func save(_ foreignKey: Int64? = nil) {
        guard let foreignKey = foreignKey else { return }
        guard let posTag = posTag,
              let backTranslations = backTranslations,
              let prefixWord = prefixWord,
              let displayTarget = displayTarget,
              let confidence = confidence,
              let normalizedTarget = normalizedTarget else { return }
        let backTranslationsData = try? JSONEncoder().encode(backTranslations)
        let orm = ORMModel.ORM(posTag: posTag.rawValue,
                               prefixWord: prefixWord,
                               displayTarget: displayTarget,
                               confidence: confidence,
                               normalizedTarget: normalizedTarget,
                               backTranslations: backTranslationsData,
                               azureDictionaryId: foreignKey
        )
        ORMModel().create(orm)
    }
}

// MARK: -
protocol ORMTranslateAble {
    associatedtype ORMModel: TableType
    func save(_ foreignKey: Int64?)
}
