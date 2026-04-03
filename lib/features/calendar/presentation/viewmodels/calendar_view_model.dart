import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../domain/usecases/get_monthly_calendar_data_use_case.dart';

/// 캘린더 화면 상태 모델
class CalendarState {
  /// 현재 표시 중인 월 (day=1 고정)
  final DateTime selectedMonth;

  /// 캘린더에서 선택된 날짜 (미선택 시 null)
  final DateTime? selectedDate;

  /// 현재 월의 일별 지출 데이터
  final Map<DateTime, List<ExpenseEntity>> monthlyExpenses;

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

  const CalendarState({
    required this.selectedMonth,
    this.selectedDate,
    this.monthlyExpenses = const {},
    this.streakDays = 0,
    this.successCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.cacheVersion = 0,
  });

  /// 선택된 날짜의 지출 목록 — 편의 getter
  List<ExpenseEntity> get selectedDateExpenses {
    if (selectedDate == null) return [];
    return monthlyExpenses[selectedDate] ?? [];
  }

  CalendarState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    Map<DateTime, List<ExpenseEntity>>? monthlyExpenses,
    int? streakDays,
    int? successCount,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? cacheVersion,
  }) {
    return CalendarState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      streakDays: streakDays ?? this.streakDays,
      successCount: successCount ?? this.successCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cacheVersion: cacheVersion ?? this.cacheVersion,
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

  /// 월별 선택 날짜 캐시: 월 이동 후 복귀 시 이전 선택 날짜 복원용
  final Map<String, DateTime> _selectedDateCache = {};

  /// 전체 기간 통계 캐시 — 1회 로드 후 재사용
  int? _cachedStreak;
  int? _cachedSuccessCount;

  /// 현재 fetch 중인 캐시 키 집합 — 중복 요청 방지
  final Set<String> _inFlightLoads = {};

  String _cacheKey(int year, int month) => '$year-$month';

  @override
  CalendarState build() {
    // invalidate 재호출 시 stale 캐시가 남지 않도록 항상 초기화
    _expenseCache.clear();
    _selectedDateCache.clear();
    _cachedStreak = null;
    _cachedSuccessCount = null;
    _inFlightLoads.clear();

    final now = DateTime.now();
    final initialState = CalendarState(
      selectedMonth: DateTime(now.year, now.month, 1),
      selectedDate: DateTime(now.year, now.month, now.day),
    );
    Future.microtask(loadMonthData);
    return initialState;
  }

  /// 특정 월의 지출 캐시를 반환한다.
  /// 캐시 미스 시 빈 Map을 반환한다 (UI 프리렌더링용).
  Map<DateTime, List<ExpenseEntity>> getCachedExpenses(int year, int month) {
    return _expenseCache[_cacheKey(year, month)] ?? const {};
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
      final (expenses, streak, successCount) = await (
        _useCase.getMonthlyExpenses(year: year, month: month),
        _cachedStreak != null
            ? Future.value(_cachedStreak!)
            : _useCase.getStreakDays(),
        _cachedSuccessCount != null
            ? Future.value(_cachedSuccessCount!)
            : _useCase.getTotalSuccessCount(),
      ).wait;

      _expenseCache[key] = expenses;
      if (state.selectedMonth.year != year ||
          state.selectedMonth.month != month) {
        return;
      }

      _cachedStreak = streak;
      _cachedSuccessCount = successCount;

      state = state.copyWith(
        monthlyExpenses: expenses,
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
      _useCase
          .getMonthlyExpenses(year: dt.year, month: dt.month)
          .then((expenses) {
            _expenseCache[key] = expenses;
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
