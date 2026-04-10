import 'package:injectable/injectable.dart';

import '../../../expense/domain/entities/expense.dart';
import '../repositories/calendar_repository.dart';

/// 월별 캘린더 데이터 조회 UseCase
/// 월별 지출, 연속 성공일, 전체 성공 횟수를 도메인 레이어에서 캡슐화한다
@lazySingleton
class GetMonthlyCalendarDataUseCase {
  const GetMonthlyCalendarDataUseCase(this._repository);

  final CalendarRepository _repository;

  /// 특정 월의 일별 지출 맵을 반환한다
  Future<Map<DateTime, List<ExpenseEntity>>> getMonthlyExpenses({
    required int year,
    required int month,
  }) =>
      _repository.getMonthlyExpenses(year: year, month: month);

  /// 오늘까지의 연속 성공일 수를 반환한다
  Future<int> getStreakDays() => _repository.getStreakDays();

  /// 전체 기간 중 성공한 날의 수를 반환한다
  Future<int> getTotalSuccessCount() => _repository.getTotalSuccessCount();

  /// 특정 월의 일별 baseAmount 맵을 반환한다
  Future<Map<DateTime, int>> getMonthlyBaseAmounts({
    required int year,
    required int month,
  }) =>
      _repository.getMonthlyBaseAmounts(year: year, month: month);

  /// 특정 월의 일별 effectiveBudget 맵을 반환한다
  Future<Map<DateTime, int>> getMonthlyEffectiveBudgets({
    required int year,
    required int month,
  }) =>
      _repository.getMonthlyEffectiveBudgets(year: year, month: month);
}
