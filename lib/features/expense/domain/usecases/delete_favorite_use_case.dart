import 'package:injectable/injectable.dart';

import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 삭제
@lazySingleton
class DeleteFavoriteUseCase {
  const DeleteFavoriteUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<void> execute(int id) => _repository.deleteFavorite(id);
}
