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
}
