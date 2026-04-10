//
//  DailyHomeWidget.swift
//  DailyHomeWidget
//
//  Created by stecdev_mac on 4/1/26.
//

import WidgetKit
import SwiftUI


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Timeline Provider
// ─────────────────────────────────────────────────────────────────────────────
struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(), total: 10000, used: 0,
            remaining: 10000, streak: 0, expenses: [], catMood: "comfortable"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(), total: 10000, used: 2800,
            remaining: 7200, streak: 12,
            expenses: [
                ExpenseItem(category: "점심", time: "12:30", amount: 3500),
                ExpenseItem(category: "아메리카노", time: "15:15", amount: 1300),
            ],
            catMood: "comfortable"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefault = UserDefaults(suiteName: "group.dailyManWon.homeWidget")

        let total     = userDefault?.integer(forKey: "totalKey")     ?? 0
        let used      = userDefault?.integer(forKey: "usedKey")      ?? 0
        let remaining = userDefault?.integer(forKey: "remainingKey") ?? 0
        let streak    = userDefault?.integer(forKey: "streakKey")    ?? 0
        let catMood   = userDefault?.string(forKey: "cat_mood")      ?? "comfortable"

        // JSON 문자열로 저장된 지출 목록 파싱
        var expenses: [ExpenseItem] = []
        if let jsonString = userDefault?.string(forKey: "expensesKey"),
           let data = jsonString.data(using: .utf8) {
            expenses = (try? JSONDecoder().decode([ExpenseItem].self, from: data)) ?? []
        }

        let entry = SimpleEntry(
            date: Date(),
            total: total,
            used: used,
            remaining: remaining,
            streak: streak,
            expenses: expenses,
            catMood: catMood
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Configuration
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeWidget: Widget {
    let kind: String = "DailyHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyHomeWidgetRouter(entry: entry)
        }
        .configurationDisplayName("하루 만원")
        .description("오늘의 잔여 예산을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Router (사이즈별 뷰 분기)
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeWidgetRouter: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            DailyHomeMediumView(entry: entry)
        case .systemLarge:
            DailyHomeLargeView(entry: entry)
        default:
            DailyHomeSmallView(entry: entry)
        }
    }
}
