import 'package:injectable/injectable.dart';
import '../../../../core/utils/result.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// 최근 N일 내 지출을 최대 M건 조회 (최신순)
@lazySingleton
class GetRecentExpensesUseCase {
  const GetRecentExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<Result<List<ExpenseEntity>>> execute({int limit = 10, int days = 7}) async {
    try {
      return Result.success(
        await _repository.getRecentExpenses(limit: limit, days: days),
      );
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
