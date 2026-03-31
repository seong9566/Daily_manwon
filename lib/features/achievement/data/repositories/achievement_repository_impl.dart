import 'package:daily_manwon/features/achievement/data/datasources/achievement_local_datasource.dart';
import 'package:daily_manwon/features/achievement/domain/entities/achievement.dart';
import 'package:daily_manwon/features/achievement/domain/repositories/achievement_repository.dart';
import 'package:injectable/injectable.dart';

/// AchievementRepository 인터페이스의 Drift 기반 구현체 (S-26g)
@LazySingleton(as: AchievementRepository)
class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementLocalDatasource _datasource;

  AchievementRepositoryImpl(this._datasource);

  @override
  Future<List<AchievementEntity>> getAllAchievements() =>
      _datasource.getAllAchievements();

  @override
  Future<bool> hasAchievement(String type) =>
      _datasource.hasAchievement(type);

  @override
  Future<void> addAchievement(String type) =>
      _datasource.addAchievement(type);
}
