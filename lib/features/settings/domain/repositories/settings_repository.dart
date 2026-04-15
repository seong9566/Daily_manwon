/// 사용자 설정 데이터 접근을 위한 레포지토리 인터페이스
abstract interface class SettingsRepository {
  /// 다크모드 설정 값을 조회한다
  Future<bool> getIsDarkMode();

  /// 다크모드 설정 값을 저장한다
  Future<void> setIsDarkMode({required bool value});

  /// 일일 예산 설정값을 조회한다
  Future<int> getDailyBudget();

  /// 일일 예산 설정값을 저장한다
  Future<void> setDailyBudget(int amount);

  /// 이월 기능 활성화 여부를 조회한다
  Future<bool> getCarryoverEnabled();

  /// 이월 기능 활성화 여부를 저장한다
  Future<void> setCarryoverEnabled(bool enabled);

  /// 해당 주차에 새 주 알림을 이미 확인했는지 조회한다
  Future<bool> hasSeenNewWeekThisWeek(String weekKey);

  /// 해당 주차에 새 주 알림을 확인했음을 저장한다
  Future<void> markNewWeekSeen(String weekKey);

  /// 세션을 초월해 영구 저장된 자동학습 숨김 키 집합을 반환한다 ("amount_category")
  Future<Set<String>> getDismissedAutoSuggestions();

  /// 자동학습 칩 숨김 키를 영구 저장한다
  Future<void> addDismissedAutoSuggestion(String key);
}
