import 'package:daily_manwon/features/expense/domain/entities/expense.dart';

/// 캘린더 화면에 필요한 데이터 접근 인터페이스
/// 월별 지출 집계, 연속 성공일 계산 등을 담당한다
abstract interface class CalendarRepository {
  /// 특정 월(year, month)의 일별 지출 목록을 반환한다
  /// 반환 맵의 키는 날짜(시분초=0 기준), 값은 해당일 지출 목록
  Future<Map<DateTime, List<ExpenseEntity>>> getMonthlyExpenses({
    required int year,
    required int month,
  });

  /// 특정 날짜의 지출 목록을 조회한다
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date);

  /// 오늘까지의 연속 성공일 수를 반환한다
  Future<int> getStreakDays();

  /// 전체 기간 중 성공한 날의 수를 반환한다
  Future<int> getTotalSuccessCount();

  /// 특정 월의 일별 baseAmount 맵을 반환한다
  Future<Map<DateTime, int>> getMonthlyBaseAmounts({
    required int year,
    required int month,
  });

  /// 특정 월의 일별 effectiveBudget 맵을 반환한다
  Future<Map<DateTime, int>> getMonthlyEffectiveBudgets({
    required int year,
    required int month,
  });

  /// 특정 월의 지출 변동을 실시간 스트림으로 구독한다
  Stream<Map<DateTime, List<ExpenseEntity>>> watchExpensesByMonth({
    required int year,
    required int month,
  });
}
