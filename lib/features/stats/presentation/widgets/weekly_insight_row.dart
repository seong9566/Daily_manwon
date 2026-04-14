import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 주간 인사이트 카드 (전주 비교 + 최다 카테고리)
/// [prevWeekTotalSpent]: null이면 전주 비교 행 미표시
/// [topCategoryIndex]: null이면 최다 카테고리 행 미표시
class WeeklyInsightRow extends StatelessWidget {
  final int currentWeekTotalSpent;
  final int? prevWeekTotalSpent;
  final int? topCategoryIndex;
  final bool isDark;
  final bool isFutureWeek;

  const WeeklyInsightRow({
    super.key,
    required this.currentWeekTotalSpent,
    required this.prevWeekTotalSpent,
    required this.topCategoryIndex,
    required this.isDark,
    this.isFutureWeek = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrevWeek = prevWeekTotalSpent != null;
    final hasTopCategory = topCategoryIndex != null;

    if (!hasPrevWeek && !hasTopCategory) return const SizedBox.shrink();

    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통계 요약',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (hasPrevWeek)
            _PrevWeekRow(
              current: currentWeekTotalSpent,
              prev: prevWeekTotalSpent!,
              isDark: isDark,
              isFutureWeek: isFutureWeek,
            ),
          if (hasPrevWeek && hasTopCategory) const SizedBox(height: 8),
          if (hasTopCategory)
            _TopCategoryRow(
              categoryIndex: topCategoryIndex!,
              textMain: textMain,
              textSub: textSub,
            ),
        ],
      ),
    );
  }
}

class _PrevWeekRow extends StatelessWidget {
  final int current;
  final int prev;
  final bool isDark;
  final bool isFutureWeek;

  const _PrevWeekRow({
    required this.current,
    required this.prev,
    required this.isDark,
    required this.isFutureWeek,
  });

  @override
  Widget build(BuildContext context) {
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

    if (isFutureWeek) {
      return Text(
        '아직 집계 되지 않았습니다',
        style: AppTypography.bodySmall.copyWith(
          color: textSub,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      );
    }

    final diff = current - prev;
    final isLess = diff < 0;

    final label = isLess
        ? '↓ 저번주보다 ${CurrencyFormatter.format(diff.abs())} 적게 씀'
        : diff == 0
        ? '저번주와 동일하게 씀'
        : '↑ 저번주보다 ${CurrencyFormatter.format(diff)} 더 씀';
    final color = isLess
        ? AppColors.statusComfortableStrong
        : diff == 0
        ? AppColors.budgetWarning
        : AppColors.budgetDanger;

    return Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

class _TopCategoryRow extends StatelessWidget {
  final int categoryIndex;
  final Color textMain;
  final Color textSub;

  const _TopCategoryRow({
    required this.categoryIndex,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.values[categoryIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : category.chipColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Image.asset(
            category.assetPath,
            width: 24,
            height: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '최다 지출: ${category.label}',
          style: AppTypography.bodySmall.copyWith(
            color: textMain,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
