import 'package:daily_manwon/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/expense_repository.dart';
import 'package:injectable/injectable.dart';

/// ExpenseRepository 인터페이스의 Drift 기반 구현체
@LazySingleton(as: ExpenseRepository)
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource _datasource;

  ExpenseRepositoryImpl(this._datasource);

  @override
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date) {
    return _datasource.getExpensesByDate(date);
  }

  @override
  Future<ExpenseEntity> addExpense(ExpenseEntity expense) {
    return _datasource.addExpense(expense);
  }

  @override
  Future<void> updateExpense(ExpenseEntity expense) {
    return _datasource.updateExpense(expense);
  }

  @override
  Future<void> deleteExpense(int id) {
    return _datasource.deleteExpense(id);
  }

  @override
  Stream<List<ExpenseEntity>> watchExpensesByDate(DateTime date) {
    return _datasource.watchExpensesByDate(date);
  }
}
