import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';

@freezed
sealed class AchievementEntity with _$AchievementEntity {
  const factory AchievementEntity({
    required int id,
    required String type,
    required DateTime achievedAt,
  }) = _AchievementEntity;
}
