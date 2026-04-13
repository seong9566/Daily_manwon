import 'package:injectable/injectable.dart';

import '../entities/category_stat.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetCategoryStatsUseCase {
  final StatsRepository _repository;

  GetCategoryStatsUseCase(this._repository);

  Future<List<CategoryStat>> execute({required int year, required int month}) =>
      _repository.getCategoryStats(year: year, month: month);
}
