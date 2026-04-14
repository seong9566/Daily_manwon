import 'package:injectable/injectable.dart';

import '../entities/weekday_stat.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetWeekdayStatsUseCase {
  final StatsRepository _repository;

  GetWeekdayStatsUseCase(this._repository);

  Future<List<WeekdayStat>> execute({
    required int year,
    required int month,
  }) => _repository.getWeekdayStats(year: year, month: month);
}
