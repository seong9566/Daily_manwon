import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/budget_mood_calculator.dart';

/// 주간 캘린더 셀
///
/// 월간 뷰의 1주 슬라이스 — 동일한 시각 언어(날짜 원 + 색상 바)로 일관성 유지
/// - 상단: 날짜 숫자 (원형 배경, 오늘/선택 강조)
/// - 하단: 예산 상태 색상 바 (comfortable→녹 / normal→앰버 / danger→레드 / over→딥레드)
class WeeklyCalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;
  final VoidCallback? onTap;

  /// 해당일 예산 감정 상태 (null = 미래·데이터 없음 → 색상 바 숨김)
  final CharacterMood? mood;

  /// 예산 잔여 비율 (0.0 ~ 1.0) — LinearProgressIndicator fill 값
  final double? remainingRatio;

  const WeeklyCalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    this.onTap,
    this.mood,
    this.remainingRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: 48,
        // 선택 시: 날짜 원 + 색상 바를 하나의 선택 영역으로 묶는 셀 배경
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.white : AppColors.primary)
                  .withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DateCircle(
              date: date,
              isToday: isToday,
              isSelected: isSelected,
              isDark: isDark,
            ),
            const SizedBox(height: 6),

            // 예산 상태 색상 바 — 월간 뷰와 동일한 히트맵 방식
            if (!isFuture && mood != null && remainingRatio != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1.5),
                  child: LinearProgressIndicator(
                    value: remainingRatio!.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: isDark
                        ? AppColors.darkDivider
                        : AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      moodBarColor(mood!, isDark: isDark),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}

class _DateCircle extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isDark;

  const _DateCircle({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;

    // 선택 상태는 셀 배경(alpha 0.07)으로만 표현 — 원 fill 없음
    if (isToday) {
      bgColor = isDark ? AppColors.darkCard : AppColors.primaryLight;
      textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    } else {
      bgColor = Colors.transparent;
      textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: AppTypography.bodyMedium.copyWith(
            color: textColor,
            fontWeight: (isToday || isSelected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
