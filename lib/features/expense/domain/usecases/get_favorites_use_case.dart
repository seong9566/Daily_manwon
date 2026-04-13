import 'package:injectable/injectable.dart';

import '../entities/favorite_expense.dart';
import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 목록 조회 (usageCount 내림차순)
@lazySingleton
class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<List<FavoriteExpenseEntity>> execute() => _repository.getFavorites();
}
