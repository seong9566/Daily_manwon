import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 월간 뷰 날짜 네비게이터 (이전달 / 월 표시 / 다음달)
class MonthlyNavRow extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;

  const MonthlyNavRow({
    super.key,
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
  });

  String get _label {
    final now = DateTime.now();
    if (selectedMonth.year == now.year) {
      return '${selectedMonth.month}월';
    }
    return '${selectedMonth.year}년 ${selectedMonth.month}월';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPrev,
            icon: Icon(Icons.chevron_left, color: textColor, size: 24),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _label,
              style: AppTypography.titleMedium.copyWith(color: textColor),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: textColor, size: 24),
          ),
        ),
      ],
    );
  }
}
