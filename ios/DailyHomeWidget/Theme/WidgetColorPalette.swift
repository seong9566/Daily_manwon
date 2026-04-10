//
//  WidgetColorPalette.swift
//  DailyHomeWidget
//

import SwiftUI

struct WidgetColorPalette {
    let background: Color
    let primaryText: Color    // 금액, 제목
    let secondaryText: Color  // 라벨, 설명
    let accentBg: Color       // 스트릭 배지, 구분선 등
    let progressColor: Color  // 프로그레스 바 채움 색상

    static func palette(for status: BudgetStatus) -> WidgetColorPalette {
        // 배경: 모든 상태 흰색 고정 (모바일 정책 동일)
        // 서브 텍스트: 중립 고정 #8E8E8E
        let bg            = Color.white
        let secondaryText = Color(red: 142/255, green: 142/255, blue: 142/255) // #8E8E8E

        switch status {
        case .comfortable:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 0,       green: 0,       blue: 0),        // #000000
                secondaryText: secondaryText,
                accentBg:      Color(red: 238/255, green: 238/255, blue: 238/255),  // #EEEEEE
                progressColor: Color(red: 0,       green: 0,       blue: 0)         // #000000 (budgetComfortable)
            )
        case .normal:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 245/255, green: 166/255, blue: 35/255),   // #F5A623
                secondaryText: secondaryText,
                accentBg:      Color(red: 254/255, green: 243/255, blue: 199/255),  // #FEF3C7
                progressColor: Color(red: 245/255, green: 166/255, blue: 35/255)    // #F5A623 (budgetWarning)
            )
        case .danger:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 232/255, green: 93/255,  blue: 93/255),   // #E85D5D
                secondaryText: secondaryText,
                accentBg:      Color(red: 253/255, green: 232/255, blue: 232/255),  // #FDE8E8
                progressColor: Color(red: 232/255, green: 93/255,  blue: 93/255)    // #E85D5D (budgetDanger)
            )
        case .over:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 192/255, green: 57/255,  blue: 43/255),   // #C0392B
                secondaryText: secondaryText,
                accentBg:      Color(red: 254/255, green: 226/255, blue: 226/255),  // #FEE2E2
                progressColor: Color(red: 232/255, green: 93/255,  blue: 93/255)    // #E85D5D (budgetDanger — Flutter와 동일)
            )
        }
    }

    /// Small 위젯 금액 폰트 크기
    static func smallFontSize(for status: BudgetStatus) -> CGFloat { 24 }

    /// Medium 위젯 "남은 예산" 금액 폰트 크기
    static func mediumRemainingFontSize(for status: BudgetStatus) -> CGFloat { 26 }

    /// Medium 위젯 "사용한 예산" 금액 폰트 크기
    static func mediumUsedFontSize(for status: BudgetStatus) -> CGFloat { 26 }

    /// Large 위젯 "남은 예산" 금액 폰트 크기
    static func largeRemainingFontSize(for status: BudgetStatus) -> CGFloat { 18 }

    /// Large 위젯 "사용한 예산" 금액 폰트 크기
    static func largeUsedFontSize(for status: BudgetStatus) -> CGFloat { 18 }
}
