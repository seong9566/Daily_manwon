import '../entities/category_stat.dart';
import '../entities/daily_stat.dart';
import '../entities/expense_summary.dart';
import '../entities/weekday_stat.dart';

abstract interface class StatsRepository {
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  });

  Future<List<WeekdayStat>> getWeekdayStats({
    required int year,
    required int month,
  });

  /// 해당 주(일~토) 7일의 일별 지출을 반환한다
  Future<List<DailyStat>> getDailyStatsForWeek(DateTime weekStart);

  Future<ExpenseSummary> getWeeklySummary({required DateTime weekStart});

  Future<ExpenseSummary> getMonthlySummary({
    required int year,
    required int month,
  });

}
