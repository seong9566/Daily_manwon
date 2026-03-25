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
  // 캐릭터 감정 상태 임계값
  // 남은 금액 기준으로 다람쥐 캐릭터의 표정이 변한다
  // -------------------------

  /// 행복 상태 최소 잔액 - 이 금액 이상이면 여유 있는 표정
  static const int happyThreshold = 5000;

  /// 걱정 상태 최소 잔액 - 이 금액 이상~행복 미만이면 걱정 표정
  /// 이 값 미만은 위험(sad) 상태로 분류한다
  static const int worriedThreshold = 1000;
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

  /// 카테고리 대표 아이콘 (Material Icons)
  IconData get icon {
    return switch (this) {
      ExpenseCategory.food => Icons.restaurant_rounded,
      ExpenseCategory.transport => Icons.directions_bus_rounded,
      ExpenseCategory.cafe => Icons.local_cafe_rounded,
      ExpenseCategory.shopping => Icons.shopping_bag_rounded,
      ExpenseCategory.etc => Icons.more_horiz_rounded,
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

/// 캐릭터 감정 상태
/// 남은 잔액 기준으로 계산된다
enum CharacterMood {
  happy,
  worried,
  sad;

  /// 남은 금액을 받아 적절한 감정 상태를 반환한다
  static CharacterMood fromRemainingBudget(int remaining) {
    if (remaining >= AppConstants.happyThreshold) {
      return CharacterMood.happy;
    } else if (remaining >= AppConstants.worriedThreshold) {
      return CharacterMood.worried;
    } else {
      return CharacterMood.sad;
    }
  }

  /// 감정 상태에 대응하는 색상
  Color get statusColor {
    return switch (this) {
      CharacterMood.happy => AppColors.statusComfortable,
      CharacterMood.worried => AppColors.statusWarning,
      CharacterMood.sad => AppColors.statusDanger,
    };
  }

  /// 말풍선 메시지 (예시 - 실제 다국어 처리 시 l10n으로 이전)
  String get bubbleMessage {
    return switch (this) {
      CharacterMood.happy => '오늘 예산이 넉넉해요!',
      CharacterMood.worried => '슬슬 아껴써야 할 것 같아요...',
      CharacterMood.sad => '오늘 예산을 거의 다 썼어요 ㅠㅠ',
    };
  }
}
