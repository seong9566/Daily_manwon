import 'package:drift/drift.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/favorite_expense.dart';

extension FavoriteExpenseRowMapper on FavoriteExpense {
  FavoriteExpenseEntity toEntity() => FavoriteExpenseEntity(
        id: id,
        amount: amount,
        category: ExpenseCategory.values[category],
        memo: memo,
        usageCount: usageCount,
        createdAt: createdAt,
      );
}

extension FavoriteExpenseEntityMapper on FavoriteExpenseEntity {
  FavoriteExpensesCompanion toCompanion() => FavoriteExpensesCompanion.insert(
        amount: amount,
        category: category.index,
        memo: Value(memo),
        createdAt: createdAt,
      );
}
