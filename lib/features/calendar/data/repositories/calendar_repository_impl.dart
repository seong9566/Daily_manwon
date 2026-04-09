import 'package:injectable/injectable.dart';

import '../../../expense/domain/entities/expense.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_datasource.dart';

/// CalendarRepository 인터페이스의 Drift 기반 구현체
@LazySingleton(as: CalendarRepository)
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDatasource _datasource;

  CalendarRepositoryImpl(this._datasource);

  @override
  Future<Map<DateTime, List<ExpenseEntity>>> getMonthlyExpenses({
    required int year,
    required int month,
  }) {
    return _datasource.getMonthlyExpenses(year: year, month: month);
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date) {
    return _datasource.getExpensesByDate(date);
  }

  @override
  Future<int> getStreakDays() {
    return _datasource.getStreakDays();
  }

  @override
  Future<int> getTotalSuccessCount() {
    return _datasource.getTotalSuccessCount();
  }

  @override
  Future<Map<DateTime, int>> getMonthlyBaseAmounts({
    required int year,
    required int month,
  }) {
    return _datasource.getMonthlyBaseAmounts(year: year, month: month);
  }
}
