import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 캘린더 셀 지출 금액 뱃지
///
/// 당일 지출 합계를 mood 색상 기반의 컬러 칩으로 표시한다.
/// - comfortable / newWeek → 초록 배경
/// - normal               → 앰버 배경
/// - danger               → 빨강 배경
/// - over                 → 짙은 빨강 배경
///
/// 월간([CalendarDayCell])과 주간([WeeklyCalendarDayCell]) 셀 공용으로 사용한다.
///
/// [totalSpent]은 반드시 0보다 커야 한다. 0원이면 호출부에서 뱃지를 생성하지 않는다.
class CalendarAmountBadge extends StatelessWidget {
  /// 당일 지출 합계 (원)
  final int totalSpent;

  /// 예산 감정 상태 — 뱃지 색상 결정
  final CharacterMood mood;

  /// 다크모드 여부
  final bool isDark;

  const CalendarAmountBadge({
    super.key,
    required this.totalSpent,
    required this.mood,
    required this.isDark,
  }) : assert(totalSpent > 0, 'totalSpent > 0 이어야 합니다. 0원이면 호출부에서 뱃지를 생성하지 않아야 합니다.');

  @override
  Widget build(BuildContext context) {
    final color = mood.getColor(isDark: isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        CurrencyFormatter.formatNumberOnly(totalSpent),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
