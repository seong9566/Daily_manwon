import 'package:injectable/injectable.dart';

import '../entities/expense_summary.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetExpenseSummaryUseCase {
  final StatsRepository _repository;

  GetExpenseSummaryUseCase(this._repository);

  Future<ExpenseSummary> executeWeekly({required DateTime weekStart}) =>
      _repository.getWeeklySummary(weekStart: weekStart);

  Future<ExpenseSummary> executeMonthly({required int year, required int month}) =>
      _repository.getMonthlySummary(year: year, month: month);
}
