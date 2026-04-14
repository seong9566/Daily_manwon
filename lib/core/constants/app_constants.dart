import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 앱 전역 상수 정의
abstract final class AppConstants {
  // -------------------------
  // 예산 설정
  // -------------------------

  /// 하루 기본 예산 (원)
  static const int dailyBudget = 10000;

  // -------------------------
  // 캐릭터 감정 상태 임계값 (비율 기준)
  // -------------------------
  /// 행복 상태 최소 잔액 비율 (50% 이상)
  static const double comfortableRatioThreshold = 0.5;

  /// 걱정 상태 최소 잔액 비율 (30% 이상)
  static const double normalRatioThreshold = 0.3;

  /// 위험 상태 최소 잔액 비율 (0% 이상)
  static const double dangerRatioThreshold = 0.0;
}

/// 지출 카테고리 분류
enum ExpenseCategory {
  food,
  transport,
  cafe,
  shopping,
  etc;

  /// 카테고리 한글 레이블
  String get label {
    return switch (this) {
      ExpenseCategory.food => '식비',
      ExpenseCategory.transport => '교통',
      ExpenseCategory.cafe => '카페',
      ExpenseCategory.shopping => '쇼핑',
      ExpenseCategory.etc => '기타',
    };
  }

  /// 카테고리 손그림 아이콘 이미지 경로
  /// 투명 배경 + 순수 검정 라인아트 PNG (_clean 포맷)
  String get assetPath {
    return switch (this) {
      ExpenseCategory.food => 'assets/images/category_images/food_clean.png',
      ExpenseCategory.transport =>
        'assets/images/category_images/car_clean.png',
      ExpenseCategory.cafe => 'assets/images/category_images/coffee_clean.png',
      ExpenseCategory.shopping =>
        'assets/images/category_images/shopping_clean.png',
      ExpenseCategory.etc => 'assets/images/category_images/etc_clean.png',
    };
  }

  /// 카테고리 배경 칩 색상 (디자인 가이드 Section 5)
  Color get chipColor {
    return switch (this) {
      ExpenseCategory.food => AppColors.chipFood,
      ExpenseCategory.transport => AppColors.chipTransport,
      ExpenseCategory.cafe => AppColors.chipCafe,
      ExpenseCategory.shopping => AppColors.chipShopping,
      ExpenseCategory.etc => AppColors.chipEtc,
    };
  }

  /// 카테고리 대표 색상
  Color get color {
    return switch (this) {
      ExpenseCategory.food => AppColors.categoryFood,
      ExpenseCategory.transport => AppColors.categoryTransport,
      ExpenseCategory.cafe => AppColors.categoryCafe,
      ExpenseCategory.shopping => AppColors.categoryShopping,
      ExpenseCategory.etc => AppColors.categoryEtc,
    };
  }
}

/// 고양이 캐릭터 감정 상태 — 잔액 비율(remaining/total) 기준
enum CharacterMood {
  comfortable, // 여유: 잔액 >= 50%
  normal, // 보통: 잔액 10~50%
  danger, // 위험: 잔액 0~10%
  over, // 초과: 잔액 < 0%
  newWeek; // 새 주 시작

  /// 잔액 비율(remaining / total)로 감정 상태를 결정한다
  static CharacterMood fromRatio(double ratio) {
    if (ratio >= AppConstants.comfortableRatioThreshold) {
      return CharacterMood.comfortable;
    }
    if (ratio >= AppConstants.normalRatioThreshold) return CharacterMood.normal;
    if (ratio >= AppConstants.dangerRatioThreshold) return CharacterMood.danger;
    return CharacterMood.over;
  }

  /// 잔액(remaining)과 총 예산(total)을 기준으로 감정 상태를 결정한다
  static CharacterMood fromRemaining(int remaining, int total) {
    if (total <= 0) {
      return remaining >= 0 ? CharacterMood.comfortable : CharacterMood.danger;
    }
    return fromRatio(remaining / total);
  }

  /// 예산(budget)과 지출(spent)을 기준으로 감정 상태를 결정한다
  static CharacterMood fromSpent(int budget, int spent) {
    if (budget <= 0) return CharacterMood.danger;
    return fromRatio((budget - spent) / budget);
  }

  /// 감정 상태별 고양이 이미지 경로
  String get assetPath {
    return switch (this) {
      CharacterMood.comfortable => 'assets/images/character/여유_clean.png',
      CharacterMood.normal => 'assets/images/character/보통_clean.png',
      CharacterMood.danger => 'assets/images/character/위험_clean.png',
      CharacterMood.over => 'assets/images/character/초과_clean.png',
      CharacterMood.newWeek => 'assets/images/character/new_week_clean.png',
    };
  }

  /// 감정 상태에 대응하는 색상
  Color getColor({bool isDark = false}) {
    return switch (this) {
      CharacterMood.comfortable || CharacterMood.newWeek =>
        isDark ? AppColors.budgetComfortableDark : AppColors.budgetComfortable,
      CharacterMood.normal => AppColors.budgetWarning,
      CharacterMood.danger => AppColors.budgetDanger,
      CharacterMood.over => AppColors.budgetOver,
    };
  }

  /// 한글 레이블
  String get label {
    return switch (this) {
      CharacterMood.comfortable => '여유',
      CharacterMood.normal => '보통',
      CharacterMood.danger => '위험',
      CharacterMood.over => '초과',
      CharacterMood.newWeek => '새 주',
    };
  }

  /// 말풍선에 표시될 한마디 코멘트
  String get comment {
    return switch (this) {
      CharacterMood.comfortable => '여유롭네요~',
      CharacterMood.normal => '적당히 쓰고 있어요',
      CharacterMood.danger => '조금 아껴야 해요...',
      CharacterMood.over => '으아, 많이 썼어요!',
      CharacterMood.newWeek => '새로운 한주가 시작됐어!',
    };
  }
}
