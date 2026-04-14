import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/usecases/get_category_stats_use_case.dart';
import '../../domain/usecases/get_expense_summary_use_case.dart';
import '../../domain/usecases/get_weekday_stats_use_case.dart';

/// 통계 화면 상태 — isLoading/errorMessage는 AsyncValue가 처리
class StatsState {
  final DateTime selectedMonth;
  final List<CategoryStat> categoryStats;
  final List<WeekdayStat> weekdayStats;

  const StatsState({
    required this.selectedMonth,
    this.categoryStats = const [],
    this.weekdayStats = const [],
  });

  StatsState copyWith({
    DateTime? selectedMonth,
    List<CategoryStat>? categoryStats,
    List<WeekdayStat>? weekdayStats,
  }) {
    return StatsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      categoryStats: categoryStats ?? this.categoryStats,
      weekdayStats: weekdayStats ?? this.weekdayStats,
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

  @override
  Future<StatsState> build() => _fetchStats(
        DateTime(DateTime.now().year, DateTime.now().month, 1),
      );

  Future<StatsState> _fetchStats(DateTime month) async {
    final (categoryStats, weekdayStats) = await (
      _categoryStatsUseCase.execute(year: month.year, month: month.month),
      _weekdayStatsUseCase.execute(),
    ).wait;
    return StatsState(
      selectedMonth: month,
      categoryStats: categoryStats,
      weekdayStats: weekdayStats,
    );
  }

  /// 선택된 월을 delta만큼 이동하고 통계를 다시 로드한다.
  /// 이전 데이터를 유지하며 로딩 상태를 표시한다.
  Future<void> changeMonth(int delta) async {
    final current = state.requireValue.selectedMonth;
    final newMonth = DateTime(current.year, current.month + delta, 1);
    // 이전 데이터를 유지하면서 로딩 상태로 전환
    state = const AsyncLoading<StatsState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchStats(newMonth));
  }

  /// 화면 당김 새로고침 — build()를 재실행한다
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 선택된 월의 월간 요약을 반환한다
  Future<ExpenseSummary> getMonthlySummary() {
    final month = state.requireValue.selectedMonth;
    return _summaryUseCase.executeMonthly(
      year: month.year,
      month: month.month,
    );
  }

  /// 현재 주(일요일 기준)의 주간 요약을 반환한다
  Future<ExpenseSummary> getWeeklySummary() {
    final weekStart = AppDateUtils.weekStartOf(DateTime.now());
    return _summaryUseCase.executeWeekly(weekStart: weekStart);
  }
}

final statsViewModelProvider =
    AsyncNotifierProvider<StatsViewModel, StatsState>(StatsViewModel.new);
