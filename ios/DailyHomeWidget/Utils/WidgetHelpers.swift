//
//  WidgetHelpers.swift
//  DailyHomeWidget
//

import SwiftUI
import WidgetKit

// MARK: - 헬퍼 함수 (private 제거 — 모듈 내 모든 파일 접근 가능)

/// cat_mood 문자열로 Asset 이미지 이름을 반환한다
func catImageName(for mood: String) -> String {
    switch mood {
    case "comfortable": return "CatComfortable"
    case "normal":      return "CatNormal"
    case "danger":      return "CatDanger"
    case "over":        return "CatOver"
    case "new_week":    return "CatComfortable" // CatNewWeek 자산 누락으로 인한 폴백 처리
    default:            return "CatComfortable"
    }
}

func formatNumber(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}

// MARK: - 이번 주 성공일 배지 공유 뷰
// Medium/Large: spacing=3, iconSize=11, textSize=12, hPadding=8, vPadding=4, cornerRadius=12
struct StreakBadgeView: View {
    let weeklySuccessDays: Int
    let colors: WidgetColorPalette
    var spacing: CGFloat = 3
    var iconSize: CGFloat = 11
    var textSize: CGFloat = 12
    var hPadding: CGFloat = 8
    var vPadding: CGFloat = 4
    var cornerRadius: CGFloat = 12

    var body: some View {
        HStack(spacing: spacing) {
            Text("🔥")
                .font(.system(size: iconSize))
            Text("이번주 성공일 : \(weeklySuccessDays)일")
                .font(.system(size: textSize, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, hPadding)
        .padding(.vertical, vPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(colors.accentBg)
        )
    }
}

// MARK: - 프로그레스 바 공유 뷰
struct WidgetProgressBar: View {
    let entry: SimpleEntry
    let colors: WidgetColorPalette
    var height: CGFloat = 6

    var body: some View {
        let carryOver = entry.total - entry.baseDailyBudget
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(colors.accentBg)
                
                let totalWidth = geometry.size.width * CGFloat(entry.progressRatio)
                if carryOver > 0 && entry.total > 0 {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(red: 74/255.0, green: 144/255.0, blue: 217/255.0)) // #4A90D9 (AppColors.accent)
                            .frame(width: totalWidth * CGFloat(carryOver) / CGFloat(entry.total))
                        if entry.baseDailyBudget > 0 {
                            Rectangle()
                                .fill(Color(red: 45/255.0, green: 189/255.0, blue: 142/255.0)) // #2DBD8E (AppColors.statusComfortableStrong)
                                .frame(width: totalWidth * CGFloat(entry.baseDailyBudget) / CGFloat(entry.total))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colors.progressColor)
                        .frame(width: totalWidth)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - iOS 17 배경 ViewModifier
struct WidgetBackground: ViewModifier {
    let color: Color

    // @ViewBuilder 필수: if #available 분기에서 두 가지 다른 View 타입을 반환
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { color }
        } else {
            content.padding(16).background(color)
        }
    }
}

extension View {
    func widgetBackground(_ color: Color) -> some View {
        modifier(WidgetBackground(color: color))
    }
}
