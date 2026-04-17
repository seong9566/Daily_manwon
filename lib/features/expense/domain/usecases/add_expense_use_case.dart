import 'package:injectable/injectable.dart';
import '../../../../core/utils/result.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// 지출 추가 UseCase — Repository 경유로 지출을 저장한다
@lazySingleton
class AddExpenseUseCase {
  const AddExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<Result<ExpenseEntity>> execute(ExpenseEntity expense) async {
    try {
      return Result.success(await _repository.addExpense(expense));
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
