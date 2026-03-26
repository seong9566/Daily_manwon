import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 시간대별 배경색 유틸리티 (U-03)
/// 7개 시간대에 따라 미묘하게 다른 배경 톤을 반환한다
abstract final class TimeBasedTheme {
  /// 현재 시간대에 맞는 배경색을 반환한다
  /// [isOverBudget] true이면 핑크틴트 반환
  /// [isDarkMode] true이면 다크 배경 고정
  static Color getBackgroundColor({
    bool isOverBudget = false,
    required bool isDarkMode,
    DateTime? now,
  }) {
    // 다크모드는 항상 동일한 배경
    if (isDarkMode) return AppColors.darkBackground;

    // 예산 초과 시 핑크 틴트
    if (isOverBudget) return AppColors.bgOverBudget;

    final hour = (now ?? DateTime.now()).hour;

    // 00:00~04:59 새벽 — 딥 블루그레이
    if (hour < 5) return AppColors.bgDawn;
    // 05:00~08:59 아침 — 따뜻한 크림
    if (hour < 9) return AppColors.bgMorning;
    // 09:00~11:59 오전 — 밝은 화이트
    if (hour < 12) return AppColors.bgForenoon;
    // 12:00~13:59 점심 — 연한 민트 화이트
    if (hour < 14) return AppColors.bgNoon;
    // 14:00~16:59 오후 — 밝은 화이트
    if (hour < 17) return AppColors.bgAfternoon;
    // 17:00~20:59 저녁 — 따뜻한 앰버
    if (hour < 21) return AppColors.bgEvening;
    // 21:00~23:59 밤 — 차분한 블루그레이
    return AppColors.bgNight;
  }

  /// 새벽(0~4시) 시간대인지 여부 — 텍스트 색상 결정용
  static bool isDawnHour({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    return hour < 5;
  }

  /// 시간대에 맞는 주 텍스트 색상
  static Color getTextColor({required bool isDarkMode, DateTime? now}) {
    if (isDarkMode) return AppColors.darkTextMain;
    if (isDawnHour(now: now)) return AppColors.textDawn;
    return AppColors.textPrimary;
  }

  /// 시간대에 맞는 보조 텍스트 색상
  static Color getSubTextColor({required bool isDarkMode, DateTime? now}) {
    if (isDarkMode) return AppColors.darkTextSub;
    if (isDawnHour(now: now)) return AppColors.textDawnSub;
    return AppColors.textSecondary;
  }
}
