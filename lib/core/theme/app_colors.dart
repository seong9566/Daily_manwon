import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 컬러 팔레트
/// 파스텔 톤 기반의 따뜻한 디자인 컨셉을 반영한다
abstract final class AppColors {
  // -------------------------
  // Primary - 파스텔 오렌지
  // -------------------------

  /// 주 브랜드 컬러
  static const Color primary = Color(0xFFFFB366);

  /// 주 컬러 다크 변형 (버튼 눌림, 강조)
  static const Color primaryDark = Color(0xFFE6944D);

  /// 주 컬러 라이트 변형 (배경 강조, 칩)
  static const Color primaryLight = Color(0xFFFFD9B3);

  // -------------------------
  // Background
  // -------------------------

  /// 앱 배경 - 웜 화이트
  static const Color background = Color(0xFFFFF8F0);

  // -------------------------
  // 지출 상태 - 남은 금액에 따른 캐릭터 감정 표현 색상
  // -------------------------

  /// 여유 상태 (잔액 5,000원 이상) - 파스텔 그린
  static const Color statusComfortable = Color(0xFF7EC8A0);

  /// 주의 상태 (잔액 1,000~4,999원) - 파스텔 옐로
  static const Color statusWarning = Color(0xFFFFD966);

  /// 위험 상태 (잔액 1,000원 미만) - 파스텔 레드
  static const Color statusDanger = Color(0xFFFF8B8B);

  // -------------------------
  // 카테고리별 대표 색상
  // -------------------------

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

  // -------------------------
  // Neutral - 텍스트 및 구조 요소
  // -------------------------

  /// 메인 텍스트 (제목, 금액 등)
  static const Color textMain = Color(0xFF3D3D3D);

  /// 서브 텍스트 (설명, 시간 등)
  static const Color textSub = Color(0xFF8E8E8E);

  /// 구분선 / 섹션 경계
  static const Color divider = Color(0xFFF0E8E0);

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
}
