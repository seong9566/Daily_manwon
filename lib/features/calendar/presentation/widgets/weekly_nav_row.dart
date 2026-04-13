import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_utils.dart';

/// 주간 뷰 날짜 네비게이터 (이전주 / 주 범위 표시 / 다음주)
class WeeklyNavRow extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;

  const WeeklyNavRow({
    super.key,
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
  });

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
              AppDateUtils.weekRangeLabel(weekStart),
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
