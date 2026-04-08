import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

// ── 월 네비게이션 위젯 ───────────────────────────────────────────

class MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final bool isDark;
  final Color textMainColor;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthNavigator({
    super.key,
    required this.selectedMonth,
    required this.isDark,
    required this.textMainColor,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        '${selectedMonth.year}. ${selectedMonth.month.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          tooltip: '이전 달',
          icon: Icon(Icons.chevron_left_rounded, color: textMainColor, size: 28),
        ),
        const SizedBox(width: 8),
        Text(
          monthLabel,
          style: AppTypography.titleMedium.copyWith(color: textMainColor),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onNext,
          tooltip: '다음 달',
          icon: Icon(Icons.chevron_right_rounded, color: textMainColor, size: 28),
        ),
      ],
    );
  }
}
