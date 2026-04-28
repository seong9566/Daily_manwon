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
            date: Date(), total: 10000, baseDailyBudget: 10000, used: 0,
            remaining: 10000, streak: 0, weeklySuccessDays: 0, expenses: [], catMood: "comfortable",
            favorites: []
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(), total: 10000, baseDailyBudget: 10000, used: 2800,
            remaining: 7200, streak: 12, weeklySuccessDays: 3,
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

        let total             = userDefault?.integer(forKey: "totalKey")             ?? 0
        let baseDailyBudget   = userDefault?.integer(forKey: "baseDailyBudgetKey") ?? total
        let streak            = userDefault?.integer(forKey: "streakKey")            ?? 0
        var weeklySuccessDays = userDefault?.integer(forKey: "weeklySuccessKey")     ?? 0
        let carryOverEnabled  = userDefault?.bool(forKey: "carryOverEnabledKey")     ?? false
        let prevDayRemaining  = userDefault?.integer(forKey: "prevDayRemainingKey")  ?? 0

        // 자정 기준 날짜 불일치 감지: Flutter가 마지막으로 데이터를 쓴 날짜와 오늘을 비교
        // locale/calendar 명시 고정 — 비-Gregorian 기기에서도 Dart와 동일한 문자열 생성
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        let lastUpdatedStr = userDefault?.string(forKey: "lastUpdatedDateKey") ?? ""
        // lastUpdatedDateKey가 오늘과 다르면 새 날 (기존 설치 이행 포함: "" != today → 리셋)
        let isNewDay = lastUpdatedStr != todayStr

        var todayTotal: Int
        let used: Int
        let remaining: Int
        let catMood: String
        var expenses: [ExpenseItem] = []

        if isNewDay {
            // 자정이 지났으나 Flutter가 아직 갱신하지 않은 상태 → 당일 데이터 리셋
            let isSunday = Calendar.current.component(.weekday, from: Date()) == 1
            todayTotal = DailyRolloverLogic.computeTodayTotal(
                baseDailyBudget: baseDailyBudget,
                prevDayRemaining: prevDayRemaining,
                carryOverEnabled: carryOverEnabled,
                isSunday: isSunday
            )

            used = 0
            remaining = todayTotal
            // remaining/total 비율로 catMood 계산 — 하드코딩 대신 실제 예산 비율 기준 적용
            // (음수 이월로 todayTotal < 0인 극단 케이스도 올바르게 처리)
            switch BudgetStatus(remaining: remaining, total: todayTotal) {
            case .comfortable: catMood = "comfortable"
            case .normal:      catMood = "normal"
            case .danger:      catMood = "danger"
            case .over:        catMood = "over"
            }
            // 새 주 시작(일요일)이면 이전 주 성공일 리셋 — Flutter 미실행 상태에서도 stale 값 방지
            if isSunday {
                weeklySuccessDays = 0
                userDefault?.set(0, forKey: "weeklySuccessKey")
            }
            // lastUpdatedDateKey를 오늘로 즉시 갱신 — 같은 날 내 Intent 낙관적 업데이트가 stale key 기준으로 동작하는 문제 방지
            userDefault?.set(todayStr, forKey: "lastUpdatedDateKey")
            userDefault?.set(0, forKey: "usedKey")
            userDefault?.set(todayTotal, forKey: "remainingKey")
            userDefault?.set(todayTotal, forKey: "totalKey")
            // cat_mood도 갱신 — 미갱신 시 getTimeline 재호출에서 전날 값을 읽어 색상 불일치 발생
            userDefault?.set(catMood, forKey: "cat_mood")
            userDefault?.synchronize()
        } else {
            todayTotal = total
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
            total: todayTotal,
            baseDailyBudget: baseDailyBudget,
            used: used,
            remaining: remaining,
            streak: streak,
            weeklySuccessDays: weeklySuccessDays,
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
