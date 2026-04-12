import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

/// 예산과 지출로 오늘의 고양이 감정을 계산한다
CharacterMood calculateMood(int budget, int spent) {
  if (budget <= 0) return CharacterMood.danger;
  final ratio = (budget - spent) / budget;
  return CharacterMood.fromRatio(ratio);
}

/// mood → 캘린더 셀 색상 바 색상 (홈/주간/월간 공통)
///
/// comfortable / newWeek → 초록 (budgetComfortable)
/// normal               → 앰버 (budgetWarning)
/// danger               → 레드 (budgetDanger)
/// over                 → 딥레드 (budgetOver)
Color moodBarColor(CharacterMood mood, {bool isDark = false}) {
  return switch (mood) {
    CharacterMood.comfortable || CharacterMood.newWeek =>
      isDark ? AppColors.budgetComfortableDark : AppColors.budgetComfortable,
    CharacterMood.normal => AppColors.budgetWarning,
    CharacterMood.danger => AppColors.budgetDanger,
    CharacterMood.over   => AppColors.budgetOver,
  };
}
