import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/favorite_expense.dart';

part 'favorite_templates_state.freezed.dart';

@freezed
sealed class FavoriteTemplatesState with _$FavoriteTemplatesState {
  const factory FavoriteTemplatesState({
    @Default([]) List<FavoriteExpenseEntity> favorites,
    @Default([]) List<ExpenseEntity> recentExpenses,
    @Default(true) bool isLoading,
  }) = _FavoriteTemplatesState;
}
