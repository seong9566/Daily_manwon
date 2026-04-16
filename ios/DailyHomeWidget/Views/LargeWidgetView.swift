//
//  LargeWidgetView.swift
//  DailyHomeWidget
//

import AppIntents
import SwiftUI
import WidgetKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Large 4×4)
// 레이아웃:
//  ┌──────────────────────────────────────┐
//  │ 총 예산 ₩10,000            🔥 12일  │
//  │ 남은 예산       │  사용한 예산       │
//  │ ₩5,200 (큰글씨) │  ₩4,800   [고양이]│
//  │──────────────────────────────────────│
//  │ 빠른 입력                            │
//  │ [☕ 3,500] [🚌 1,500]               │
//  │ [🍱 4,000] [💳 2,000]               │
//  └──────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeLargeView: View {
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

    private var totalText: String {
        "총 예산 ₩\(formatNumber(entry.total))"
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
                        .minimumScaleFactor(0.6)  // Medium(0.5)보다 큰 최솟값 — Large 캔버스 기준
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
                        .minimumScaleFactor(0.6)  // Medium(0.5)보다 큰 최솟값 — Large 캔버스 기준
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

            // ── 빠른 입력 헤더 + "+" 버튼 (항상 표시) ─────────────────
            Spacer().frame(height: 12)

            HStack {
                Text("빠른 입력")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                Spacer()
                Button(intent: OpenAddExpenseIntent()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                }
                .buttonStyle(.plain)
            }

            Spacer().frame(height: 8)

            if !entry.favorites.isEmpty {
                // 즐겨찾기 버튼 — 최대 4개, 2×2 그리드
                let displayFavs = Array(entry.favorites.prefix(4))
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                    ],
                    spacing: 8
                ) {
                    ForEach(displayFavs) { fav in
                        Button(intent: AddFavoriteExpenseIntent(
                            favoriteId: fav.id,
                            amount: fav.amount,
                            category: fav.category,
                            memo: fav.memo
                        )) {
                            VStack(spacing: 4) {
                                Image(fav.categoryAssetName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .foregroundColor(colors.primaryText)
                                    .frame(width: 22, height: 22)
                                Text(fav.formattedAmount)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(colors.primaryText)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colors.accentBg)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                // 즐겨찾기 없을 때 안내 메시지
                HStack {
                    Spacer()
                    Text("즐겨찾기를 추가하면 빠르게 기록할 수 있어요")
                        .font(.system(size: 11))
                        .foregroundColor(colors.secondaryText.opacity(0.6))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }

            Spacer()
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
        catMood: "comfortable",
        favorites: [
            FavoriteItem(id: 1, amount: 3500, category: 2, memo: ""),
            FavoriteItem(id: 2, amount: 1500, category: 1, memo: ""),
        ]
    )
    SimpleEntry(
        date: Date(), total: 10000, used: 11500, remaining: -1500, streak: 0,
        expenses: [
            ExpenseItem(category: "점심", time: "12:30", amount: 8500),
            ExpenseItem(category: "카페", time: "15:15", amount: 2800),
        ],
        catMood: "over",
        favorites: [
            FavoriteItem(id: 1, amount: 3500, category: 2, memo: ""),
            FavoriteItem(id: 2, amount: 1500, category: 1, memo: ""),
        ]
    )
}
