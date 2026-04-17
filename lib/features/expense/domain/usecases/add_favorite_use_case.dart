import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../entities/favorite_expense.dart';
import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 추가
@lazySingleton
class AddFavoriteUseCase {
  const AddFavoriteUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<Result<void>> execute({
    required int amount,
    required ExpenseCategory category,
    String memo = '',
  }) async {
    try {
      await _repository.addFavorite(
        FavoriteExpenseEntity(
          amount: amount,
          category: category,
          memo: memo,
          createdAt: DateTime.now(),
        ),
      );
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
