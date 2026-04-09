import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_constants.dart';

/// 예산 잔액 비율에 따라 고양이 감정 이미지를 전환하는 인디케이터
///
/// [AnimatedSwitcher] + [FadeTransition]으로 mood 전환 시 부드러운 fade 제공.
/// mood별 idle 루프 애니메이션이 항상 재생되며, [lastExpenseId]가 변경될 때마다
/// mood에 맞는 마이크로 애니메이션이 추가로 한 번 재트리거된다.
/// RGBA 투명 PNG이므로 라이트/다크 테마 별도 처리 불필요.
class BudgetCatIndicator extends StatelessWidget {
  final CharacterMood mood;

  /// 위젯 크기 (기본 120dp)
  final double size;

  /// 마지막으로 추가된 지출 ID — 변경 시 mood별 마이크로 애니메이션을 재트리거
  final int? lastExpenseId;

  const BudgetCatIndicator({
    super.key,
    required this.mood,
    this.size = 120,
    this.lastExpenseId,
  });

  @override
  Widget build(BuildContext context) {
    final catImage = Image.asset(
      mood.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // idle loop → micro animation 순서로 래핑
    final animated = _buildMicroAnimation(_buildIdleLoop(catImage));

    // AnimatedSwitcher는 mood 전환 시에만 fade 트리거 (SizedBox의 ValueKey(mood) 기준)
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: SizedBox(
        key: ValueKey(mood),
        width: size,
        height: size,
        child: animated,
      ),
    );
  }

  /// mood별 idle 루프 애니메이션 (앱이 홈 화면을 표시하는 동안 항상 재생)
  Widget _buildIdleLoop(Widget child) {
    switch (mood) {
      case CharacterMood.comfortable:
        // 느긋하게 부유 (scale 1.0→1.05 reverse loop)
        return child
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            );
      case CharacterMood.normal:
        // 살짝 위아래 float (moveY 0→-5 reverse loop)
        return child
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -5,
              duration: 1800.ms,
              curve: Curves.easeInOut,
            );
      case CharacterMood.danger:
        // 귀 쫑긋 반복 (gentle shakeX loop)
        return child
            .animate(onPlay: (c) => c.repeat())
            .shakeX(hz: 2, amount: 3, duration: 2000.ms);
      case CharacterMood.over:
        // 발 동동 반복 (rapid shakeX loop)
        return child
            .animate(onPlay: (c) => c.repeat())
            .shakeX(hz: 4, amount: 5, duration: 1200.ms);
    }
  }

  /// mood별 마이크로 애니메이션 (lastExpenseId 변경 시 한 번 재생 후 idle loop로 복귀)
  Widget _buildMicroAnimation(Widget child) {
    switch (mood) {
      case CharacterMood.comfortable:
        // 느긋하게 기지개 (scale bounce)
        return child
            .animate(key: ValueKey(lastExpenseId))
            .scale(
              begin: const Offset(0.92, 0.92),
              duration: 350.ms,
              curve: Curves.elasticOut,
            )
            .then(delay: 0.ms)
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 200.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
              curve: Curves.elasticOut,
            );
      case CharacterMood.normal:
        // 고개 끄덕 (translateY)
        return child
            .animate(key: ValueKey(lastExpenseId))
            .scale(
              begin: const Offset(0.92, 0.92),
              duration: 350.ms,
              curve: Curves.elasticOut,
            )
            .then(delay: 0.ms)
            .moveY(begin: 0, end: -8, duration: 150.ms)
            .then()
            .moveY(begin: -8, end: 0, duration: 150.ms);
      case CharacterMood.danger:
        // 귀 쫑긋 (shake horizontal)
        return child
            .animate(key: ValueKey(lastExpenseId))
            .scale(
              begin: const Offset(0.92, 0.92),
              duration: 350.ms,
              curve: Curves.elasticOut,
            )
            .then(delay: 0.ms)
            .shakeX(hz: 4, amount: 4, duration: 400.ms);
      case CharacterMood.over:
        // 발 동동 (rapid shake + shimmer)
        return child
            .animate(key: ValueKey(lastExpenseId))
            .scale(
              begin: const Offset(0.92, 0.92),
              duration: 350.ms,
              curve: Curves.elasticOut,
            )
            .then(delay: 0.ms)
            .shakeX(hz: 6, amount: 6, duration: 500.ms)
            .shimmer(
              color: Colors.red.withValues(alpha: 0.3),
              duration: 500.ms,
            );
    }
  }
}
