//
//  AnalyticsKeys.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/4/28.
//

import FirebaseAnalytics

enum AnalyticsSelectContentType: String {
    case button
}

struct ContentItemValue: Equatable {
    let id: String
    let name: String
    let type: String
    init(id: String, name: String, type: AnalyticsSelectContentType) {
        self.id = id
        self.name = name
        self.type = type.rawValue
    }
}

enum ContentItem: RawRepresentable, CaseIterable {
    typealias RawValue = ContentItemValue
    case visionPageQueryButton
    
    init?(rawValue: ContentItemValue) {
        return nil
    }
    
    var rawValue: ContentItemValue {
        switch self {
        case .visionPageQueryButton:
            return ContentItemValue (
                id: "001",
                name: "visionPageQueryButton",
                type: .button)
        }
    }
    
}

class GAManager {
    static func log(item: ContentItem) {
        let value = item.rawValue
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(value.id)",
            AnalyticsParameterItemName: value.name,
            AnalyticsParameterContentType: value.type,
        ])
    }
}


