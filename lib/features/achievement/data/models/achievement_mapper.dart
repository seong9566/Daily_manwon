import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/achievement/domain/entities/achievement.dart';

/// Drift의 Achievement DataClass ↔ AchievementEntity 변환 확장
extension AchievementMapper on Achievement {
  /// DB 레코드를 도메인 엔티티로 변환
  AchievementEntity toEntity() => AchievementEntity(
        id: id,
        type: type,
        achievedAt: achievedAt,
      );
}

/// AchievementEntity → Drift Insert Companion 변환 확장
/// - 신규 업적 달성 기록 시 사용
extension AchievementEntityMapper on AchievementEntity {
  AchievementsCompanion toCompanion() => AchievementsCompanion.insert(
        type: type,
        achievedAt: achievedAt,
      );
}
