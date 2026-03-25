import 'package:drift/drift.dart';

import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';

extension ExpenseMapper on Expense {
  ExpenseEntity toEntity() => ExpenseEntity(
        id: id,
        amount: amount,
        category: category,
        memo: memo,
        createdAt: createdAt,
      );
}

extension ExpenseEntityMapper on ExpenseEntity {
  ExpensesCompanion toCompanion() => ExpensesCompanion.insert(
        amount: amount,
        category: category,
        memo: Value(memo),
        createdAt: createdAt,
      );
}
