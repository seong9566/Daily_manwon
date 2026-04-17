import 'package:injectable/injectable.dart';
import '../../../../core/utils/result.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// 지출 수정 UseCase
@lazySingleton
class UpdateExpenseUseCase {
  const UpdateExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<Result<void>> execute(ExpenseEntity expense) async {
    try {
      await _repository.updateExpense(expense);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
