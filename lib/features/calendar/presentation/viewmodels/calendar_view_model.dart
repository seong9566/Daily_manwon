import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../domain/repositories/calendar_repository.dart';

/// 캘린더 화면 상태 모델
class CalendarState {
  /// 현재 표시 중인 월 (day=1 고정)
  final DateTime selectedMonth;

  /// 캘린더에서 선택된 날짜 (미선택 시 null)
  final DateTime? selectedDate;

  /// 현재 월의 일별 지출 데이터
  /// 키: 날짜(시분초=0), 값: 해당일 지출 목록
  final Map<DateTime, List<ExpenseEntity>> monthlyExpenses;

  /// 오늘까지 연속 성공일 수
  final int streakDays;

  /// 전체 성공 횟수
  final int successCount;

  /// 데이터 로딩 중 여부
  final bool isLoading;

  /// 오류 메시지 (없으면 null)
  final String? errorMessage;

  const CalendarState({
    required this.selectedMonth,
    this.selectedDate,
    this.monthlyExpenses = const {},
    this.streakDays = 0,
    this.successCount = 0,
    this.isLoading = false,
    this.errorMessage,
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
    );
  }
}

/// 캘린더 화면 ViewModel
/// 월 이동, 날짜 선택, 월별 데이터 로드를 담당한다
class CalendarViewModel extends Notifier<CalendarState> {
  CalendarRepository get _repository => getIt<CalendarRepository>();

  @override
  CalendarState build() {
    final now = DateTime.now();
    // 초기 상태: 이번 달, 오늘 선택
    final initialState = CalendarState(
      selectedMonth: DateTime(now.year, now.month, 1),
      selectedDate: DateTime(now.year, now.month, now.day),
    );

    // 빌드 직후 이번 달 데이터 로드
    Future.microtask(loadMonthData);

    return initialState;
  }

  /// 월을 delta만큼 이동한다 (양수 = 다음 달, 음수 = 이전 달)
  Future<void> changeMonth(int delta) async {
    final current = state.selectedMonth;
    final newMonth = DateTime(current.year, current.month + delta, 1);

    state = state.copyWith(
      selectedMonth: newMonth,
      // 월 이동 시 선택된 날짜 초기화
      clearSelectedDate: true,
    );

    await loadMonthData();
  }

  /// 날짜를 선택한다
  void selectDate(DateTime date) {
    final dayKey = DateTime(date.year, date.month, date.day);
    state = state.copyWith(selectedDate: dayKey);
  }

  /// 현재 선택된 월의 데이터를 로드한다
  /// 월별 지출 + 연속 성공일 + 전체 성공 횟수를 함께 갱신한다
  Future<void> loadMonthData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // 월별 지출과 통계를 병렬로 조회
      final results = await Future.wait([
        _repository.getMonthlyExpenses(
          year: state.selectedMonth.year,
          month: state.selectedMonth.month,
        ),
        _repository.getStreakDays(),
        _repository.getTotalSuccessCount(),
      ]);

      final monthlyExpenses =
          results[0] as Map<DateTime, List<ExpenseEntity>>;
      final streakDays = results[1] as int;
      final successCount = results[2] as int;

      state = state.copyWith(
        monthlyExpenses: monthlyExpenses,
        streakDays: streakDays,
        successCount: successCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '데이터를 불러오지 못했습니다.',
      );
    }
  }
}

/// 캘린더 ViewModel Provider — 전역 선언
/// Riverpod 코드젠 미사용, 수동 선언
final calendarViewModelProvider =
    NotifierProvider<CalendarViewModel, CalendarState>(
  CalendarViewModel.new,
);
