//
//  DailyRolloverLogic.swift
//  DailyHomeWidget
//

enum DailyRolloverLogic {
    /// 자정 롤오버 시 오늘의 총 예산을 계산한다.
    ///
    /// - Parameters:
    ///   - baseDailyBudget: 이월 미포함 순수 일일 예산 (UserDefaults: baseDailyBudgetKey)
    ///   - prevDayRemaining: 어제 잔액 스냅샷 (UserDefaults: prevDayRemainingKey — Intent 불변)
    ///   - carryOverEnabled: 이월 기능 활성화 여부
    ///   - isSunday: 오늘이 일요일(주 리셋)인지 여부
    /// - Returns: 오늘의 총 예산 (음수 이월 포함)
    static func computeTodayTotal(
        baseDailyBudget: Int,
        prevDayRemaining: Int,
        carryOverEnabled: Bool,
        isSunday: Bool
    ) -> Int {
        let carryOver = (carryOverEnabled && !isSunday) ? prevDayRemaining : 0
        return baseDailyBudget + carryOver
    }
}
