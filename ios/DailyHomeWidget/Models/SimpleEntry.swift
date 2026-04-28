//
//  SimpleEntry.swift
//  DailyHomeWidget
//

import WidgetKit

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let total: Int
    let baseDailyBudget: Int
    let used: Int
    let remaining: Int
    let streak: Int
    let weeklySuccessDays: Int
    let expenses: [ExpenseItem]
    let catMood: String  // "comfortable", "normal", "danger", "over"
    let favorites: [FavoriteItem]  // 추가 (최대 4개)

    // 중복 제거: Small/Medium/Large progressRatio 통합 (순수 산술 — Utils 의존 없음)
    // 음수 이월 시 기본 예산 기준으로 비율 계산 — effectiveBudget 기준이면 1.0 오판
    var progressRatio: Double {
        let carryOver = total - baseDailyBudget
        let reference = (carryOver < 0 && baseDailyBudget > 0) ? baseDailyBudget : total
        guard reference > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(remaining) / Double(reference)))
    }
}
