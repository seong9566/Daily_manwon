import 'package:injectable/injectable.dart';

import '../../domain/entities/category_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';

@LazySingleton(as: StatsRepository)
class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDatasource _datasource;

  StatsRepositoryImpl(this._datasource);

  @override
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  }) => _datasource.getCategoryStats(year: year, month: month);

  @override
  Future<List<WeekdayStat>> getWeekdayStats() =>
      _datasource.getWeekdayStats();

  @override
  Future<ExpenseSummary> getWeeklySummary({required DateTime weekStart}) {
    final from = weekStart;
    final to = weekStart.add(const Duration(days: 7));
    return _datasource.getExpenseSummary(from: from, to: to);
  }

  @override
  Future<ExpenseSummary> getMonthlySummary({
    required int year,
    required int month,
  }) {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 1);
    return _datasource.getExpenseSummary(from: from, to: to);
  }
}
