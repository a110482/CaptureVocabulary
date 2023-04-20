//
//  CaptureVocabularyWidget.swift
//  CaptureVocabularyWidget
//
//  Created by Tan Elijah on 2023/4/13.
//

import WidgetKit
import SwiftUI
import Intents

struct CaptureVocabularyWidget: Widget {
    let kind: String = "CaptureVocabularyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: CaptureVocabularyWidgetProvider()) { entry in
            CaptureVocabularyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WordHouse")
        .description("隨時複習單字")
    }
}

struct CaptureVocabularyWidget_Previews: PreviewProvider {
    static var previews: some View {
        CaptureVocabularyWidgetEntryView(
            entry: CaptureVocabularyWidgetEntry(
                date: Date(),
                configuration: ConfigurationIntent()))
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
