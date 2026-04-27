//
//  DailyHomeWidget.swift
//  DailyHomeWidget
//
//  Created by stecdev_mac on 4/1/26.
//

import AppIntents
import WidgetKit
import SwiftUI


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Timeline Provider
// ─────────────────────────────────────────────────────────────────────────────
struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    private let appGroupSuite = WidgetConstants.appGroup

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(), total: 10000, used: 0,
            remaining: 10000, streak: 0, expenses: [], catMood: "comfortable",
            favorites: []
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
            catMood: "comfortable",
            favorites: [
                FavoriteItem(id: 1, amount: 3500, category: 2, memo: ""),
                FavoriteItem(id: 2, amount: 1500, category: 1, memo: ""),
            ]
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefault = UserDefaults(suiteName: appGroupSuite)
        // 다른 프로세스(Intent, Flutter)가 기록한 최신값을 읽도록 강제 동기화
        userDefault?.synchronize()

        let total     = userDefault?.integer(forKey: "totalKey")     ?? 0
        let streak    = userDefault?.integer(forKey: "streakKey")    ?? 0

        // 자정 기준 날짜 불일치 감지: Flutter가 마지막으로 데이터를 쓴 날짜와 오늘을 비교
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        let lastUpdatedStr = userDefault?.string(forKey: "lastUpdatedDateKey") ?? ""
        // lastUpdatedDateKey가 존재하고 오늘과 다르면 새 날이 시작된 것
        let isNewDay = !lastUpdatedStr.isEmpty && lastUpdatedStr != todayStr

        let used: Int
        let remaining: Int
        let catMood: String
        var expenses: [ExpenseItem] = []

        if isNewDay {
            // 자정이 지났으나 Flutter가 아직 갱신하지 않은 상태 → 당일 데이터 리셋
            used = 0
            remaining = total
            catMood = "comfortable"
            // expenses는 빈 배열 유지
        } else {
            used      = userDefault?.integer(forKey: "usedKey")      ?? 0
            remaining = userDefault?.integer(forKey: "remainingKey") ?? 0
            catMood   = userDefault?.string(forKey: "cat_mood")      ?? "comfortable"

            // JSON 문자열로 저장된 지출 목록 파싱
            if let jsonString = userDefault?.string(forKey: "expensesKey"),
               let data = jsonString.data(using: .utf8) {
                expenses = (try? JSONDecoder().decode([ExpenseItem].self, from: data)) ?? []
            }
        }

        var favorites: [FavoriteItem] = []
        if let favJson = userDefault?.string(forKey: "favoritesKey"),
           let data = favJson.data(using: .utf8) {
            let decoded = (try? JSONDecoder().decode([FavoriteItem].self, from: data)) ?? []
            favorites = Array(decoded.prefix(4))
        }

        let entry = SimpleEntry(
            date: Date(),
            total: total,
            used: used,
            remaining: remaining,
            streak: streak,
            expenses: expenses,
            catMood: catMood,
            favorites: favorites
        )

        // 다음 자정 시각 계산 — 자정 이후 WidgetKit이 자동으로 getTimeline을 재호출한다
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let nextMidnight = calendar.startOfDay(for: tomorrow)

        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
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
