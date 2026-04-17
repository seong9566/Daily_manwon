import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category_stat.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/weekday_stat.dart';

part 'stats_state.freezed.dart';

enum StatsViewMode { monthly, weekly }

@freezed
sealed class StatsState with _$StatsState {
  const factory StatsState({
    required DateTime selectedMonth,
    required DateTime selectedWeekStart,
    @Default(StatsViewMode.monthly) StatsViewMode viewMode,
    @Default([]) List<CategoryStat> categoryStats,
    @Default([]) List<WeekdayStat> weekdayStats,
    @Default([]) List<DailyStat> dailyStats,
    @Default(0.0) double dailyBudget,
    @Default(0) int weeklyTotalSpent,
    @Default(0) int weeklyBudget,
    @Default(0) int weeklySuccessDays,
    @Default(7) int weeklyTotalDays,
    int? weeklyTopCategoryIndex,
    int? prevWeekTotalSpent,
  }) = _StatsState;
}
