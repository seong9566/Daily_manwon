import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 주간 캘린더 셀
///
/// - 상단: 날짜 숫자 (원형 배경, 오늘/선택 강조)
/// - 중단: 지출 금액 텍스트(있을 경우) 또는 도토리 아이콘(지출 없는 과거 날짜)
/// - 하단: 성공/실패 색상 dot
class WeeklyCalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isFuture;

  /// null = 미래 (dot 없음)
  final bool? isSuccess;
  final int? totalAmount;

  /// 지출 없는 과거 날짜 = true → 도토리 아이콘 표시
  final bool showAcornIcon;
  final VoidCallback? onTap;
  final bool isDark;

  /// 해당일 고양이 감정 상태 (null = 표시 안 함)
  final CharacterMood? mood;

  const WeeklyCalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.isSuccess,
    required this.totalAmount,
    required this.showAcornIcon,
    this.onTap,
    required this.isDark,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DateCircle(
              date: date,
              isToday: isToday,
              isSelected: isSelected,
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            _MiddleContent(
              totalAmount: totalAmount,
              showAcornIcon: showAcornIcon,
              isFuture: isFuture,
              isDark: isDark,
              mood: mood,
            ),
            const SizedBox(height: 4),
            _StatusDot(isSuccess: isSuccess),
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
    Color? bgColor;
    Color textColor;
    BoxBorder? border;

    if (isSelected) {
      bgColor = isDark ? AppColors.white : AppColors.primary;
      textColor = isDark ? AppColors.black : AppColors.white;
    } else if (isToday) {
      bgColor = isDark ? AppColors.darkCard : AppColors.primaryLight;
      textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    } else {
      bgColor = Colors.transparent;
      textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
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

class _MiddleContent extends StatelessWidget {
  final int? totalAmount;
  final bool showAcornIcon;
  final bool isFuture;
  final bool isDark;
  final CharacterMood? mood;

  const _MiddleContent({
    required this.totalAmount,
    required this.showAcornIcon,
    required this.isFuture,
    required this.isDark,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    if (isFuture) {
      return const SizedBox(height: 16);
    }

    // 과거 날짜이고 mood가 있으면 미니 고양이 이미지 표시
    if (mood != null) {
      return Image.asset(
        mood!.assetPath,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        color: isDark ? AppColors.white : AppColors.black,
      );
    }

    // if (showAcornIcon) {
    //   return const Text(
    //     '🌰',
    //     style: TextStyle(fontSize: 14),
    //   ).animate().scale(duration: 300.ms, curve: Curves.easeOut);
    // }

    if (totalAmount != null && totalAmount! > 0) {
      return Text(
        CurrencyFormatter.formatWithWon(totalAmount!),
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextSub : AppColors.textSub,
          fontSize: 10,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return const SizedBox(height: 16);
  }
}

class _StatusDot extends StatelessWidget {
  final bool? isSuccess;

  const _StatusDot({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    if (isSuccess == null) {
      return const SizedBox(height: 6);
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkTextMain
            : isSuccess!
            ? AppColors.budgetComfortable
            : AppColors.budgetDanger,
      ),
    );
  }
}
