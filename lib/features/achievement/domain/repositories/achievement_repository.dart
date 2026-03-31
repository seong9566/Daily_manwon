import '../entities/achievement.dart';

/// 업적 저장/조회 Repository 인터페이스 (S-26g)
abstract interface class AchievementRepository {
  /// 전체 업적 목록 조회
  Future<List<AchievementEntity>> getAllAchievements();

  /// 특정 type의 업적이 이미 기록됐는지 확인
  Future<bool> hasAchievement(String type);

  /// 신규 업적 기록 저장
  Future<void> addAchievement(String type);
}
