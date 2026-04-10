//
//  ExpenseRowView.swift
//  DailyHomeWidget
//

import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 지출 항목 행 (Large 위젯용)
// ─────────────────────────────────────────────────────────────────────────────
struct ExpenseRowView: View {
    let expense: ExpenseItem
    let colors: WidgetColorPalette

    var body: some View {
        HStack(spacing: 8) {
            // 아이콘 이미지
            Image(expense.categoryAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .padding(5)
                .background(
                    Circle()
                        .fill(colors.accentBg)
                )

            // 카테고리 + 시간
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)

                Text(expense.time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(colors.secondaryText)
            }

            Spacer()

            // 금액 (음수 표시)
            Text("-\(formatNumber(expense.amount))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.vertical, 4)
    }
}
