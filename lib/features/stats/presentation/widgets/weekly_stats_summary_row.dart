import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 주간 핵심 수치 3-column 카드 (총 지출 · 성공일 · 일평균)
class WeeklyStatsSummaryRow extends StatelessWidget {
  final int totalSpent;
  final int successDays;
  final int totalDays;
  final bool isDark;

  const WeeklyStatsSummaryRow({
    super.key,
    required this.totalSpent,
    required this.successDays,
    required this.totalDays,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final avgDaily = totalDays > 0 ? totalSpent ~/ totalDays : 0;

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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
        children: [
          _StatCell(
            label: '총 지출',
            value: CurrencyFormatter.format(totalSpent),
            textMain: textMain,
            textSub: textSub,
          ),
          VerticalDivider(color: divider, width: 1, thickness: 1),
          _StatCell(
            label: '성공일',
            value: totalDays > 0 ? '$successDays/$totalDays일' : '-',
            textMain: textMain,
            textSub: textSub,
          ),
          VerticalDivider(color: divider, width: 1, thickness: 1),
          _StatCell(
            label: '일평균',
            value: CurrencyFormatter.format(avgDaily),
            textMain: textMain,
            textSub: textSub,
          ),
        ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color textMain;
  final Color textSub;

  const _StatCell({
    required this.label,
    required this.value,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: textSub,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
