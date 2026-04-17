import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/providers/budget_change_provider.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/usecases/get_category_stats_use_case.dart';
import '../../domain/usecases/get_daily_budget_use_case.dart';
import '../../domain/usecases/get_daily_stats_use_case.dart';
import '../../domain/usecases/get_expense_summary_use_case.dart';
import '../../domain/usecases/get_weekday_stats_use_case.dart';
import 'stats_state.dart';

part 'stats_view_model.g.dart';

@Riverpod(keepAlive: true)
class StatsViewModel extends _$StatsViewModel {
  GetCategoryStatsUseCase get _categoryStatsUseCase =>
      getIt<GetCategoryStatsUseCase>();
  GetWeekdayStatsUseCase get _weekdayStatsUseCase =>
      getIt<GetWeekdayStatsUseCase>();
  GetExpenseSummaryUseCase get _summaryUseCase =>
      getIt<GetExpenseSummaryUseCase>();
  GetDailyStatsUseCase get _dailyStatsUseCase => getIt<GetDailyStatsUseCase>();
  GetDailyBudgetUseCase get _dailyBudgetUseCase =>
      getIt<GetDailyBudgetUseCase>();

  @override
  Future<StatsState> build() {
    ref.listen(budgetChangeProvider, (_, _) => refresh());
    final now = DateTime.now();
    return _fetchStats(
      DateTime(now.year, now.month, 1),
      AppDateUtils.weekStartOf(now),
    );
  }

  Future<StatsState> _fetchStats(
    DateTime month,
    DateTime weekStart, {
    StatsViewMode viewMode = StatsViewMode.monthly,
  }) async {
    final prevWeekStart = weekStart.subtract(const Duration(days: 7));

    final dailyBudget = await _dailyBudgetUseCase.execute();

    final categoryStats = await _categoryStatsUseCase.execute(
      year: month.year,
      month: month.month,
    );
    final weekdayStats = await _weekdayStatsUseCase.execute(
      year: month.year,
      month: month.month,
    );
    final dailyStats = await _dailyStatsUseCase.execute(weekStart: weekStart);
    final weekSummary = await _summaryUseCase.executeWeekly(
      weekStart: weekStart,
    );
    final prevSummary = await _summaryUseCase.executeWeekly(
      weekStart: prevWeekStart,
    );

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final isFutureWeek = weekStart.isAfter(todayStart);
    // no-spend day(amount=0)도 예산 이하이므로 성공으로 계산한다
    // 현재 주의 경우 오늘 포함 이후 날짜(미래)는 제외하여 실제 경과 일수만 카운팅
    final weeklySuccessDays = isFutureWeek
        ? 0
        : dailyStats
              .where(
                (s) =>
                    s.date.day != DateTime.now().day &&
                    !s.date.isAfter(todayStart) &&
                    s.amount <= dailyBudget,
              )
              .length;

    return StatsState(
      selectedMonth: month,
      selectedWeekStart: weekStart,
      viewMode: viewMode,
      categoryStats: categoryStats,
      weekdayStats: weekdayStats,
      dailyStats: dailyStats,
      dailyBudget: dailyBudget.toDouble(),
      weeklyTotalSpent: weekSummary.totalSpent,
      weeklyBudget: 7 * dailyBudget,
      weeklySuccessDays: weeklySuccessDays,
      weeklyTopCategoryIndex: weekSummary.topCategoryIndex,
      prevWeekTotalSpent: prevSummary.totalSpent,
    );
  }

  /// 월간/주간 모드 전환 — 재fetch 없음
  void toggleViewMode() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        viewMode: current.viewMode == StatsViewMode.monthly
            ? StatsViewMode.weekly
            : StatsViewMode.monthly,
      ),
    );
  }

  /// 선택된 월을 delta만큼 이동하고 통계를 다시 로드한다
  Future<void> changeMonth(int delta) async {
    final now = DateTime.now();
    final current = state.asData?.value;
    final currentMonth =
        current?.selectedMonth ?? DateTime(now.year, now.month, 1);
    final weekStart =
        current?.selectedWeekStart ?? AppDateUtils.weekStartOf(now);
    final viewMode = current?.viewMode ?? StatsViewMode.monthly;

    final newMonth = DateTime(currentMonth.year, currentMonth.month + delta, 1);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchStats(newMonth, weekStart, viewMode: viewMode),
    );
  }

  /// 선택된 주를 delta만큼 이동하고 통계를 다시 로드한다
  Future<void> changeWeek(int delta) async {
    final now = DateTime.now();
    final current = state.asData?.value;
    final month = current?.selectedMonth ?? DateTime(now.year, now.month, 1);
    final weekStart =
        current?.selectedWeekStart ?? AppDateUtils.weekStartOf(now);
    final viewMode = current?.viewMode ?? StatsViewMode.weekly;

    final newWeekStart = weekStart.add(Duration(days: 7 * delta));
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchStats(month, newWeekStart, viewMode: viewMode),
    );
  }

  /// 화면 당김 새로고침
  Future<void> refresh() async {
    final now = DateTime.now();
    final current = state.asData?.value;
    final month = current?.selectedMonth ?? DateTime(now.year, now.month, 1);
    final weekStart =
        current?.selectedWeekStart ?? AppDateUtils.weekStartOf(now);
    final viewMode = current?.viewMode ?? StatsViewMode.monthly;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchStats(month, weekStart, viewMode: viewMode),
    );
  }
}
