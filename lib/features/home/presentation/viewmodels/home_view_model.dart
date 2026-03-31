import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/domain/repositories/expense_repository.dart';
import '../../domain/repositories/acorn_repository.dart';
import '../../domain/repositories/daily_budget_repository.dart';

/// 홈 화면 상태
class HomeState {
  final int remainingBudget;
  final int totalBudget;
  final int carryOver;
  final List<ExpenseEntity> expenses;
  final int totalAcorns;
  final int streakDays;
  final bool isLoading;

  const HomeState({
    this.remainingBudget = 10000,
    this.totalBudget = 10000,
    this.carryOver = 0,
    this.expenses = const [],
    this.totalAcorns = 0,
    this.streakDays = 0,
    this.isLoading = true,
  });

  HomeState copyWith({
    int? remainingBudget,
    int? totalBudget,
    int? carryOver,
    List<ExpenseEntity>? expenses,
    int? totalAcorns,
    int? streakDays,
    bool? isLoading,
  }) {
    return HomeState(
      remainingBudget: remainingBudget ?? this.remainingBudget,
      totalBudget: totalBudget ?? this.totalBudget,
      carryOver: carryOver ?? this.carryOver,
      expenses: expenses ?? this.expenses,
      totalAcorns: totalAcorns ?? this.totalAcorns,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 홈 화면 뷰모델 — 오늘의 예산, 지출, 도토리, 스트릭을 관리한다
class HomeViewModel extends Notifier<HomeState> {
  StreamSubscription<List<ExpenseEntity>>? _expenseSubscription;
  DateTime _lastActiveDate = DateTime.now();

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

  /// 초기 데이터 로드
  Future<void> _loadData() async {
    try {
      final budgetRepo = getIt<DailyBudgetRepository>();
      final acornRepo = getIt<AcornRepository>();
      final expenseRepo = getIt<ExpenseRepository>();

      // 오늘 예산 확보
      final budget = await budgetRepo.getOrCreateTodayBudget();
      final totalBudget = budget.baseAmount + budget.carryOver;

      // 오늘 지출 목록
      final expenses = await expenseRepo.getExpensesByDate(DateTime.now());

      // 남은 예산
      final remaining = await budgetRepo.getRemainingBudget(DateTime.now());

      // 도토리 + 스트릭
      final acorns = await acornRepo.getTotalAcorns();
      final streak = await acornRepo.getStreakDays();

      state = state.copyWith(
        remainingBudget: remaining,
        totalBudget: totalBudget,
        carryOver: budget.carryOver,
        expenses: expenses,
        totalAcorns: acorns,
        streakDays: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// 지출 변동을 실시간으로 감지하여 상태 갱신
  ///
  /// 재호출 시 이전 구독을 cancel하고 새 날짜 기준으로 재구독한다.
  void _watchExpenses() {
    _expenseSubscription?.cancel();

    final budgetRepo = getIt<DailyBudgetRepository>();
    final expenseRepo = getIt<ExpenseRepository>();

    _expenseSubscription =
        expenseRepo.watchExpensesByDate(DateTime.now()).listen((expenses) async {
      final remaining = await budgetRepo.getRemainingBudget(DateTime.now());
      state = state.copyWith(
        expenses: expenses,
        remainingBudget: remaining,
      );
    });
  }

  /// 수동 새로고침
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }

  /// 지출 삭제
  Future<void> deleteExpense(int id) async {
    final expenseRepo = getIt<ExpenseRepository>();
    await expenseRepo.deleteExpense(id);
    // watchExpenses가 자동으로 상태를 갱신함
  }
}

/// 홈 뷰모델 프로바이더
final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
