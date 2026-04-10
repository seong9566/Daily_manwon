//
//  LargeWidgetView.swift
//  DailyHomeWidget
//

import SwiftUI
import WidgetKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Large 4×4)
// 이미지 레이아웃:
//  ┌──────────────────────────────────────┐
//  │ 총 예산 ₩10,000            🔥 12일  │
//  │ 남은 예산       │  사용한 예산       │
//  │ ₩5,200 (큰글씨) │  ₩4,800           │
//  │──────────────────────────────────────│
//  │ 오늘의 지출                     2건  │
//  │ ☕ 점심     12:30           -3,500   │
//  │ ☕ 아메리카노 15:15          -1,300   │
//  └──────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeLargeView: View {
    var entry: Provider.Entry

    private var status: BudgetStatus { BudgetStatus(remaining: entry.remaining) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }

    private var remainingText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }

    private var usedText: String {
        "₩\(formatNumber(entry.used))"
    }

    private var totalText: String {
        "총 예산 ₩\(formatNumber(entry.total))"
    }

    /// 표시할 지출 목록 (최대 3건)
    private var displayExpenses: [ExpenseItem] {
        Array(entry.expenses.prefix(3))
    }

    var body: some View {
        let content = VStack(alignment: .leading, spacing: 0) {

            // ── 상단: 총 예산 + 스트릭 배지 ──────────────────────────
            HStack {
                Text(totalText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)

                Spacer()

                StreakBadgeView(
                    streak: entry.streak,
                    colors: colors,
                    spacing: 3,
                    iconSize: 11,
                    textSize: 12,
                    hPadding: 8,
                    vPadding: 4,
                    cornerRadius: 12
                )
            }

            Spacer().frame(height: 8)

            // ── 중간: 남은 예산 | 사용한 예산 (좌우 분할, 중앙 정렬) ──
            HStack(alignment: .center, spacing: 0) {
                // 좌측: 남은 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("남은 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)

                    Text(remainingText)
                        .font(.system(size: WidgetColorPalette.largeRemainingFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.6)
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
                        .font(.system(size: WidgetColorPalette.largeUsedFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 고양이 캐릭터
                Image(catImageName(for: entry.catMood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .padding(.leading, 8)
            }

            // 프로그레스 바
            WidgetProgressBar(ratio: entry.progressRatio, colors: colors)

            Spacer().frame(height: 12)

            // ── 오늘의 지출 헤더 ─────────────────────────────────────
            HStack {
                Text("오늘의 지출")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)

                Spacer()

                Text("\(entry.expenses.count)건")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer().frame(height: 8)

            // ── 지출 목록 ────────────────────────────────────────────
            if displayExpenses.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("아직 지출이 없어요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colors.secondaryText.opacity(0.6))
                    Spacer()
                }
                Spacer()
            } else {
                VStack(spacing: 6) {
                    ForEach(displayExpenses) { expense in
                        ExpenseRowView(expense: expense, colors: colors)
                    }

                    // 3건 초과 시 "외 N건 더보기" 표시
                    if entry.expenses.count > 3 {
                        HStack {
                            Spacer()
                            Text("외 \(entry.expenses.count - 3)건 더보기")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(colors.secondaryText.opacity(0.7))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                Spacer()
            }
        }

        content.widgetBackground(colors.background)
    }
}

#Preview(as: .systemLarge) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(
        date: Date(), total: 10000, used: 4800, remaining: 5200, streak: 12,
        expenses: [
            ExpenseItem(category: "점심", time: "12:30", amount: 3500),
            ExpenseItem(category: "아메리카노", time: "15:15", amount: 1300),
        ],
        catMood: "comfortable"
    )
    SimpleEntry(
        date: Date(), total: 10000, used: 11500, remaining: -1500, streak: 0,
        expenses: [
            ExpenseItem(category: "점심", time: "12:30", amount: 8500),
            ExpenseItem(category: "카페", time: "15:15", amount: 2800),
        ],
        catMood: "over"
    )
}
