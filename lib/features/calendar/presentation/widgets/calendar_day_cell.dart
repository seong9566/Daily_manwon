import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'calendar_amount_badge.dart';

/// 캘린더 날짜 셀 위젯
/// 날짜 숫자 + 선택/오늘 강조 표시
/// 과거 날짜이고 mood가 있을 경우 예산 상태 색상 바 표시
/// 선택 시: 날짜 원 + 색상 바를 아우르는 셀 전체 배경으로 하나의 선택 영역 표현
class CalendarDayCell extends StatelessWidget {
  /// 표시할 날짜
  final DateTime date;

  /// 오늘 날짜 여부
  final bool isToday;

  /// 선택된 날짜 여부
  final bool isSelected;

  /// 현재 표시 월과 같은 달인지 여부 (다른 달이면 흐리게)
  final bool isCurrentMonth;

  /// 미래 날짜 여부 (색상 바 표시 없음)
  final bool isFuture;

  /// 해당일 성공 여부 (null = 지출 없음, true = 성공, false = 실패)
  final bool? isSuccess;

  /// 해당일 예산 감정 상태 (null = 미래·데이터 없음 → 색상 바 숨김)
  final CharacterMood? mood;

  /// 당일 지출 합계 (원) — null이면 뱃지 숨김 (미래 날짜, 데이터 없음)
  final int? totalSpent;

  /// 탭 콜백
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.isFuture,
    this.isSuccess,
    this.mood,
    this.totalSpent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 텍스트 색상 결정
    final Color textColor;
    if (!isCurrentMonth) {
      // 다른 달 날짜는 표시하지 않음 (빈 셀)
      textColor = Colors.transparent;
    } else if (isFuture) {
      // 미래 날짜는 연한 회색
      textColor = isDark
          ? AppColors.darkTextSub.withAlpha(120)
          : AppColors.textSub;
    } else if (isSelected) {
      // 선택된 날: 라이트=white on black, 다크=black on white
      textColor = isDark ? AppColors.black : AppColors.white;
    } else if (isToday) {
      textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    } else {
      textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    }

    // 배경색 결정
    Color? bgColor;
    if (isSelected) {
      // 선택된 날: 라이트=black, 다크=white
      bgColor = isDark ? AppColors.white : AppColors.primary;
    } else if (isToday) {
      // 오늘(미선택): 연한 회색 배경
      bgColor = isDark ? AppColors.darkCard : AppColors.primaryLight;
    }

    return Semantics(
      button: isCurrentMonth,
      selected: isSelected,
      label: isCurrentMonth
          ? '${date.month}월 ${date.day}일'
              '${isToday ? ', 오늘' : ''}'
              '${isSuccess == true ? ', 성공' : isSuccess == false ? ', 초과' : ', 지출없음'}'
          : null,
      excludeSemantics: !isCurrentMonth,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isCurrentMonth ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          // 선택 시: 날짜 원 + 색상 바를 하나의 선택 영역으로 묶는 셀 배경
          // 날짜 원의 강한 fill 과 경쟁하지 않도록 alpha를 낮게 유지
          decoration: BoxDecoration(
            color: isSelected && isCurrentMonth
                ? (isDark ? AppColors.white : AppColors.primary)
                    .withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── 날짜 원형 배경 + 숫자 ──────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  isCurrentMonth ? '${date.day}' : '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: (isToday || isSelected)
                        ? FontWeight.w700
                        : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // ── 예산 상태 색상 바 (과거 날짜 + mood 있을 때만) ──────
              // 월간 개요: 고양이 대신 얇은 색상 바로 한 달 전체 패턴을 캘린더 히트맵처럼 표현
              //   comfortable / normal → 녹색 (budgetOK)
              //   danger              → 앰버 (budgetWarning)
              //   over                → 딥레드 (budgetOver)
              if (isCurrentMonth && !isFuture && mood != null && totalSpent != null)
                CalendarAmountBadge(
                  totalSpent: totalSpent!,
                  mood: mood!,
                  isDark: isDark,
                )
              else
                const SizedBox(height: 3),
            ],
          ),
        ),
      ),
    );
  }
}
