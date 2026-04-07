import 'package:injectable/injectable.dart';

import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// 지출 수정 UseCase
@lazySingleton
class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  /// 지출 엔티티를 수정한다
  Future<void> execute(ExpenseEntity expense) =>
      _repository.updateExpense(expense);
}
