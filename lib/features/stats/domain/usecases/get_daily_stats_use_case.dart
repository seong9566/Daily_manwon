import 'package:injectable/injectable.dart';

import '../entities/daily_stat.dart';
import '../repositories/stats_repository.dart';

/// 해당 주의 일별 지출 통계를 반환하는 유스케이스
@lazySingleton
class GetDailyStatsUseCase {
  final StatsRepository _repository;

  GetDailyStatsUseCase(this._repository);

  Future<List<DailyStat>> execute({required DateTime weekStart}) =>
      _repository.getDailyStatsForWeek(weekStart);
}
