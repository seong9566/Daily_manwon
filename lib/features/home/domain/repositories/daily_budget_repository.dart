import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';

/// 일별 예산 데이터 접근을 위한 레포지토리 인터페이스
abstract interface class DailyBudgetRepository {
  /// 특정 날짜의 예산 정보를 조회한다. 없으면 null 반환
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date);

  /// 오늘 날짜의 예산을 조회하거나, 없으면 생성 후 반환한다
  Future<DailyBudgetEntity> getOrCreateTodayBudget({required int carryOver});

  /// 특정 날짜의 예산을 조회하거나, 없으면 생성 후 반환한다 (갭 처리용)
  ///
  /// [baseAmount]가 제공되면 해당 금액을 사용하고, 없으면 현재 설정값으로 폴백한다.
  Future<DailyBudgetEntity> getOrCreateBudgetForDate({
    required DateTime date,
    required int carryOver,
    int? baseAmount,
  });

  /// 특정 날짜의 남은 예산을 계산한다 (effectiveBudget - 총 지출)
  Future<int> getRemainingBudget(DateTime date);

  /// 특정 날짜의 남은 예산을 실시간으로 구독한다 (지출 변동 시 자동 재계산)
  Stream<int> watchRemainingBudget(DateTime date);

  /// 가장 최근 예산 레코드의 날짜를 반환한다
  Future<DateTime?> getLastBudgetDate();

  /// 특정 날짜의 총 지출액을 반환한다
  Future<int> getTotalExpensesByDate(DateTime date);

  /// 오늘 예산 레코드의 baseAmount를 즉시 업데이트한다 (설정 변경 즉시 반영용)
  Future<void> updateTodayBaseAmount(int amount);
}
