import 'package:injectable/injectable.dart';

import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// 지출 추가 UseCase — Repository 경유로 지출을 저장한다
@lazySingleton
class AddExpenseUseCase {
  const AddExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  /// 지출 엔티티를 저장하고 저장된 엔티티를 반환한다
  Future<ExpenseEntity> execute(ExpenseEntity expense) =>
      _repository.addExpense(expense);
}
