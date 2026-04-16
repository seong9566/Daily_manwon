import 'package:injectable/injectable.dart';

import '../../domain/entities/favorite_expense.dart';
import '../../domain/repositories/favorite_expense_repository.dart';
import '../datasources/favorite_expense_datasource.dart';

/// 즐겨찾기 지출 템플릿 저장소 구현체
@LazySingleton(as: FavoriteExpenseRepository)
class FavoriteExpenseRepositoryImpl implements FavoriteExpenseRepository {
  final FavoriteExpenseDatasource _datasource;

  FavoriteExpenseRepositoryImpl(this._datasource);

  @override
  Future<List<FavoriteExpenseEntity>> getFavorites() =>
      _datasource.getFavorites();

  @override
  Future<void> addFavorite(FavoriteExpenseEntity favorite) =>
      _datasource.addFavorite(favorite);

  @override
  Future<void> deleteFavorite(int id) => _datasource.deleteFavorite(id);

  @override
  Future<void> incrementUsageCount(int id) =>
      _datasource.incrementUsageCount(id);

  @override
  Future<void> syncAutoFavorites() => _datasource.syncAutoFavorites();
}
