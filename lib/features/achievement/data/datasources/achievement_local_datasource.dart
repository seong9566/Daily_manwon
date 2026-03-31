import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/achievement/data/models/achievement_mapper.dart';
import 'package:daily_manwon/features/achievement/domain/entities/achievement.dart';
import 'package:injectable/injectable.dart';

/// 업적 Drift 로컬 데이터소스 (S-26g)
/// Achievements 테이블에 대한 CRUD를 담당한다
@lazySingleton
class AchievementLocalDatasource {
  final AppDatabase _db;

  AchievementLocalDatasource(this._db);

  /// 전체 업적 목록 조회
  Future<List<AchievementEntity>> getAllAchievements() async {
    final rows = await _db.select(_db.achievements).get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// 특정 type의 업적이 이미 기록됐는지 확인 (중복 수여 방지)
  Future<bool> hasAchievement(String type) async {
    final row = await (_db.select(_db.achievements)
          ..where((t) => t.type.equals(type)))
        .getSingleOrNull();
    return row != null;
  }

  /// 신규 업적 기록 저장
  Future<void> addAchievement(String type) async {
    await _db.into(_db.achievements).insert(
          AchievementsCompanion.insert(
            type: type,
            achievedAt: DateTime.now(),
          ),
        );
  }
}
