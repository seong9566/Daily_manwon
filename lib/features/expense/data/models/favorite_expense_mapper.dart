import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/favorite_expense.dart';

extension FavoriteExpenseRowMapper on FavoriteExpense {
  FavoriteExpenseEntity toEntity() => FavoriteExpenseEntity(
        id: id,
        amount: amount,
        category: category,
        memo: memo,
        usageCount: usageCount,
        isAuto: isAuto,
        createdAt: createdAt,
      );
}

extension FavoriteExpenseEntityMapper on FavoriteExpenseEntity {
  FavoriteExpensesCompanion toCompanion() => FavoriteExpensesCompanion.insert(
        amount: amount,
        category: category,
        memo: Value(memo),
        isAuto: Value(isAuto),
        createdAt: createdAt,
      );
}
