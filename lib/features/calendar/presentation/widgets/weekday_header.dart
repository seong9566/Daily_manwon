import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 캘린더 상단 요일 레이블 행 (일~토)
class WeekdayHeader extends StatelessWidget {
  final bool isDark;

  const WeekdayHeader({super.key, required this.isDark});

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _weekdays.map((day) {
            final isWeekend = day == '일' || day == '토';
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: AppTypography.bodySmall.copyWith(
                    color: isWeekend
                        ? (day == '일'
                              ? AppColors.statusDanger.withAlpha(200)
                              : AppColors.categoryTransport.withAlpha(200))
                        : textSubColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
