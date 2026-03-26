import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';

/// 일별 예산 데이터 접근을 위한 레포지토리 인터페이스
abstract interface class DailyBudgetRepository {
  /// 특정 날짜의 예산 정보를 조회한다. 없으면 null 반환
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date);

  /// 오늘 날짜의 예산을 조회하거나, 없으면 기본값(1만원)으로 생성 후 반환한다
  Future<DailyBudgetEntity> getOrCreateTodayBudget();

  /// 특정 날짜의 남은 예산을 계산한다 (baseAmount + carryOver - 총 지출)
  Future<int> getRemainingBudget(DateTime date);

  /// 특정 날짜의 남은 예산을 실시간으로 구독한다 (지출 변동 시 자동 재계산)
  Stream<int> watchRemainingBudget(DateTime date);
}
