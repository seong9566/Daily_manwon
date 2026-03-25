import 'package:drift/drift.dart';

import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';

extension DailyBudgetMapper on DailyBudget {
  DailyBudgetEntity toEntity() => DailyBudgetEntity(
        id: id,
        date: date,
        baseAmount: baseAmount,
        carryOver: carryOver,
      );
}

extension DailyBudgetEntityMapper on DailyBudgetEntity {
  DailyBudgetsCompanion toCompanion() => DailyBudgetsCompanion.insert(
        date: date,
        baseAmount: Value(baseAmount),
        carryOver: Value(carryOver),
      );
}
