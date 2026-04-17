/// 앱 전체 간격 및 크기 토큰
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;

  /// 좌우 페이지 여백
  static const double pagePadding = 20.0;

  /// 최소 터치 타깃 크기
  static const double touchTarget = 44.0;

  /// 금액 표시 영역 좌우 패딩 — 즐겨찾기 아이콘 공간 확보용
  static const double amountPadding = 60.0;

  /// 주 액션 버튼 높이
  static const double buttonHeight = 52.0;
}

/// 앱 전체 애니메이션 지속 시간 토큰
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration shake = Duration(milliseconds: 400);
  static const Duration pulse = Duration(milliseconds: 280);
}
