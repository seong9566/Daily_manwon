import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'expense_add_state.freezed.dart';

@freezed
sealed class ExpenseAddState with _$ExpenseAddState {
  const factory ExpenseAddState({
    @Default('') String amountString,
    @Default(ExpenseCategory.cafe) ExpenseCategory selectedCategory,
    @Default(false) bool isSaving,
    @Default(false) bool addToFavorite,
    @Default(false) bool saveError,
    required DateTime recordDate,
    required DateTime saveCreatedAt,
  }) = _ExpenseAddState;

  const ExpenseAddState._();

  int get amount => amountString.isEmpty ? 0 : int.parse(amountString);
  bool get canSave => amount > 0 && !isSaving;
}
