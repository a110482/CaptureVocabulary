//
//  CaptureVocabularyWidgetEntryView.swift
//  CaptureVocabularyWidgetExtension
//
//  Created by Tan Elijah on 2023/4/13.
//

import SwiftUI
import WidgetKit
import Intents

struct CaptureVocabularyWidgetEntryView : View {
    var entry: CaptureVocabularyWidgetProvider.Entry
    
    @ViewBuilder
    var body: some View {
//        Text(entry.date, style: .time)
        Label("hello", image: "")
    }
}

// MARK: -
struct CaptureVocabularyWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

// MARK: -

struct CaptureVocabularyWidgetProvider: IntentTimelineProvider {
    typealias Entry = CaptureVocabularyWidgetEntry
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Entry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
