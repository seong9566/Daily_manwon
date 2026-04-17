import 'package:injectable/injectable.dart';
import '../../../../core/utils/result.dart';
import '../entities/favorite_expense.dart';
import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 목록 조회 (usageCount 내림차순)
@lazySingleton
class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<Result<List<FavoriteExpenseEntity>>> execute() async {
    try {
      return Result.success(await _repository.getFavorites());
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
