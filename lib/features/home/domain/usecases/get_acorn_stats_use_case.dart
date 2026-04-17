import 'package:injectable/injectable.dart';

import '../entities/acorn.dart';
import '../repositories/acorn_repository.dart';

/// 고양이 발도장/스트릭 통계 조회 UseCase
@lazySingleton
class GetAcornStatsUseCase {
  const GetAcornStatsUseCase(this._repository);
  final AcornRepository _repository;

  /// 전체 고양이 발도장 개수 조회
  Future<int> getTotalAcorns() => _repository.getTotalAcorns();

  /// 오늘부터 역추적한 연속 성공 일수 조회
  Future<int> getStreakDays() => _repository.getStreakDays();

  /// 특정 날짜의 고양이 발도장 목록 조회
  Future<List<AcornEntity>> getAcornsByDate(DateTime date) =>
      _repository.getAcornsByDate(date);

  /// 고양이 발도장 추가
  Future<void> addAcorn(int amount, String reason, {DateTime? date}) =>
      _repository.addAcorn(amount, reason, date: date);
}
