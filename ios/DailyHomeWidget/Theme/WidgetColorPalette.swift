//
//  WidgetColorPalette.swift
//  DailyHomeWidget
//

import SwiftUI

struct WidgetColorPalette {
    let background: Color
    let primaryText: Color    // 금액, 제목
    let secondaryText: Color  // 라벨, 설명
    let accentBg: Color       // 버튼 배경, 프로그레스 바 트랙 등
    let progressColor: Color  // 프로그레스 바 채움 색상

    static func palette(for status: BudgetStatus) -> WidgetColorPalette {
        let bg            = Color.white
        let secondaryText = Color(red: 118/255, green: 118/255, blue: 118/255) // #767676, 흰 배경 대비 ≈4.5:1
        let accentBg      = Color(red: 238/255, green: 238/255, blue: 238/255) // #EEEEEE 고정

        switch status {
        case .comfortable:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 0,       green: 0,       blue: 0),   // #000000
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 0,       green: 0,       blue: 0)    // #000000
            )
        case .normal:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 245/255, green: 166/255, blue: 35/255),  // #F5A623 (Flutter budgetWarning)
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 245/255, green: 166/255, blue: 35/255)   // #F5A623 (Flutter budgetWarning)
            )
        case .danger:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 232/255, green: 93/255,  blue: 93/255), // #E85D5D, 대형 텍스트(24pt+) 대비 ≈3.4:1 — AA 통과
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 232/255, green: 93/255,  blue: 93/255)  // #E85D5D
            )
        case .over:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 192/255, green: 57/255,  blue: 43/255), // #C0392B (Flutter budgetOver)
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 192/255, green: 57/255,  blue: 43/255)  // #C0392B (Flutter budgetOver)
            )
        }
    }

    /// Small 위젯 금액 폰트 크기
    static func smallFontSize(for status: BudgetStatus) -> CGFloat { 24 }

    /// Medium 위젯 "남은 예산" 금액 폰트 크기
    static func mediumRemainingFontSize(for status: BudgetStatus) -> CGFloat { 18 }

    /// Medium 위젯 "사용한 예산" 금액 폰트 크기
    static func mediumUsedFontSize(for status: BudgetStatus) -> CGFloat { 18 }

    /// Large 위젯 "남은 예산" 금액 폰트 크기
    static func largeRemainingFontSize(for status: BudgetStatus) -> CGFloat { 18 }

    /// Large 위젯 "사용한 예산" 금액 폰트 크기
    static func largeUsedFontSize(for status: BudgetStatus) -> CGFloat { 18 }

    // 버튼 텍스트 전용 고정 색상: #4A4A4A
    // accentBg(#EEEEEE) 위 대비 ≈7.7:1 — 모든 상태에서 WCAG AA 통과
    static let buttonTextColor = Color(red: 74/255, green: 74/255, blue: 74/255)
}
