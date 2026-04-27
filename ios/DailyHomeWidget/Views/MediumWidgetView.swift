//
//  MediumWidgetView.swift
//  DailyHomeWidget
//

import AppIntents
import SwiftUI
import WidgetKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Medium 4×2)
// 레이아웃:
//  ┌──────────────────────────────────────┐
//  │ 남은 예산       │  사용한 예산 [고양이]│
//  │ ₩7,200 (큰글씨) │  ₩2,800 (작은글씨)  │
//  │ (초과 시 "초과!" 표시)               │
//  │ ████████░░ 진행바                    │
//  │ [      + 지출 추가      ]            │
//  └──────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeMediumView: View {
    var entry: Provider.Entry

    private var status: BudgetStatus { BudgetStatus(catMood: entry.catMood) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }

    private var remainingText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }

    private var usedText: String {
        "₩\(formatNumber(entry.used))"
    }

    var body: some View {
        let content = VStack(alignment: .center, spacing: 0) {

            // ── 남은 예산 | 사용한 예산 (좌우 분할) ──────────────────
            HStack(alignment: .center, spacing: 0) {
                // 좌측: 남은 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("남은 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)

                    Text(remainingText)
                        .font(.system(size: WidgetColorPalette.mediumRemainingFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 세로 구분선
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 12)

                // 우측: 사용한 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("사용한 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)

                    Text(usedText)
                        .font(.system(size: WidgetColorPalette.mediumUsedFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(catImageName(for: entry.catMood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .padding(.leading, 8)
            }

            if status == .over {
                Text("초과!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }

            Spacer()

            // 프로그레스 바
            WidgetProgressBar(ratio: entry.progressRatio, colors: colors)

            Spacer().frame(height: 6)

            Button(intent: OpenAddExpenseIntent()) {
                Text(status.addButtonLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(WidgetColorPalette.buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colors.accentBg)
                    )
            }
            .buttonStyle(.plain)
        }

        content.widgetBackground(colors.background)
    }
}

#Preview(as: .systemMedium) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(date: Date(), total: 10000, used: 2800, remaining: 7200, streak: 12, expenses: [], catMood: "comfortable", favorites: [])
    SimpleEntry(date: Date(), total: 10000, used: 7200, remaining: 2800, streak: 7, expenses: [], catMood: "normal", favorites: [])
    SimpleEntry(date: Date(), total: 10000, used: 13000, remaining: -3000, streak: 0, expenses: [], catMood: "over", favorites: [])
}
