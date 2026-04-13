//
//  SimpleEntry.swift
//  DailyHomeWidget
//

import WidgetKit

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let total: Int
    let used: Int
    let remaining: Int
    let streak: Int
    let expenses: [ExpenseItem]
    let catMood: String  // "comfortable", "normal", "danger", "over"
    let favorites: [FavoriteItem]  // 추가 (최대 4개)

    // 중복 제거: Small/Medium/Large progressRatio 통합 (순수 산술 — Utils 의존 없음)
    var progressRatio: Double {
        guard total > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(remaining) / Double(total)))
    }
}
