import 'package:daily_manwon/features/home/data/datasources/acorn_local_datasource.dart';
import 'package:daily_manwon/features/home/domain/repositories/acorn_repository.dart';
import 'package:injectable/injectable.dart';

/// AcornRepository 인터페이스의 Drift 기반 구현체
@LazySingleton(as: AcornRepository)
class AcornRepositoryImpl implements AcornRepository {
  final AcornLocalDatasource _datasource;

  AcornRepositoryImpl(this._datasource);

  @override
  Future<int> getTotalAcorns() => _datasource.getTotalAcorns();

  @override
  Future<void> addAcorn(int count, String reason) =>
      _datasource.addAcorn(count, reason);

  @override
  Future<int> getStreakDays() => _datasource.getStreakDays();
}
