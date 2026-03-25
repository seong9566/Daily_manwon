import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

@freezed
sealed class ExpenseEntity with _$ExpenseEntity {
  const factory ExpenseEntity({
    required int id,
    required int amount,
    required int category,
    @Default('') String memo,
    required DateTime createdAt,
  }) = _ExpenseEntity;
}
