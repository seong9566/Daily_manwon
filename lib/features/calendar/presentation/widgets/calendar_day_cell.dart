import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 캘린더 날짜 셀 위젯
/// 날짜 숫자 + 하단 성공/실패 dot + 선택/오늘 강조 표시
/// 과거 날짜이고 mood가 있을 경우 미니 고양이 이미지 표시
class CalendarDayCell extends StatelessWidget {
  /// 표시할 날짜
  final DateTime date;

  /// 오늘 날짜 여부
  final bool isToday;

  /// 선택된 날짜 여부
  final bool isSelected;

  /// 현재 표시 월과 같은 달인지 여부 (다른 달이면 흐리게)
  final bool isCurrentMonth;

  /// 미래 날짜 여부 (dot 표시 없음)
  final bool isFuture;

  /// 해당일 성공 여부 (null = 지출 없음, true = 성공, false = 실패)
  final bool? isSuccess;

  /// 해당일 고양이 감정 상태 (null = 표시 안 함)
  final CharacterMood? mood;

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
    } else if (isToday && !isSelected) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── 날짜 원형 배경 + 숫자 ──────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
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
            const SizedBox(height: 2),

            // ── 미니 고양이 이미지 (과거 날짜 + mood 있을 때만) ──────
            if (isCurrentMonth && !isFuture && mood != null)
              ColorFiltered(
                colorFilter: isDark
                    ? const ColorFilter.matrix([
                        -1, 0, 0, 0, 255,
                        0, -1, 0, 0, 255,
                        0, 0, -1, 0, 255,
                        0, 0, 0, 1, 0,
                      ])
                    : const ColorFilter.matrix([
                        1, 0, 0, 0, 0,
                        0, 1, 0, 0, 0,
                        0, 0, 1, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                child: Image.asset(
                  mood!.assetPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              )
            else
              const SizedBox(height: 20),

            const SizedBox(height: 1),

            // ── 성공/실패 dot ─────────────────────────
            // 미래 또는 다른 달은 dot 없음
            if (isCurrentMonth && !isFuture && isSuccess != null)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  // 성공: 검정(다크: 흰색), 실패: 빨강
                  color: isSuccess!
                      ? (isDark ? AppColors.white.withValues(alpha: 0.7) : AppColors.textMain)
                      : AppColors.statusDanger,
                  shape: BoxShape.circle,
                ),
              )
            else
              // dot 자리 유지 — 레이아웃 안정을 위해 투명 점 유지
              const SizedBox(width: 5, height: 5),
          ],
        ),
      ),
    );
  }
}
