import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Pretendard 폰트 기반 텍스트 스타일 체계
/// 화면 내 역할에 따라 크기와 굵기를 명확히 구분한다
abstract final class AppTypography {
  static const String _fontFamily = 'Pretendard';

  // -------------------------
  // Display - 핵심 수치 강조
  // -------------------------

  /// 남은 금액 등 화면 중앙의 핵심 숫자 표시용
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textMain,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// 지출 입력 화면 금액 입력 숫자 표시용
  static const TextStyle displayAmount = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textMain,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// 금액 단위 레이블 (₩, 원) 표시용
  static const TextStyle amountUnit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textSub,
    height: 1.4,
  );

  // -------------------------
  // Title - 섹션 구분
  // -------------------------

  /// 섹션 타이틀, 카드 제목 등
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textMain,
    height: 1.4,
  );

  // -------------------------
  // Body - 콘텐츠 본문
  // -------------------------

  /// 리스트 항목의 금액 등 강조가 필요한 본문
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textMain,
    height: 1.5,
  );

  /// 리스트 항목 설명, 일반 본문
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textMain,
    height: 1.5,
  );

  /// 캡션, 시간, 부가 정보 등
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSub,
    height: 1.4,
  );

  // -------------------------
  // Label - UI 요소
  // -------------------------

  /// 캐릭터 말풍선, 버튼 레이블 등
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textMain,
    height: 1.4,
  );
}
