import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/providers/budget_change_provider.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../domain/usecases/get_monthly_calendar_data_use_case.dart';

/// 캘린더 뷰 모드
enum CalendarViewMode { monthly, weekly }

/// 캘린더 화면 상태 모델
class CalendarState {
  /// 현재 표시 중인 월 (day=1 고정)
  final DateTime selectedMonth;

  /// 캘린더에서 선택된 날짜 (미선택 시 null)
  final DateTime? selectedDate;

  /// 현재 월의 일별 지출 데이터
  final Map<DateTime, List<ExpenseEntity>> monthlyExpenses;

  /// 현재 월의 일별 baseAmount 데이터 (DailyBudgets.baseAmount)
  final Map<DateTime, int> monthlyBaseAmounts;

  /// 현재 월의 일별 effectiveBudget 데이터 (baseAmount + carryOver)
  final Map<DateTime, int> monthlyEffectiveBudgets;

  /// 오늘까지 연속 성공일 수
  final int streakDays;

  /// 전체 성공 횟수
  final int successCount;

  /// 데이터 로딩 중 여부 — 최초 캐시 미스 시에만 true
  final bool isLoading;

  /// 오류 메시지 (없으면 null)
  final String? errorMessage;

  /// 인접 달 캐시 갱신 시 증가 — UI 재빌드 유발용
  final int cacheVersion;

  /// 현재 뷰 모드 (월간/주간)
  final CalendarViewMode viewMode;

  /// 주간 뷰에서 현재 표시 중인 주의 시작일 (일요일)
  final DateTime selectedWeekStart;

  const CalendarState({
    required this.selectedMonth,
    this.selectedDate,
    this.monthlyExpenses = const {},
    this.monthlyBaseAmounts = const {},
    this.monthlyEffectiveBudgets = const {},
    this.streakDays = 0,
    this.successCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.cacheVersion = 0,
    this.viewMode = CalendarViewMode.monthly,
    required this.selectedWeekStart,
  });

  /// 선택된 날짜의 지출 목록 — 편의 getter
  List<ExpenseEntity> get selectedDateExpenses {
    if (selectedDate == null) return [];
    return monthlyExpenses[selectedDate] ?? [];
  }

  /// 이번 달 오늘까지의 총 예산 합산 (effectiveBudget → baseAmount → dailyBudget 순 폴백)
  int get monthlyTotalBudget {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    int total = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, d);
      if (date.isAfter(today)) continue;
      total += monthlyEffectiveBudgets[date] ??
          monthlyBaseAmounts[date] ??
          AppConstants.dailyBudget;
    }
    return total;
  }

  /// 이번 달 오늘까지의 총 지출 합산
  int get monthlyTotalSpent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    int total = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, d);
      if (date.isAfter(today)) continue;
      total +=
          (monthlyExpenses[date] ?? []).fold<int>(0, (s, e) => s + e.amount);
    }
    return total;
  }

  /// 현재 표시 중인 월의 성공일 수 (오늘 이전 날짜 기준)
  /// 지출이 없는 날(0원)도 성공으로 카운트한다
  int get monthlySuccessCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, d);
      if (date.isAfter(today)) continue;
      final dayTotal = (monthlyExpenses[date] ?? []).fold<int>(0, (s, e) => s + e.amount);
      final budget = monthlyEffectiveBudgets[date] ?? monthlyBaseAmounts[date] ?? AppConstants.dailyBudget;
      if (dayTotal <= budget) count++;
    }
    return count;
  }

  CalendarState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    Map<DateTime, List<ExpenseEntity>>? monthlyExpenses,
    Map<DateTime, int>? monthlyBaseAmounts,
    Map<DateTime, int>? monthlyEffectiveBudgets,
    int? streakDays,
    int? successCount,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? cacheVersion,
    CalendarViewMode? viewMode,
    DateTime? selectedWeekStart,
  }) {
    return CalendarState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      monthlyBaseAmounts: monthlyBaseAmounts ?? this.monthlyBaseAmounts,
      monthlyEffectiveBudgets: monthlyEffectiveBudgets ?? this.monthlyEffectiveBudgets,
      streakDays: streakDays ?? this.streakDays,
      successCount: successCount ?? this.successCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cacheVersion: cacheVersion ?? this.cacheVersion,
      viewMode: viewMode ?? this.viewMode,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
    );
  }
}

/// 캘린더 화면 ViewModel
/// 월 이동, 날짜 선택, 월별 데이터 로드 및 ±2달 프리패치를 담당한다
class CalendarViewModel extends Notifier<CalendarState> {
  GetMonthlyCalendarDataUseCase get _useCase =>
      getIt<GetMonthlyCalendarDataUseCase>();

  /// 월별 지출 캐시: key = "year-month"
  final Map<String, Map<DateTime, List<ExpenseEntity>>> _expenseCache = {};

  /// 월별 baseAmount 캐시: key = "year-month"
  final Map<String, Map<DateTime, int>> _baseAmountCache = {};

  /// 월별 effectiveBudget 캐시: key = "year-month"
  final Map<String, Map<DateTime, int>> _effectiveBudgetCache = {};

  /// 월별 선택 날짜 캐시: 월 이동 후 복귀 시 이전 선택 날짜 복원용
  final Map<String, DateTime> _selectedDateCache = {};

  /// 전체 기간 통계 캐시 — 1회 로드 후 재사용
  int? _cachedStreak;
  int? _cachedSuccessCount;

  /// 현재 fetch 중인 캐시 키 집합 — 중복 요청 방지
  final Set<String> _inFlightLoads = {};

  /// 현재 선택 월의 지출 변동 스트림 구독
  StreamSubscription<Map<DateTime, List<ExpenseEntity>>>?
      _monthWatchSubscription;

  String _cacheKey(int year, int month) => '$year-$month';

  @override
  CalendarState build() {
    // invalidate 재호출 시 stale 캐시가 남지 않도록 항상 초기화
    _expenseCache.clear();
    _baseAmountCache.clear();
    _effectiveBudgetCache.clear();
    _selectedDateCache.clear();
    _cachedStreak = null;
    _cachedSuccessCount = null;
    _inFlightLoads.clear();

    final now = DateTime.now();
    final initialState = CalendarState(
      selectedMonth: DateTime(now.year, now.month, 1),
      selectedDate: DateTime(now.year, now.month, now.day),
      selectedWeekStart: AppDateUtils.weekStartOf(now),
      isLoading: true, // invalidate 후 빈 화면 flash 방지 — loadMonthData()에서 false로 전환
    );
    ref.onDispose(() => _monthWatchSubscription?.cancel());

    ref.listen(budgetChangeProvider, (_, _) => loadMonthData(forceRefresh: true));
    Future.microtask(() async {
      await _restoreViewMode();
      await loadMonthData();
      _watchCurrentMonth(); // 초기 로드 후 스트림 구독 시작
    });
    return initialState;
  }

  /// 특정 월의 지출 캐시를 반환한다.
  /// 캐시 미스 시 빈 Map을 반환한다 (UI 프리렌더링용).
  Map<DateTime, List<ExpenseEntity>> getCachedExpenses(int year, int month) {
    return _expenseCache[_cacheKey(year, month)] ?? const {};
  }

  /// 특정 날짜의 지출 목록을 캐시에서 직접 반환한다.
  /// selectedMonth와 무관하게 해당 날짜 소속 월의 캐시를 조회하므로,
  /// 주간 뷰에서 월 경계를 넘는 주 이동 후에도 올바른 데이터를 반환한다.
  List<ExpenseEntity> getExpensesForDate(DateTime? date) {
    if (date == null) return const [];
    final key = _cacheKey(date.year, date.month);
    return _expenseCache[key]?[date] ?? const [];
  }

  /// 특정 월의 baseAmount 캐시를 반환한다.
  /// 캐시 미스 시 빈 Map을 반환한다 (fallback은 UI에서 AppConstants.dailyBudget 사용).
  Map<DateTime, int> getCachedBaseAmounts(int year, int month) {
    return _baseAmountCache[_cacheKey(year, month)] ?? const {};
  }

  /// 특정 월의 effectiveBudget 캐시를 반환한다.
  /// 캐시 미스 시 빈 Map을 반환한다.
  Map<DateTime, int> getCachedEffectiveBudgets(int year, int month) {
    return _effectiveBudgetCache[_cacheKey(year, month)] ?? const {};
  }

  /// 현재 선택 월의 지출 변동을 구독한다. 월 변경 시 재호출하여 재구독한다.
  void _watchCurrentMonth() {
    _monthWatchSubscription?.cancel();
    final month = state.selectedMonth;
    _monthWatchSubscription = _useCase
        .watchExpensesByMonth(year: month.year, month: month.month)
        .listen((_) {
          final key = _cacheKey(month.year, month.month);
          if (!_inFlightLoads.contains(key)) {
            loadMonthData(forceRefresh: true);
          }
        });
  }

  /// 월을 delta만큼 이동한다 (양수 = 다음 달, 음수 = 이전 달)
  Future<void> changeMonth(int delta) async {
    final current = state.selectedMonth;
    final currentKey = _cacheKey(current.year, current.month);

    // 현재 월의 선택 날짜를 캐시에 저장
    if (state.selectedDate != null) {
      _selectedDateCache[currentKey] = state.selectedDate!;
    }

    final newMonth = DateTime(current.year, current.month + delta, 1);
    final newKey = _cacheKey(newMonth.year, newMonth.month);

    // 새 월의 캐시된 선택 날짜 복원 (없으면 null)
    final restoredDate = _selectedDateCache[newKey];

    state = state.copyWith(
      selectedMonth: newMonth,
      selectedDate: restoredDate,
      clearSelectedDate: restoredDate == null,
    );

    await loadMonthData();
    _watchCurrentMonth(); // 월 변경 시 새 월로 재구독
  }

  /// 날짜를 선택한다
  void selectDate(DateTime date) {
    final dayKey = DateTime(date.year, date.month, date.day);
    // 월별 선택 날짜 캐시에도 저장
    final monthKey = _cacheKey(dayKey.year, dayKey.month);
    _selectedDateCache[monthKey] = dayKey;
    state = state.copyWith(selectedDate: dayKey);
  }

  /// 현재 선택된 월의 데이터를 로드한다.
  ///
  /// [forceRefresh] true이면 캐시를 우회하여 새로 로드한다 (RefreshIndicator용).
  Future<void> loadMonthData({bool forceRefresh = false}) async {
    final year = state.selectedMonth.year;
    final month = state.selectedMonth.month;
    final key = _cacheKey(year, month);

    if (!forceRefresh && _inFlightLoads.contains(key)) return;

    // 캐시 히트 — 깜빡임 없이 즉시 전환
    if (!forceRefresh && _expenseCache.containsKey(key)) {
      state = state.copyWith(
        monthlyExpenses: _expenseCache[key]!,
        monthlyBaseAmounts: _baseAmountCache[key] ?? const {},
        monthlyEffectiveBudgets: _effectiveBudgetCache[key] ?? const {},
        streakDays: _cachedStreak ?? state.streakDays,
        successCount: _cachedSuccessCount ?? state.successCount,
        isLoading: false,
      );
      _prefetchAdjacentMonths(year, month);
      return;
    }

    // 캐시 미스 또는 forceRefresh — 로딩 표시 후 fetch
    _inFlightLoads.add(key);
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final (expenses, baseAmounts, effectiveBudgets, streak, successCount) = await (
        _useCase.getMonthlyExpenses(year: year, month: month),
        _useCase.getMonthlyBaseAmounts(year: year, month: month),
        _useCase.getMonthlyEffectiveBudgets(year: year, month: month),
        _cachedStreak != null
            ? Future.value(_cachedStreak!)
            : _useCase.getStreakDays(),
        _cachedSuccessCount != null
            ? Future.value(_cachedSuccessCount!)
            : _useCase.getTotalSuccessCount(),
      ).wait;

      _expenseCache[key] = expenses;
      _baseAmountCache[key] = baseAmounts;
      _effectiveBudgetCache[key] = effectiveBudgets;
      if (state.selectedMonth.year != year ||
          state.selectedMonth.month != month) {
        return;
      }

      _cachedStreak = streak;
      _cachedSuccessCount = successCount;

      state = state.copyWith(
        monthlyExpenses: expenses,
        monthlyBaseAmounts: baseAmounts,
        monthlyEffectiveBudgets: effectiveBudgets,
        streakDays: streak,
        successCount: successCount,
        isLoading: false,
      );

      _prefetchAdjacentMonths(year, month);
    } catch (e) {
      if (state.selectedMonth.year == year &&
          state.selectedMonth.month == month) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '데이터를 불러오지 못했습니다.',
        );
      }
    } finally {
      _inFlightLoads.remove(key);
    }
  }

  /// monthly ↔ weekly 전환
  void toggleViewMode() {
    final newMode = state.viewMode == CalendarViewMode.monthly
        ? CalendarViewMode.weekly
        : CalendarViewMode.monthly;
    final weekStart = state.selectedDate != null
        ? AppDateUtils.weekStartOf(state.selectedDate!)
        : AppDateUtils.weekStartOf(DateTime.now());
    state = state.copyWith(viewMode: newMode, selectedWeekStart: weekStart);
    _saveViewMode(newMode);
  }

  /// 주 단위 이동 (delta: +1 다음 주, -1 이전 주)
  Future<void> changeWeek(int delta) async {
    final newWeekStart = state.selectedWeekStart.add(Duration(days: delta * 7));
    final weekEnd = newWeekStart.add(const Duration(days: 6));
    final key1 = _cacheKey(newWeekStart.year, newWeekStart.month);
    final key2 = _cacheKey(weekEnd.year, weekEnd.month);
    if (!_expenseCache.containsKey(key1)) {
      await _loadMonth(newWeekStart.year, newWeekStart.month);
    }
    if (key1 != key2 && !_expenseCache.containsKey(key2)) {
      await _loadMonth(weekEnd.year, weekEnd.month);
    }
    state = state.copyWith(
      selectedWeekStart: newWeekStart,
      selectedDate: newWeekStart,
    );
  }

  /// 현재 주의 지출 요약 계산 (캐시 활용, 별도 DB 쿼리 없음)
  ({int totalSpent, int dailyAverage, int savingDays, int totalDays, int weeklyBudget})
      getWeeklySummary() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final weekDays = AppDateUtils.weekDaysFrom(state.selectedWeekStart);
    int totalSpent = 0, savingDays = 0, countedDays = 0;
    // 총지출 색상 기준: 실제 지출이 있는 날의 예산만 합산
    // — 지출 없는 날(0원)을 포함하면 비율이 희석되어 셀 뱃지와 색상이 달라짐
    int spentDaysBudget = 0;
    for (final day in weekDays) {
      if (day.isAfter(today)) continue;
      countedDays++;
      final expenses = _expenseCache[_cacheKey(day.year, day.month)]?[day] ?? [];
      final dayTotal = expenses.fold<int>(0, (s, e) => s + e.amount);
      totalSpent += dayTotal;
      final dayBudget = _effectiveBudgetCache[_cacheKey(day.year, day.month)]?[day]
          ?? _baseAmountCache[_cacheKey(day.year, day.month)]?[day]
          ?? AppConstants.dailyBudget;
      if (dayTotal > 0) spentDaysBudget += dayBudget;
      if (dayTotal == 0 || dayTotal <= dayBudget) savingDays++;
    }
    return (
      totalSpent: totalSpent,
      dailyAverage: countedDays > 0 ? totalSpent ~/ countedDays : 0,
      savingDays: savingDays,
      totalDays: weekDays.length,
      weeklyBudget: spentDaysBudget,
    );
  }

  /// 뷰 모드를 SharedPreferences에 저장한다
  Future<void> _saveViewMode(CalendarViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendar_view_mode', mode.name);
  }

  /// 저장된 뷰 모드를 복원한다
  Future<void> _restoreViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('calendar_view_mode');
    if (saved != null) {
      final savedMode = CalendarViewMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => CalendarViewMode.monthly,
      );
      state = state.copyWith(viewMode: savedMode);
    }
  }

  /// 특정 월 데이터를 캐시에 로드한다 (changeWeek 내부 사용)
  Future<void> _loadMonth(int year, int month) async {
    final key = _cacheKey(year, month);
    if (_inFlightLoads.contains(key)) return;
    _inFlightLoads.add(key);
    try {
      final (expenses, baseAmounts, effectiveBudgets) = await (
        _useCase.getMonthlyExpenses(year: year, month: month),
        _useCase.getMonthlyBaseAmounts(year: year, month: month),
        _useCase.getMonthlyEffectiveBudgets(year: year, month: month),
      ).wait;
      _expenseCache[key] = expenses;
      _baseAmountCache[key] = baseAmounts;
      _effectiveBudgetCache[key] = effectiveBudgets;
    } finally {
      _inFlightLoads.remove(key);
    }
  }

  /// ±2달 데이터를 백그라운드에서 미리 로드한다.
  /// 캐시 완료 시 cacheVersion을 증가시켜 UI 재빌드를 유발한다.
  void _prefetchAdjacentMonths(int year, int month) {
    for (final offset in [-2, -1, 1, 2]) {
      final dt = DateTime(year, month + offset);
      final key = _cacheKey(dt.year, dt.month);
      if (_expenseCache.containsKey(key) || _inFlightLoads.contains(key)) {
        continue;
      }

      _inFlightLoads.add(key);
      (
        _useCase.getMonthlyExpenses(year: dt.year, month: dt.month),
        _useCase.getMonthlyBaseAmounts(year: dt.year, month: dt.month),
        _useCase.getMonthlyEffectiveBudgets(year: dt.year, month: dt.month),
      ).wait.then((results) {
            final (expenses, baseAmounts, effectiveBudgets) = results;
            _expenseCache[key] = expenses;
            _baseAmountCache[key] = baseAmounts;
            _effectiveBudgetCache[key] = effectiveBudgets;
            // 인접 달 그리드에 데이터가 반영되도록 state 변경 유발
            state = state.copyWith(cacheVersion: state.cacheVersion + 1);
          })
          .whenComplete(() {
            _inFlightLoads.remove(key);
          })
          .ignore();
    }
  }
}

/// 캘린더 ViewModel Provider
final calendarViewModelProvider =
    NotifierProvider<CalendarViewModel, CalendarState>(
  CalendarViewModel.new,
);
