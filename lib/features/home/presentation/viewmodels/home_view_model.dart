import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/domain/entities/favorite_expense.dart';
import '../../../expense/domain/usecases/add_expense_use_case.dart';
import '../../../expense/domain/usecases/add_favorite_use_case.dart';
import '../../../expense/domain/usecases/delete_favorite_use_case.dart';
import '../../../expense/domain/usecases/get_favorites_use_case.dart';
import '../../../expense/domain/usecases/increment_favorite_usage_use_case.dart';
import '../../../expense/domain/usecases/update_expense_use_case.dart';
import '../../../calendar/presentation/viewmodels/calendar_view_model.dart';
import '../../../expense/domain/usecases/get_recent_expenses_use_case.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
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

  /// 일요일 첫 접근 인터스티셜 트리거 여부
  final bool isNewWeek;

  /// 수동 즐겨찾기 목록 (usageCount 내림차순)
  final List<FavoriteExpenseEntity> favorites;

  /// 최근 7일 내 지출 최대 10건 (최신순) — "최근 내역" 탭용
  final List<ExpenseEntity> recentExpenses;

  const HomeState({
    this.remainingBudget = 10000,
    this.totalBudget = 10000,
    this.expenses = const [],
    this.totalAcorns = 0,
    this.streakDays = 0,
    this.isLoading = true,
    this.carryOver = 0,
    this.isNewWeek = false,
    this.favorites = const [],
    this.recentExpenses = const [],
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
    List<FavoriteExpenseEntity>? favorites,
    List<ExpenseEntity>? recentExpenses,
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
      favorites: favorites ?? this.favorites,
      recentExpenses: recentExpenses ?? this.recentExpenses,
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

      // 새 주 감지 (일요일 + 이월 활성화 + 이번 주 미확인)
      final carryoverEnabled = await settingsRepository.getCarryoverEnabled();
      final weekKey = _currentWeekKey();
      final isNewWeek =
          DateTime.now().weekday == DateTime.sunday &&
          carryoverEnabled &&
          !await settingsRepository.hasSeenNewWeekThisWeek(weekKey);

      final favoritesList = await getIt<GetFavoritesUseCase>().execute();
      final recentList = await getIt<GetRecentExpensesUseCase>().execute();

      state = state.copyWith(
        remainingBudget: remaining,
        totalBudget: totalBudget,
        expenses: expenses,
        totalAcorns: acorns,
        streakDays: streak,
        isLoading: false,
        carryOver: carryOver,
        isNewWeek: isNewWeek,
        favorites: favoritesList,
        recentExpenses: recentList,
      );

      // 홈 위젯 데이터 갱신 (비동기 실행 — 실패해도 앱 동작에 영향 없음)
      final catMood = isNewWeek
          ? 'new_week'
          : CharacterMood.fromRemaining(remaining, totalBudget).name;
      unawaited(
        getIt<WidgetService>().updateWidget(
          total: totalBudget,
          used: totalBudget - remaining,
          remaining: remaining,
          streak: streak,
          expenses: expenses
              .map(
                (e) => {
                  'category': e.category.label,
                  'time': DateFormat('HH:mm').format(e.createdAt),
                  'amount': e.amount,
                },
              )
              .toList(),
          catMood: catMood,
          favorites: favoritesList
              .map((f) => {
                    'id': f.id,
                    'amount': f.amount,
                    'category': f.category.index,
                    'memo': f.memo,
                  })
              .toList(),
        ),
      );
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

    _expenseSubscription = expenseUseCase
        .watchExpensesByDate(DateTime.now())
        .listen((expenses) async {
          final remaining = await budgetUseCase.getRemainingBudget(
            DateTime.now(),
          );
          state = state.copyWith(
            expenses: expenses,
            remainingBudget: remaining,
          );

          // 지출 변동 시 홈 위젯 실시간 갱신
          // _loadData 완료 전(isLoading=true)이면 streak 등 초기값이 0이므로 스킵
          if (!state.isLoading) {
            final favoritesList = await getIt<GetFavoritesUseCase>().execute();
            final recentList = await getIt<GetRecentExpensesUseCase>().execute();
            state = state.copyWith(
              favorites: favoritesList,
              recentExpenses: recentList,
            );
            unawaited(
              getIt<WidgetService>().updateWidget(
                total: state.totalBudget,
                used: state.totalBudget - remaining,
                remaining: remaining,
                streak: state.streakDays,
                expenses: expenses
                    .map(
                      (e) => {
                        'category': e.category.label,
                        'time': DateFormat('HH:mm').format(e.createdAt),
                        'amount': e.amount,
                      },
                    )
                    .toList(),
                catMood: state.isNewWeek
                    ? 'new_week'
                    : CharacterMood.fromRemaining(
                        remaining,
                        state.totalBudget,
                      ).name,
                favorites: favoritesList
                    .map((f) => {
                          'id': f.id,
                          'amount': f.amount,
                          'category': f.category.index,
                          'memo': f.memo,
                        })
                    .toList(),
              ),
            );
          }
        });
  }

  /// 새 주 인터스티셜 확인 후 상태를 초기화한다
  Future<void> markNewWeekSeen() async {
    await getIt<SettingsRepository>().markNewWeekSeen(_currentWeekKey());
    state = state.copyWith(isNewWeek: false);
  }

  /// 현재 주의 일요일 기준 키를 반환한다 (yyyy-MM-dd 형식)
  String _currentWeekKey() {
    final now = DateTime.now();
    final sunday = AppDateUtils.weekStartOf(now);
    return '${sunday.year}-${sunday.month.toString().padLeft(2, '0')}-${sunday.day.toString().padLeft(2, '0')}';
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

  /// 지출 추가
  Future<void> addExpense(ExpenseEntity expense) async {
    await getIt<AddExpenseUseCase>().execute(expense);
    ref.invalidate(calendarViewModelProvider);
  }

  /// 지출 수정
  Future<void> updateExpense(ExpenseEntity expense) async {
    await getIt<UpdateExpenseUseCase>().execute(expense);
    ref.invalidate(calendarViewModelProvider);
  }

  /// 지출 삭제
  Future<void> deleteExpense(int id) async {
    await getIt<DeleteExpenseUseCase>().execute(id);
    ref.invalidate(calendarViewModelProvider);
  }

  /// 위젯 버튼 탭으로 기록된 pending 지출을 처리한다.
  ///
  /// HomeScreen의 AppLifecycleState.resumed 콜백에서 호출한다.
  /// 처리 후 [_watchExpenses] 스트림이 자동으로 변경을 감지해 UI를 갱신한다.
  Future<void> processPendingWidgetExpense() async {
    await getIt<WidgetService>().processPendingWidgetExpense();
  }

  /// 위젯 "직접 입력(+)" 버튼 탭 여부를 확인하고 플래그를 초기화한다.
  ///
  /// HomeScreen의 initState 및 AppLifecycleState.resumed 콜백에서 호출한다.
  /// true 반환 시 HomeScreen에서 showExpenseAddBottomSheet를 호출해야 한다.
  ///
  /// 이 메서드는 도메인 로직이 없는 아키텍처 경계 위임자다.
  /// Screen → Service 직접 호출을 차단하기 위해 존재한다.
  Future<bool> checkPendingOpenExpense() async {
    return getIt<WidgetService>().checkAndClearPendingOpenExpense();
  }

  /// 즐겨찾기 추가 — DB 저장 후 state 갱신
  Future<void> addFavorite({
    required int amount,
    required ExpenseCategory category,
    String memo = '',
  }) async {
    await getIt<AddFavoriteUseCase>().execute(
      amount: amount,
      category: category,
      memo: memo,
    );

    final updated = await getIt<GetFavoritesUseCase>().execute();
    state = state.copyWith(favorites: updated);
  }

  /// 즐겨찾기 삭제 — DB 삭제 후 state 갱신 + iOS 위젯 favoritesKey 동기화
  Future<void> deleteFavorite(int id) async {
    await getIt<DeleteFavoriteUseCase>().execute(id);
    final updated = await getIt<GetFavoritesUseCase>().execute();
    state = state.copyWith(favorites: updated);
    unawaited(
      getIt<WidgetService>().updateFavorites(
        updated
            .map(
              (f) => {
                'id': f.id,
                'amount': f.amount,
                'category': f.category.index,
                'memo': f.memo,
              },
            )
            .toList(),
      ),
    );
  }

  /// 즐겨찾기 사용 횟수 증가 — usageCount 변동으로 정렬이 바뀔 수 있으므로 state 갱신
  Future<void> incrementFavoriteUsage(int id) async {
    await getIt<IncrementFavoriteUsageUseCase>().execute(id);
    final updated = await getIt<GetFavoritesUseCase>().execute();
    state = state.copyWith(favorites: updated);
  }

  /// 기존 지출과 동일한 내용을 현재 시각으로 새로 저장한다
  Future<void> repeatExpense(ExpenseEntity expense) async {
    await addExpense(
      ExpenseEntity(
        amount: expense.amount,
        category: expense.category,
        memo: expense.memo,
        createdAt: DateTime.now(),
      ),
    );
  }
}

/// 홈 뷰모델 프로바이더
final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
