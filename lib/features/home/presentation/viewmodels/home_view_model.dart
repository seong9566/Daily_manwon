import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
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
  @override
  HomeState build() {
    _loadData();
    _watchExpenses();
    return const HomeState();
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
  void _watchExpenses() {
    final budgetRepo = getIt<DailyBudgetRepository>();
    final expenseRepo = getIt<ExpenseRepository>();

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
