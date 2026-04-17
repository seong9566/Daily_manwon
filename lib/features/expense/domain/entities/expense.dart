import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'expense.freezed.dart';

@freezed
sealed class ExpenseEntity with _$ExpenseEntity {
  const factory ExpenseEntity({
    @Default(0) int id,
    required int amount,
    required ExpenseCategory category,
    @Default('') String memo,
    required DateTime createdAt,
  }) = _ExpenseEntity;
}
