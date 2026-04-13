import 'package:injectable/injectable.dart';

import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 사용 횟수 증가
@lazySingleton
class IncrementFavoriteUsageUseCase {
  const IncrementFavoriteUsageUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<void> execute(int id) => _repository.incrementUsageCount(id);
}
