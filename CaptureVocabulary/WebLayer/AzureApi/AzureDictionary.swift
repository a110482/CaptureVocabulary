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
    var normalizedSource: String?
    var translations: [Translation]?
    var displaySource: String?
    
    struct Translation: Codable {
        var posTag: PosTag?
        var backTranslations: [BackTranslation]?
        var prefixWord: String?
        var displayTarget: String?
        var confidence: Double?
        var normalizedTarget: String?
    }

    struct BackTranslation: Codable {
        var frequencyCount, numExamples: Int?
        var displayText, normalizedText: String?
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

// MARK: - 接上 SQL
extension AzureDictionaryModel: ORMTranslateAble {
    typealias ORMModel = AzureDictionaryORM
    
    func save(_ foreignKey: Int64? = nil) {
        // 存主詞
        guard let normalizedSource = normalizedSource,
              let displaySource = displaySource else { return }
        let orm = ORMModel.ORM(normalizedSource: normalizedSource, displaySource: displaySource)
        ORMModel.create(orm)
        // 存解釋
        guard let translations = translations else { return }
        let query = ORMModel.table
//            .select(ORMModel.id, ORMModel.normalizedSource, ORMModel.displaySource)
            .filter(ORMModel.normalizedSource == normalizedSource)
            .limit(1)
        guard let foreignKey = ORMModel.prepare(query)?.first?.id else { return }
        for translation in translations {
            translation.save(foreignKey)
        }
        
    }
    
    static func load(key: String?, foreignKey: Int64? = nil) -> [AzureDictionaryModel] {
        guard let key = key else { return [] }
        // 先讀取第一層資料
        let query = ORMModel.table.filter(ORMModel.normalizedSource == key).limit(1)
        guard let dictionaryObj = ORMModel.prepare(query)?.first else { return [] }
        var model = AzureDictionaryModel()
        model.normalizedSource = dictionaryObj.normalizedSource
        model.displaySource = dictionaryObj.displaySource
        
        // 讀取第二層
        let translations = Translation.load(foreignKey: dictionaryObj.id)
        model.translations = translations
        return [model]
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
        ORMModel.create(orm)
    }
    
    static func load(key: String? = nil, foreignKey: Int64? = nil) -> [AzureDictionaryModel.Translation] {
        guard let foreignKey = foreignKey else { return [] }
        let query = ORMModel.table.filter(ORMModel.azureDictionaryId == foreignKey)
        guard let orms = ORMModel.prepare(query) else { return [] }
        return orms.map { orm in
            var model = AzureDictionaryModel.Translation()
            model.posTag = AzureDictionaryModel.PosTag(rawValue: orm.posTag)
            model.prefixWord = orm.prefixWord
            model.displayTarget = orm.displayTarget
            model.confidence = orm.confidence
            model.normalizedTarget = orm.normalizedTarget
            if let backTranslations = orm.backTranslations {
                model.backTranslations = try? JSONDecoder().decode([AzureDictionaryModel.BackTranslation].self, from: backTranslations)
            }
            return model
        }
    }
}
