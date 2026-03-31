import 'package:injectable/injectable.dart';

import '../../../expense/domain/repositories/expense_repository.dart';

/// 지출 삭제 UseCase
@lazySingleton
class DeleteExpenseUseCase {
  const DeleteExpenseUseCase(this._repository);
  final ExpenseRepository _repository;

  /// ID로 지출 항목을 삭제한다
  Future<void> execute(int id) => _repository.deleteExpense(id);
}
