/// 앱 전역 이모지 아이콘 토큰 — rewardIcon(🐾), streakIcon(🔥) 제공
///
/// UI에서 이모지를 하드코딩하지 않고 이 클래스를 통해 참조한다.
/// 아이콘 변경 시 이 파일 한 곳만 수정하면 전체 반영된다.
abstract final class AppEmoji {
  /// 보상(발도장) 아이콘 — 성공 횟수 및 리워드 표시에 사용
  static const String rewardIcon = '🐾';

  /// 연속 성공(스트릭) 아이콘
  static const String streakIcon = '🔥';
}
