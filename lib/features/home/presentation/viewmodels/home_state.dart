import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../expense/domain/entities/expense.dart';
import '../../../expense/domain/entities/favorite_expense.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    @Default(10000) int remainingBudget,
    @Default(10000) int totalBudget,
    @Default([]) List<ExpenseEntity> expenses,
    @Default(0) int totalAcorns,
    @Default(0) int streakDays,
    @Default(true) bool isLoading,
    @Default(0) int carryOver,
    @Default(false) bool isNewWeek,
    @Default([]) List<FavoriteExpenseEntity> favorites,
    @Default([]) List<ExpenseEntity> recentExpenses,
  }) = _HomeState;
}
