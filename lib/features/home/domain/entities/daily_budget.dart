import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_budget.freezed.dart';

@freezed
sealed class DailyBudgetEntity with _$DailyBudgetEntity {
  const DailyBudgetEntity._();

  const factory DailyBudgetEntity({
    required int id,
    required DateTime date,
    @Default(10000) int baseAmount,
    @Default(0) int carryOver,
  }) = _DailyBudgetEntity;

  int get effectiveBudget => baseAmount + carryOver;
}
