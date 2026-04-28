import 'package:flutter/material.dart';


import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/presentation/widgets/expense_list_item.dart';
import '../models/calendar_expense_item.dart';

/// 선택된 날짜의 지출 내역 섹션
/// 캘린더 하단에 표시되며, 날짜 헤더 + 총액 + 지출 리스트로 구성된다
class DailyExpenseDetail extends StatelessWidget {
  /// 선택된 날짜
  final DateTime date;

  /// 해당 날짜의 지출 목록
  final List<CalendarExpenseItem> expenses;

  /// 지출 항목 탭 시 호출되는 콜백
  final void Function(CalendarExpenseItem expense)? onExpenseTap;

  /// 기본 예산 (설정된 하루 예산)
  final int? baseAmount;

  /// 이월 포함 실제 예산
  final int? effectiveBudget;

  const DailyExpenseDetail({
    super.key,
    required this.date,
    required this.expenses,
    this.onExpenseTap,
    this.baseAmount,
    this.effectiveBudget,
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

        // ── 예산 구성 카드 (이월이 있을 때: 양수·음수 모두 표시) ───────────
        if (effectiveBudget != null &&
            baseAmount != null &&
            effectiveBudget! != baseAmount!) ...[
          _BudgetBreakdownCard(
            baseAmount: baseAmount!,
            effectiveBudget: effectiveBudget!,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
        ],

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
              final item = expenses[index];
              return ExpenseListItem(
                expense: item.toExpenseEntity(),
                onTap: onExpenseTap != null ? () => onExpenseTap!(item) : null,
              );
            },
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _BudgetBreakdownCard extends StatelessWidget {
  final int baseAmount;
  final int effectiveBudget;
  final bool isDark;

  const _BudgetBreakdownCard({
    required this.baseAmount,
    required this.effectiveBudget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final carryOver = effectiveBudget - baseAmount;
    final isNegative = carryOver < 0;
    final carryOverColor = isNegative ? AppColors.budgetDanger : AppColors.accent;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNegative
            ? AppColors.budgetDanger.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark ? AppColors.darkCard : AppColors.primaryLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘 예산 구성',
            style: AppTypography.bodySmall.copyWith(
              color: textSubColor,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          // 기본 예산: 초록 dot — 기본 예산 구간 비율 표시
          _BudgetRow(
            label: '기본 예산',
            amount: baseAmount,
            dotColor: AppColors.statusComfortableStrong,
            isDark: isDark,
          ),
          const SizedBox(height: 4),
          _BudgetRow(
            label: isNegative ? '초과이월' : '이월',
            // carryOver.abs() 필수 — prefix와 이중 마이너스 방지
            amount: carryOver.abs(),
            prefix: isNegative ? '-' : '+',
            dotColor: carryOverColor,
            isDark: isDark,
          ),
          Divider(height: 16, thickness: 1, color: dividerColor),
          _BudgetRow(
            label: '합계',
            amount: effectiveBudget,
            isBold: true,
            isDark: isDark,
            // 합계가 음수이면 빨간색으로 강조
            textColor: effectiveBudget < 0 ? AppColors.budgetDanger : null,
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final int amount;
  final String prefix;
  final Color? dotColor;
  final bool isBold;
  final bool isDark;
  final Color? textColor;

  const _BudgetRow({
    required this.label,
    required this.amount,
    required this.isDark,
    this.prefix = '',
    this.dotColor,
    this.isBold = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Row(
      children: [
        if (dotColor != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor!, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: textSubColor,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          '$prefix${CurrencyFormatter.formatWithWon(amount)}',
          style: AppTypography.bodySmall.copyWith(
            color: textColor ?? dotColor ?? textMainColor,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
