// RolloverLogicTests.swift
// TDD assertion script for DailyRolloverLogic
//
// Run:
//   swiftc -o /tmp/rollover_test \
//     ios/DailyHomeWidget/Utils/DailyRolloverLogic.swift \
//     ios/DailyHomeWidget/Tests/RolloverLogicTests.swift \
//   && /tmp/rollover_test

import Foundation

@main
struct RolloverLogicTests {
    static func main() {
        var passed = 0, failed = 0

        func check(_ condition: Bool, _ message: String, line: Int = #line) {
            if condition {
                print("✓ \(message)")
                passed += 1
            } else {
                print("✗ FAIL [line \(line)]: \(message)")
                failed += 1
            }
        }

        // ── Bug 2: 음수 이월 반영 ────────────────────────────────────────────────
        // max(0, prevDayRemaining)이면 -2000 → 0 이 되어 10000을 반환하는 버그
        // 올바른 구현: prevDayRemaining 부호 그대로 → 8000 반환
        check(
            DailyRolloverLogic.computeTodayTotal(
                baseDailyBudget: 10000, prevDayRemaining: -2000,
                carryOverEnabled: true, isSunday: false
            ) == 8000,
            "초과 지출(-2000) 이월 → 오늘 총 예산 8000"
        )

        // ── 양수 이월 ──────────────────────────────────────────────────────────────
        check(
            DailyRolloverLogic.computeTodayTotal(
                baseDailyBudget: 10000, prevDayRemaining: 3000,
                carryOverEnabled: true, isSunday: false
            ) == 13000,
            "절약(+3000) 이월 → 오늘 총 예산 13000"
        )

        // ── 일요일: 이월 리셋 ──────────────────────────────────────────────────────
        check(
            DailyRolloverLogic.computeTodayTotal(
                baseDailyBudget: 10000, prevDayRemaining: 3000,
                carryOverEnabled: true, isSunday: true
            ) == 10000,
            "일요일(주 리셋) → 이월 무시, 오늘 예산 = baseDailyBudget"
        )

        // ── 이월 비활성 ────────────────────────────────────────────────────────────
        check(
            DailyRolloverLogic.computeTodayTotal(
                baseDailyBudget: 10000, prevDayRemaining: 3000,
                carryOverEnabled: false, isSunday: false
            ) == 10000,
            "이월 비활성 → 오늘 예산 = baseDailyBudget"
        )

        // ── 경계: prevDayRemaining = 0 ─────────────────────────────────────────────
        check(
            DailyRolloverLogic.computeTodayTotal(
                baseDailyBudget: 10000, prevDayRemaining: 0,
                carryOverEnabled: true, isSunday: false
            ) == 10000,
            "잔액 0 이월 → 오늘 예산 = baseDailyBudget (변화 없음)"
        )

        print("\n\(passed)/\(passed + failed) passed")
        if failed > 0 { exit(1) }
    }
}
