import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/domain/usecases/add_expense_use_case.dart';
import '../../../expense/domain/usecases/update_expense_use_case.dart';
import '../../../calendar/presentation/viewmodels/calendar_view_model.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/usecases/check_and_award_title_use_case.dart';
import '../../domain/usecases/delete_expense_use_case.dart';
import '../../domain/usecases/evaluate_and_award_acorn_use_case.dart';
import '../../domain/usecases/get_acorn_stats_use_case.dart';
import '../../domain/usecases/get_today_budget_use_case.dart';
import '../../domain/usecases/get_today_expenses_use_case.dart';

/// 홈 화면 상태
class HomeState {
  final int remainingBudget;
  final int totalBudget;
  final List<ExpenseEntity> expenses;
  final int totalAcorns;
  final int streakDays;
  final bool isLoading;

  /// 이월 배지 표시용 금액 (0이면 이월 없음)
  final int carryOver;

  /// 월요일 첫 접근 인터스티셜 트리거 여부
  final bool isNewWeek;

  /// 방금 획득한 칭호 이름 — null이면 신규 칭호 없음 (S-26g)
  final String? newlyAchievedTitle;

  const HomeState({
    this.remainingBudget = 10000,
    this.totalBudget = 10000,
    this.expenses = const [],
    this.totalAcorns = 0,
    this.streakDays = 0,
    this.isLoading = true,
    this.carryOver = 0,
    this.isNewWeek = false,
    this.newlyAchievedTitle,
  });

  HomeState copyWith({
    int? remainingBudget,
    int? totalBudget,
    List<ExpenseEntity>? expenses,
    int? totalAcorns,
    int? streakDays,
    bool? isLoading,
    int? carryOver,
    bool? isNewWeek,
    String? newlyAchievedTitle,
    // null로 명시적 초기화가 필요할 때 사용하는 플래그 (S-26g)
    bool clearTitle = false,
  }) {
    return HomeState(
      remainingBudget: remainingBudget ?? this.remainingBudget,
      totalBudget: totalBudget ?? this.totalBudget,
      expenses: expenses ?? this.expenses,
      totalAcorns: totalAcorns ?? this.totalAcorns,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
      carryOver: carryOver ?? this.carryOver,
      isNewWeek: isNewWeek ?? this.isNewWeek,
      newlyAchievedTitle: clearTitle ? null : (newlyAchievedTitle ?? this.newlyAchievedTitle),
    );
  }
}

/// 홈 화면 뷰모델 — 오늘의 예산, 지출, 도토리, 스트릭을 관리한다
class HomeViewModel extends Notifier<HomeState> {
  StreamSubscription<List<ExpenseEntity>>? _expenseSubscription;
  DateTime _lastActiveDate = DateTime.now();

  /// _loadData 동시 실행 방지 플래그
  bool _loadDataInProgress = false;
  bool _loadDataPending = false;

  @override
  HomeState build() {
    ref.onDispose(() => _expenseSubscription?.cancel());
    _lastActiveDate = DateTime.now();
    _loadData();
    _watchExpenses();
    return const HomeState();
  }

  /// 날짜 변경 여부를 확인하고 변경됐으면 데이터를 갱신한다.
  ///
  /// Screen의 AppLifecycleState.resumed 콜백에서 호출한다.
  void checkDateChange() {
    final now = DateTime.now();
    if (!AppDateUtils.isSameDay(now, _lastActiveDate)) {
      _lastActiveDate = now;
      _watchExpenses(); // 새 날짜 기준으로 스트림 재구독
      _loadData(); // 이월된 오늘 예산 로드
    }
  }

  /// 초기 데이터 로드 — 동시 호출 시 현재 실행이 끝난 후 한 번만 재실행한다
  Future<void> _loadData() async {
    if (_loadDataInProgress) {
      _loadDataPending = true;
      return;
    }
    _loadDataInProgress = true;
    try {
      final budgetUseCase = getIt<GetTodayBudgetUseCase>();
      final acornUseCase = getIt<GetAcornStatsUseCase>();
      final expenseUseCase = getIt<GetTodayExpensesUseCase>();

      // 전날 결과 평가 → 도토리 지급 (중복 방지 포함)
      await getIt<EvaluateAndAwardAcornUseCase>().execute();

      final settingsRepository = getIt<SettingsRepository>();

      // 오늘 예산 확보
      final budget = await budgetUseCase.getOrCreateTodayBudget();
      final totalBudget = budget.effectiveBudget;
      final carryOver = budget.carryOver;

      // 오늘 지출 목록
      final expenses = await expenseUseCase.getExpensesByDate(DateTime.now());

      // 남은 예산
      final remaining = await budgetUseCase.getRemainingBudget(DateTime.now());

      // 도토리 + 스트릭
      final acorns = await acornUseCase.getTotalAcorns();
      final streak = await acornUseCase.getStreakDays();

      // 새 주 감지 (월요일 + 이월 활성화 + 이번 주 미확인)
      final carryoverEnabled = await settingsRepository.getCarryoverEnabled();
      final weekKey = _currentWeekKey();
      final isNewWeek = DateTime.now().weekday == DateTime.monday
          && carryoverEnabled
          && !await settingsRepository.hasSeenNewWeekThisWeek(weekKey);

      // 스트릭 마일스톤 달성 시 칭호 수여 (S-26g)
      final newTitle = await getIt<CheckAndAwardTitleUseCase>().execute(streak);

      state = state.copyWith(
        remainingBudget: remaining,
        totalBudget: totalBudget,
        expenses: expenses,
        totalAcorns: acorns,
        streakDays: streak,
        isLoading: false,
        carryOver: carryOver,
        isNewWeek: isNewWeek,
        newlyAchievedTitle: newTitle,
      );

      // 홈 위젯 데이터 갱신 (비동기 실행 — 실패해도 앱 동작에 영향 없음)
      final catMood = isNewWeek
          ? 'new_week'
          : (remaining < 0 || totalBudget <= 0
              ? CharacterMood.over.name
              : CharacterMood.fromRatio(remaining / totalBudget).name);
      unawaited(getIt<WidgetService>().updateWidget(
        total: totalBudget,
        used: totalBudget - remaining,
        remaining: remaining,
        streak: streak,
        expenses: expenses
            .map((e) => {
                  'category': ExpenseCategory.values[e.category].label,
                  'time': DateFormat('HH:mm').format(e.createdAt),
                  'amount': e.amount,
                })
            .toList(),
        catMood: catMood,
      ));
    } catch (e) {
      state = state.copyWith(isLoading: false);
    } finally {
      _loadDataInProgress = false;
      if (_loadDataPending) {
        _loadDataPending = false;
        await _loadData();
      }
    }
  }

  /// 지출 변동을 실시간으로 감지하여 상태 갱신
  ///
  /// 재호출 시 이전 구독을 cancel하고 새 날짜 기준으로 재구독한다.
  void _watchExpenses() {
    _expenseSubscription?.cancel();

    final budgetUseCase = getIt<GetTodayBudgetUseCase>();
    final expenseUseCase = getIt<GetTodayExpensesUseCase>();

    _expenseSubscription =
        expenseUseCase.watchExpensesByDate(DateTime.now()).listen((expenses) async {
      final remaining = await budgetUseCase.getRemainingBudget(DateTime.now());
      state = state.copyWith(
        expenses: expenses,
        remainingBudget: remaining,
      );

      // 지출 변동 시 홈 위젯 실시간 갱신
      // _loadData 완료 전(isLoading=true)이면 streak 등 초기값이 0이므로 스킵
      if (!state.isLoading) {
        unawaited(getIt<WidgetService>().updateWidget(
          total: state.totalBudget,
          used: state.totalBudget - remaining,
          remaining: remaining,
          streak: state.streakDays,
          expenses: expenses
              .map((e) => {
                    'category': ExpenseCategory.values[e.category].label,
                    'time': DateFormat('HH:mm').format(e.createdAt),
                    'amount': e.amount,
                  })
              .toList(),
          catMood: state.isNewWeek
              ? 'new_week'
              : (remaining < 0 || state.totalBudget <= 0
                  ? CharacterMood.over.name
                  : CharacterMood.fromRatio(remaining / state.totalBudget).name),
        ));
      }
    });
  }

  /// 새 주 인터스티셜 확인 후 상태를 초기화한다
  Future<void> markNewWeekSeen() async {
    await getIt<SettingsRepository>().markNewWeekSeen(_currentWeekKey());
    state = state.copyWith(isNewWeek: false);
  }

  /// 현재 주의 월요일 기준 키를 반환한다 (yyyy-MM-dd 형식)
  String _currentWeekKey() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
    final d = DateTime(monday.year, monday.month, monday.day);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 칭호 Snackbar 표시 후 상태를 초기화한다 (S-26g)
  void clearAchievedTitle() {
    state = state.copyWith(clearTitle: true);
  }

  /// 수동 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }

  /// 지출 추가 — AddExpenseUseCase 경유, 캘린더 동기화 포함
  Future<void> addExpense(ExpenseEntity expense) async {
    await getIt<AddExpenseUseCase>().execute(expense);
    ref.invalidate(calendarViewModelProvider);
  }

  /// 지출 수정
  Future<void> updateExpense(ExpenseEntity expense) async {
    await getIt<UpdateExpenseUseCase>().execute(expense);
    ref.invalidate(calendarViewModelProvider);
  }

  /// 지출 삭제 — 홈 스트림은 watchExpenses가 자동 갱신, 캘린더는 invalidate로 동기화
  Future<void> deleteExpense(int id) async {
    await getIt<DeleteExpenseUseCase>().execute(id);
    // 캘린더 화면 데이터 동기화 (활성 상태면 즉시 재로드, 미방문이면 다음 진입 시 갱신)
    ref.invalidate(calendarViewModelProvider);
  }
}

/// 홈 뷰모델 프로바이더
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
