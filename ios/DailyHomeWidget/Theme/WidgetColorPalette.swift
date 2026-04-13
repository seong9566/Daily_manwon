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
        // 배경: 흰색 고정
        // 서브 텍스트: 중립 고정 #8E8E8E
        // accentBg: 흰 배경 정책에 맞게 항상 #EEEEEE 고정
        //   → 스트릭 배지 배경, 카테고리 아이콘 원, 즐겨찾기 버튼 배경, 프로그레스 바 트랙 등
        //   → 금액 텍스트와 Bar 채움만 상태 색상을 적용하고, 나머지는 중립 유지
        let bg            = Color.white
        let secondaryText = Color(red: 142/255, green: 142/255, blue: 142/255) // #8E8E8E
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
                primaryText:   Color(red: 245/255, green: 166/255, blue: 35/255), // #F5A623
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 245/255, green: 166/255, blue: 35/255)  // #F5A623
            )
        case .danger:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 232/255, green: 93/255,  blue: 93/255), // #E85D5D
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 232/255, green: 93/255,  blue: 93/255)  // #E85D5D
            )
        case .over:
            return WidgetColorPalette(
                background:    bg,
                primaryText:   Color(red: 192/255, green: 57/255,  blue: 43/255), // #C0392B
                secondaryText: secondaryText,
                accentBg:      accentBg,
                progressColor: Color(red: 232/255, green: 93/255,  blue: 93/255)  // #E85D5D
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
