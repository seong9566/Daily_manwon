import 'package:injectable/injectable.dart';

import '../../../achievement/domain/repositories/achievement_repository.dart';

/// 스트릭 마일스톤 달성 시 칭호 수여 UseCase (S-26g)
///
/// streak >= milestone인 모든 미수여 칭호를 DB에 기록하고,
/// 가장 높은 신규 칭호명을 반환한다. 없으면 null.
@lazySingleton
class CheckAndAwardTitleUseCase {
  const CheckAndAwardTitleUseCase(this._repository);
  final AchievementRepository _repository;

  /// 스트릭 마일스톤별 칭호 정의 — key: 달성 일수, value: (DB type, 표시명)
  static const Map<int, (String, String)> _titleMilestones = {
    3: ('streak_3', '절약 새싹 🌱'),
    7: ('streak_7', '절약 고수 🌿'),
    14: ('streak_14', '절약 달인 🌳'),
    30: ('streak_30', '절약 전설 🏆'),
  };

  /// 미수여 마일스톤을 모두 수여하고 가장 높은 신규 칭호명을 반환한다
  Future<String?> execute(int streak) async {
    String? latestTitle;
    // 낮은 일수부터 순서대로 확인하여 모든 미수여 마일스톤 수여
    for (final entry in _titleMilestones.entries) {
      if (streak < entry.key) continue;
      final (type, title) = entry.value;
      final alreadyAwarded = await _repository.hasAchievement(type);
      if (alreadyAwarded) continue;
      await _repository.addAchievement(type);
      latestTitle = title;
    }
    return latestTitle;
  }
}
