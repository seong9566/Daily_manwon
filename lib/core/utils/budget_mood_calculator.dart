import '../constants/app_constants.dart';

/// 예산과 지출로 오늘의 고양이 감정을 계산한다
CharacterMood calculateMood(int budget, int spent) {
  if (budget <= 0) return CharacterMood.danger;
  final ratio = (budget - spent) / budget;
  return CharacterMood.fromRatio(ratio);
}
