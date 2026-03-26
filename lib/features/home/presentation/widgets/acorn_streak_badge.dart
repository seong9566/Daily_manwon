import 'package:flutter/material.dart';

/// 도토리 수 + 스트릭 일수 표시 배지 (U-07)
/// "🌰 12 · 🔥 7일" 형식으로 가운데 정렬
class AcornStreakBadge extends StatelessWidget {
  final int totalAcorns;
  final int streakDays;

  const AcornStreakBadge({
    super.key,
    required this.totalAcorns,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🌰 $totalAcorns', style: textStyle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('·', style: textStyle),
        ),
        Text('🔥 $streakDays일', style: textStyle),
      ],
    );
  }
}
