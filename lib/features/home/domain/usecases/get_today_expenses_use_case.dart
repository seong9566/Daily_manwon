import 'package:injectable/injectable.dart';

import '../../../expense/domain/entities/expense.dart';
import '../../../expense/domain/repositories/expense_repository.dart';

/// 오늘 지출 조회 UseCase
@lazySingleton
class GetTodayExpensesUseCase {
  const GetTodayExpensesUseCase(this._repository);
  final ExpenseRepository _repository;

  /// 특정 날짜의 지출 목록을 한 번 조회한다
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date) =>
      _repository.getExpensesByDate(date);

  /// 특정 날짜의 지출 목록을 실시간으로 구독한다
  Stream<List<ExpenseEntity>> watchExpensesByDate(DateTime date) =>
      _repository.watchExpensesByDate(date);
}
