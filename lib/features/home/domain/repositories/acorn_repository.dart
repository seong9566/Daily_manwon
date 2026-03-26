/// 도토리 저장/조회 Repository 인터페이스 (U-24)
///
/// 구현체: AcornRepositoryImpl (data/repositories)
abstract interface class AcornRepository {
  /// 전체 도토리 합산 개수를 반환한다
  Future<int> getTotalAcorns();

  /// 도토리를 추가한다
  ///
  /// [count] 추가할 도토리 수
  /// [reason] 도토리 획득 사유 (예: '하루 만원 달성', '5천원 이상 절약 보너스')
  Future<void> addAcorn(int count, String reason);

  /// 오늘부터 과거로 역추적하여 연속 성공 일수를 반환한다
  ///
  /// 연속 성공: 해당 날짜에 도토리가 1개 이상 기록된 경우
  Future<int> getStreakDays();
}
