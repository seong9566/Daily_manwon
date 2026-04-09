import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expense/domain/entities/expense.dart';

/// 선택된 날짜의 지출 내역 섹션
/// 캘린더 하단에 표시되며, 날짜 헤더 + 총액 + 지출 리스트로 구성된다
class DailyExpenseDetail extends StatelessWidget {
  /// 선택된 날짜
  final DateTime date;

  /// 해당 날짜의 지출 목록
  final List<ExpenseEntity> expenses;

  /// 지출 항목 탭 시 호출되는 콜백
  final void Function(ExpenseEntity expense)? onExpenseTap;

  const DailyExpenseDetail({
    super.key,
    required this.date,
    required this.expenses,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    // 총 지출 합계
    final total = expenses.fold<int>(0, (sum, e) => sum + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 구분선 ───────────────────────────────────
        Divider(height: 1, thickness: 1, color: dividerColor),
        const SizedBox(height: 16),

        // ── 날짜 헤더 + 총액 ─────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '${date.month}월 ${date.day}일',
                style: AppTypography.titleMedium.copyWith(
                  color: textMainColor,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (expenses.isNotEmpty)
                Text(
                  // 총 지출을 "-4,800원" 형식으로 표시
                  '-${CurrencyFormatter.formatWithWon(total)}',
                  style: AppTypography.bodyLarge.copyWith(
                    color: textMainColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 지출 목록 또는 빈 상태 ────────────────────
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              '이 날은 지출이 없어요',
              style: AppTypography.bodyMedium.copyWith(color: textSubColor),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            // 부모 스크롤에 위임 — 독립 스크롤 방지
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: dividerColor,
            ),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final categoryIndex = expense.category.clamp(
                0,
                ExpenseCategory.values.length - 1,
              );
              final category = ExpenseCategory.values[categoryIndex];

              return Semantics(
                label: '${category.label} ${CurrencyFormatter.formatWithWon(expense.amount)}원',
                button: onExpenseTap != null,
                child: InkWell(
                  onTap: onExpenseTap != null ? () => onExpenseTap!(expense) : null,
                  child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                  children: [
                    // 카테고리 이미지
                    Image.asset(
                      category.assetPath,
                      width: 24,
                      height: 24,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                    const SizedBox(width: 12),

                    // 카테고리 이름
                    Text(
                      category.label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: textMainColor,
                      ),
                    ),

                    const Spacer(),

                    // 금액
                    Text(
                      '-${CurrencyFormatter.formatWithWon(expense.amount)}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: textMainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ),
                ),
              );
            },
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}
