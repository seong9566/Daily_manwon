import '../entities/category_stat.dart';
import '../entities/expense_summary.dart';
import '../entities/weekday_stat.dart';

abstract interface class StatsRepository {
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  });

  Future<List<WeekdayStat>> getWeekdayStats();

  Future<ExpenseSummary> getWeeklySummary({
    required DateTime weekStart,
  });

  Future<ExpenseSummary> getMonthlySummary({
    required int year,
    required int month,
  });
}
