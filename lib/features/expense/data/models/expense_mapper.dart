import 'package:drift/drift.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/expense.dart';

extension ExpenseMapper on Expense {
  ExpenseEntity toEntity() => ExpenseEntity(
        id: id,
        amount: amount,
        category: ExpenseCategory.values[category],
        memo: memo,
        createdAt: createdAt,
      );
}

extension ExpenseEntityMapper on ExpenseEntity {
  ExpensesCompanion toCompanion() => ExpensesCompanion.insert(
        amount: amount,
        category: category.index,
        memo: Value(memo),
        createdAt: createdAt,
      );
}
