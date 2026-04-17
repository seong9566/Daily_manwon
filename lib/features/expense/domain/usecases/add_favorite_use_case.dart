import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/favorite_expense.dart';
import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 추가
@lazySingleton
class AddFavoriteUseCase {
  const AddFavoriteUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<void> execute({
    required int amount,
    required ExpenseCategory category,
    String memo = '',
  }) =>
      _repository.addFavorite(
        FavoriteExpenseEntity(
          amount: amount,
          category: category,
          memo: memo,
          createdAt: DateTime.now(),
        ),
      );
}
