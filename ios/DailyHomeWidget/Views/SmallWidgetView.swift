//
//  SmallWidgetView.swift
//  DailyHomeWidget
//

import AppIntents
import SwiftUI
import WidgetKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Small 2×2)
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeSmallView: View {
    var entry: Provider.Entry

    private var status: BudgetStatus { BudgetStatus(catMood: entry.catMood) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }

    private var amountText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }

    var body: some View {
        let content = VStack(alignment: .center, spacing: 0) {
            Spacer()

            HStack {
                Spacer()
                Image(catImageName(for: entry.catMood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                Spacer()
            }

            HStack {
                Spacer()
                Text("남은 예산")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(colors.secondaryText)
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
     

            Spacer()

            WidgetProgressBar(entry: entry, colors: colors)

            Spacer().frame(height: 4)

            Button(intent: OpenAddExpenseIntent()) {
                Text(status.addButtonLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(WidgetColorPalette.buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colors.accentBg)
                    )
            }
            .buttonStyle(.plain)

            Spacer().frame(height: 14)
        }

        content.widgetBackground(colors.background)
    }
}

#Preview(as: .systemSmall) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(date: Date(), total: 10000, baseDailyBudget: 10000, used: 3000, remaining: 7000, streak: 12, weeklySuccessDays: 3, expenses: [], catMood: "comfortable", favorites: [])
    SimpleEntry(date: Date(), total: 10000, baseDailyBudget: 10000, used: 9000, remaining: 1000, streak: 5, weeklySuccessDays: 2, expenses: [], catMood: "normal", favorites: [])
    SimpleEntry(date: Date(), total: 10000, baseDailyBudget: 10000, used: 12000, remaining: -2000, streak: 0, weeklySuccessDays: 0, expenses: [], catMood: "over", favorites: [])
}
