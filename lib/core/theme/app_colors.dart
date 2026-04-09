import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 컬러 팔레트
/// 디자인 가이드(ui_design_guide.md) 기반 토큰 시스템
abstract final class AppColors {
  // =========================================================================
  // Primary - Black / White
  // =========================================================================

  /// 라이트 모드 주 브랜드 컬러 — Black
  static const Color primary = Color(0xFF000000);

  /// 라이트 모드 네비게이션 선택 강조 — Black
  static const Color primaryDark = Color(0xFF000000);

  /// 라이트 모드 네비게이션 인디케이터 배경 — 연회색
  static const Color primaryLight = Color(0xFFEEEEEE);

  // =========================================================================
  // Base — 순수 흑백 (컴포넌트 전경색, 강조 표면)
  // =========================================================================

  /// 순수 흰색 — 버튼 전경색, 다크모드 강조 표면
  static const Color white = Color(0xFFFFFFFF);

  /// 순수 검정 — 버튼 전경색, 라이트모드 강조 표면
  static const Color black = Color(0xFF000000);

  // =========================================================================
  // Background - 기본 배경
  // =========================================================================

  /// 앱 배경 - 웜 화이트
  static const Color background = Color(0xFFFFFFFF);

  // =========================================================================
  // 숫자 감정 상태 색상 (ui_design_guide Section 1.2)
  // HeroBudgetNumber, 프로그레스 바, 캘린더 dot에 사용
  // =========================================================================

  /// 여유 상태 (≥5,000원) [Light] — Black
  static const Color budgetComfortable = Color(0xFF000000);

  /// 여유 상태 (≥5,000원) [Dark] — White
  static const Color budgetComfortableDark = Color(0xFFFFFFFF);

  /// 주의 상태 (1,000~4,999원) — 앰버 오렌지
  static const Color budgetWarning = Color(0xFFF5A623);

  /// 위험 상태 (<1,000원) — 코랄 레드
  static const Color budgetDanger = Color(0xFFE85D5D);

  /// 초과 상태 (<0원) — 딥 레드
  static const Color budgetOver = Color(0xFFC0392B);

  /// 보조 액센트 — 스카이 블루 (수정 스와이프, 링크)
  static const Color accent = Color(0xFF4A90D9);

  // =========================================================================
  // 레거시 상태 색상 (AppConstants CharacterMood에서 참조)
  // =========================================================================

  /// 여유 상태 - 파스텔 그린 (레거시)
  static const Color statusComfortable = Color(0xFF7EC8A0);

  /// 주의 상태 - 파스텔 옐로 (레거시)
  static const Color statusWarning = Color(0xFFFFD966);

  /// 위험 상태 - 파스텔 레드 (레거시)
  static const Color statusDanger = Color(0xFFFF8B8B);

  // =========================================================================
  // 카테고리별 대표 색상
  // =========================================================================

  /// 식비
  static const Color categoryFood = Color(0xFFFF9B9B);

  /// 교통
  static const Color categoryTransport = Color(0xFF9BB8FF);

  /// 카페
  static const Color categoryCafe = Color(0xFFC4A882);

  /// 쇼핑
  static const Color categoryShopping = Color(0xFFC49BFF);

  /// 기타
  static const Color categoryEtc = Color(0xFFB8B8B8);

  // =========================================================================
  // 카테고리 칩 배경색 (ui_design_guide Section 5)
  // =========================================================================

  /// 식비 칩 배경
  static const Color chipFood = Color(0xFFFFF0E0);

  /// 교통 칩 배경
  static const Color chipTransport = Color(0xFFE8F4FD);

  /// 카페 칩 배경
  static const Color chipCafe = Color(0xFFF5ECD7);

  /// 쇼핑 칩 배경
  static const Color chipShopping = Color(0xFFF3E8FD);

  /// 기타 칩 배경
  static const Color chipEtc = Color(0xFFF0F0F0);

  // =========================================================================
  // Neutral - 텍스트 및 구조 요소 (레거시)
  // =========================================================================

  /// 메인 텍스트 (제목, 금액 등)
  static const Color textMain = Color(0xFF3D3D3D);

  /// 서브 텍스트 (설명, 시간 등)
  static const Color textSub = Color(0xFF8E8E8E);

  /// 구분선 / 섹션 경계
  static const Color divider = Color(0xFFF0E8E0);

  /// 구분선 (디자인 가이드)
  static const Color border = Color(0xFFE5E7EB);

  /// 카드 배경
  static const Color card = Color(0xFFFFFFFF);

  // =========================================================================
  // Dark Mode
  // =========================================================================

  /// 다크모드 배경
  static const Color darkBackground = Color(0xFF1A1A1A);

  /// 다크모드 표면 (카드, 바텀시트 등)
  static const Color darkSurface = Color(0xFF2A2A2A);

  /// 다크모드 카드 배경
  static const Color darkCard = Color(0xFF333333);

  /// 다크모드 메인 텍스트
  static const Color darkTextMain = Color(0xFFF0F0F0);

  /// 다크모드 서브 텍스트
  static const Color darkTextSub = Color(0xFFA0A0A0);

  /// 다크모드 구분선
  static const Color darkDivider = Color(0xFF3D3D3D);

  // =========================================================================
  // Confetti 파티클 색상
  // =========================================================================

  /// 축하 파티클 - 노란색
  static const Color confettiYellow = Color(0xFFFFE66D);

  /// 축하 파티클 - 빨간색
  static const Color confettiRed = Color(0xFFFF6B6B);
}
