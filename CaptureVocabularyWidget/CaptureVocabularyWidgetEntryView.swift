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
    
    init(entry: CaptureVocabularyWidgetProvider.Entry) {
        self.entry = entry
    }
    
    @ViewBuilder
    var body: some View {
        ZStack {
            VStack {
                Text(entry.vocabularyCard?.normalizedSource ?? "")
                    .font(.title)
                    .foregroundColor(.black)
                
                Color.black.frame(height: 1)
                    .padding([.leading, .trailing], 20)
                
                Text(entry.vocabularyCard?.normalizedTarget ?? "")
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
        .background(Color.white)
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct CaptureVocabularyWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CaptureVocabularyWidgetEntryView(
                entry: CaptureVocabularyWidgetEntry(
                    date: Date(),
                    configuration: ConfigurationIntent()))
        }
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// MARK: -
struct CaptureVocabularyWidgetEntry: TimelineEntry {
    var date: Date
    let configuration: ConfigurationIntent
    let vocabularyCard: VocabularyCardORM.ORM? = {
        let numbers = VocabularyCardORM.ORM.cardNumbers(memorized: false)
        guard numbers > 0 else { return nil }
        let randomIndex = Int.random(in: 0 ..< numbers)
        let card =  VocabularyCardORM.ORM.get(by: randomIndex, memorized: false)
        return card
    }()
    
}

// MARK: -

struct CaptureVocabularyWidgetProvider: IntentTimelineProvider {
    typealias Entry = CaptureVocabularyWidgetEntry
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(),
              configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(),
                          configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var currentDate = Date()
        var entries: [Entry] = []
        let calendar = Calendar.current
        for _ in 0 ..< 30 {
            var entry = Entry(date: currentDate, configuration: configuration)
            if let modifiedDate = calendar.date(
                byAdding: .minute,
                value: 10,
                to: currentDate) {
                currentDate = modifiedDate
                entry.date = currentDate
                entries.append(entry)
            }
        }
        let timeline = Timeline(entries: entries, policy: .after(currentDate))
        completion(timeline)
    }
}
