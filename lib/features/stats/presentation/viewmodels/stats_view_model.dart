import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/usecases/get_category_stats_use_case.dart';
import '../../domain/usecases/get_daily_budget_use_case.dart';
import '../../domain/usecases/get_daily_stats_use_case.dart';
import '../../domain/usecases/get_expense_summary_use_case.dart';
import '../../domain/usecases/get_weekday_stats_use_case.dart';

enum StatsViewMode { monthly, weekly }

/// 통계 화면 상태 — isLoading/errorMessage는 AsyncValue가 처리
class StatsState {
  final DateTime selectedMonth;
  final List<CategoryStat> categoryStats;
  final List<WeekdayStat> weekdayStats;
  // 공통
  final StatsViewMode viewMode;
  final DateTime selectedWeekStart;
  // 주간 전용
  final double dailyBudget; // 설정한 일일 예산
  final List<DailyStat> dailyStats;
  final int weeklyTotalSpent;
  final int weeklyBudget; // 7 × dailyBudget
  final int weeklySuccessDays;
  final int weeklyTotalDays;
  final int? weeklyTopCategoryIndex;
  final int? prevWeekTotalSpent; // null = 전주 데이터 없음

  const StatsState({
    required this.selectedMonth,
    required this.selectedWeekStart,
    this.viewMode = StatsViewMode.monthly,
    this.categoryStats = const [],
    this.weekdayStats = const [],
    this.dailyStats = const [],
    this.dailyBudget = 0,
    this.weeklyTotalSpent = 0,
    this.weeklyBudget = 0,
    this.weeklySuccessDays = 0,
    this.weeklyTotalDays = 7,
    this.weeklyTopCategoryIndex,
    this.prevWeekTotalSpent,
  });

  StatsState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedWeekStart,
    StatsViewMode? viewMode,
    List<CategoryStat>? categoryStats,
    List<WeekdayStat>? weekdayStats,
    List<DailyStat>? dailyStats,
    int? weeklyTotalSpent,
    int? weeklyBudget,
    int? weeklySuccessDays,
    int? weeklyTopCategoryIndex,
    int? prevWeekTotalSpent,
    double? dailyBudget,
  }) {
    return StatsState(
      dailyBudget: dailyBudget ?? this.dailyBudget,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
      viewMode: viewMode ?? this.viewMode,
      categoryStats: categoryStats ?? this.categoryStats,
      weekdayStats: weekdayStats ?? this.weekdayStats,
      dailyStats: dailyStats ?? this.dailyStats,
      weeklyTotalSpent: weeklyTotalSpent ?? this.weeklyTotalSpent,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      weeklySuccessDays: weeklySuccessDays ?? this.weeklySuccessDays,
      weeklyTopCategoryIndex:
          weeklyTopCategoryIndex ?? this.weeklyTopCategoryIndex,
      prevWeekTotalSpent: prevWeekTotalSpent ?? this.prevWeekTotalSpent,
    );
  }
}

/// 통계 화면 ViewModel
class StatsViewModel extends AsyncNotifier<StatsState> {
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
    // 선택 주의 일요일이 오늘보다 미래이면 성공일 0
    final isFutureWeek = weekStart.isAfter(todayStart);
    // no-spend day(amount=0)도 예산 이하이므로 성공으로 계산한다
    // 현재 주의 경우 오늘 이후 날짜(미래)는 제외하여 실제 경과 일수만 카운팅
    final weeklySuccessDays = isFutureWeek
        ? 0
        : dailyStats
            .where((s) => !s.date.isAfter(todayStart) && s.amount <= dailyBudget)
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
      // 전주 지출 데이터가 없어도 0원으로 비교 표시
      prevWeekTotalSpent: prevSummary.totalSpent,
    );
  }

  /// 월간/주간 모드 전환 — 재fetch 없음 (데이터 이미 있음)
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

  /// 화면 당김 새로고침 — viewMode·선택 월·선택 주를 유지한 채 데이터만 갱신한다
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

final statsViewModelProvider =
    AsyncNotifierProvider<StatsViewModel, StatsState>(StatsViewModel.new);
