import 'package:injectable/injectable.dart';
import '../../../../core/utils/result.dart';
import '../repositories/favorite_expense_repository.dart';

/// 즐겨찾기 사용 횟수 증가
@lazySingleton
class IncrementFavoriteUsageUseCase {
  const IncrementFavoriteUsageUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  Future<Result<void>> execute(int id) async {
    try {
      await _repository.incrementUsageCount(id);
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
