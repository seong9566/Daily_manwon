import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/usecases/get_category_stats_use_case.dart';
import '../../domain/usecases/get_expense_summary_use_case.dart';
import '../../domain/usecases/get_weekday_stats_use_case.dart';

class StatsState {
  final DateTime selectedMonth;
  final List<CategoryStat> categoryStats;
  final List<WeekdayStat> weekdayStats;
  final bool isLoading;
  final String? errorMessage;

  const StatsState({
    required this.selectedMonth,
    this.categoryStats = const [],
    this.weekdayStats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StatsState copyWith({
    DateTime? selectedMonth,
    List<CategoryStat>? categoryStats,
    List<WeekdayStat>? weekdayStats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      categoryStats: categoryStats ?? this.categoryStats,
      weekdayStats: weekdayStats ?? this.weekdayStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 통계 화면 ViewModel
class StatsViewModel extends Notifier<StatsState> {
  GetCategoryStatsUseCase get _categoryStats =>
      getIt<GetCategoryStatsUseCase>();
  GetWeekdayStatsUseCase get _weekdayStats => getIt<GetWeekdayStatsUseCase>();
  GetExpenseSummaryUseCase get _summary => getIt<GetExpenseSummaryUseCase>();

  @override
  StatsState build() {
    final now = DateTime.now();
    final initialState = StatsState(
      selectedMonth: DateTime(now.year, now.month, 1),
      isLoading: true,
    );
    Future.microtask(loadStats);
    return initialState;
  }

  /// 선택된 월을 delta만큼 이동하고 통계를 다시 로드한다
  Future<void> changeMonth(int delta) async {
    final current = state.selectedMonth;
    final newMonth = DateTime(current.year, current.month + delta, 1);
    state = state.copyWith(
      selectedMonth: newMonth,
      isLoading: true,
      clearError: true,
    );
    await loadStats();
  }

  /// 현재 선택된 월의 카테고리 통계와 요일별 통계를 로드한다
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final (categoryStats, weekdayStats) = await (
        _categoryStats.execute(
          year: state.selectedMonth.year,
          month: state.selectedMonth.month,
        ),
        _weekdayStats.execute(),
      ).wait;
      state = state.copyWith(
        categoryStats: categoryStats,
        weekdayStats: weekdayStats,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '통계를 불러오지 못했습니다.',
      );
    }
  }

  /// 선택된 월의 월간 요약을 반환한다
  Future<ExpenseSummary> getMonthlySummary() => _summary.executeMonthly(
        year: state.selectedMonth.year,
        month: state.selectedMonth.month,
      );

  /// 현재 주(일요일 기준)의 주간 요약을 반환한다
  Future<ExpenseSummary> getWeeklySummary() {
    final weekStart = AppDateUtils.weekStartOf(DateTime.now());
    return _summary.executeWeekly(weekStart: weekStart);
  }
}

final statsViewModelProvider = NotifierProvider<StatsViewModel, StatsState>(
  StatsViewModel.new,
);
