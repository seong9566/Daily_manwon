import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_expense.freezed.dart';

@freezed
sealed class FavoriteExpenseEntity with _$FavoriteExpenseEntity {
  const factory FavoriteExpenseEntity({
    required int id,
    required int amount,
    required int category,   // ExpenseCategory.index
    @Default('') String memo,
    @Default(0) int usageCount,
    required DateTime createdAt,
  }) = _FavoriteExpenseEntity;
}
