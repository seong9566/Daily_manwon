//
//  SmallWidgetView.swift
//  DailyHomeWidget
//

import SwiftUI
import WidgetKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Small 2×2)
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeSmallView: View {
    var entry: Provider.Entry

    private var status: BudgetStatus { BudgetStatus(remaining: entry.remaining) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }

    private var amountText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }

    var body: some View {
        let content = VStack(alignment: .leading, spacing: 0) {
            // 상단: 남은 예산 라벨 + 스트릭 배지
            HStack {
                Text("남은 예산")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)

                Spacer()

                StreakBadgeView(streak: entry.streak, colors: colors)
            }

            Spacer()

            HStack {
                Spacer()
                Image(catImageName(for: entry.catMood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                Spacer()
            }

            HStack {
                Spacer()
                Text(amountText)
                    .font(.system(size: WidgetColorPalette.smallFontSize(for: status), weight: .bold))
                    .foregroundColor(colors.primaryText)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Spacer()
            }

            if status == .over {
                HStack {
                    Spacer()
                    Text("초과!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                    Spacer()
                }
            }

            Spacer()

            // 프로그레스 바
            WidgetProgressBar(ratio: entry.progressRatio, colors: colors)

            Spacer().frame(height: 8)

            Text(status.statusMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(colors.secondaryText)
                .lineLimit(1)
        }

        content.widgetBackground(colors.background)
    }
}

#Preview(as: .systemSmall) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(date: Date(), total: 10000, used: 3000, remaining: 7000, streak: 12, expenses: [], catMood: "comfortable", favorites: [])
    SimpleEntry(date: Date(), total: 10000, used: 9000, remaining: 1000, streak: 5, expenses: [], catMood: "normal", favorites: [])
    SimpleEntry(date: Date(), total: 10000, used: 12000, remaining: -2000, streak: 0, expenses: [], catMood: "over", favorites: [])
}
