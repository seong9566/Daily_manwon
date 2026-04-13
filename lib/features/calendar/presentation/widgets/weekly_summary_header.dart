import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 주간 예산 요약 헤더
///
/// 총지출, 일평균, 절약일 수를 표시한다.
/// 총지출 색상은 [weeklyBudget] 대비 잔액 비율로 결정한다 (홈과 동일한 ratio 기반 로직).
class WeeklySummaryHeader extends StatelessWidget {
  final int totalSpent;
  final int dailyAverage;
  final int savingDays;
  final int totalDays;

  /// 이번 주 오늘까지의 예산 합산 (0이면 색상 fallback)
  final int weeklyBudget;

  final bool isDark;

  const WeeklySummaryHeader({
    super.key,
    required this.totalSpent,
    required this.dailyAverage,
    required this.savingDays,
    required this.totalDays,
    required this.weeklyBudget,
    required this.isDark,
  });

  /// 잔액 비율 기반 총지출 색상 (CharacterMood.fromRatio 통일)
  // Color _totalSpentColor() {
  //   if (weeklyBudget <= 0) {
  //     return CharacterMood.comfortable.getColor(isDark: isDark);
  //   }
  //   return CharacterMood.fromSpent(
  //     weeklyBudget,
  //     totalSpent,
  //   ).getColor(isDark: isDark);
  // }

  @override
  Widget build(BuildContext context) {
    final subTextColor = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final mainTextColor = isDark ? AppColors.darkTextMain : AppColors.textMain;

    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            label: '이번주 총 지출',
            value: CurrencyFormatter.formatWithWon(totalSpent),
            valueColor: mainTextColor,
            labelColor: subTextColor,
          ),
        ),
        _Divider(isDark: isDark),
        Expanded(
          child: _SummaryItem(
            label: '일평균',
            value: CurrencyFormatter.formatWithWon(dailyAverage),
            valueColor: mainTextColor,
            labelColor: subTextColor,
          ),
        ),
        _Divider(isDark: isDark),
        Expanded(
          child: _SummaryItem(
            label: '절약일',
            value: '$savingDays / $totalDays일',
            valueColor: mainTextColor,
            labelColor: subTextColor,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: labelColor)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.darkDivider : AppColors.border,
    );
  }
}
