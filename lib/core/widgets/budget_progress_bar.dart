import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 예산 잔액 진행 바 — 홈/주간/월간 공용
///
/// [remaining] / [total] 비율로 고양이 마커 위치와 색상을 결정한다.
/// - ratio > 0.7 (여유): 고양이 이미지 여유_clean, 바 색상 budgetComfortable
/// - ratio > 0.3 (보통): 보통_clean, budgetWarning
/// - ratio >= 0.0 (위험): 위험_clean, budgetDanger
/// - ratio < 0.0 (초과): 초과_clean, budgetOver
class BudgetProgressBar extends StatelessWidget {
  /// 남은 예산 (음수 = 초과)
  final int remaining;

  /// 총 예산 (0이면 danger 처리)
  final int total;

  final bool isDark;

  const BudgetProgressBar({
    super.key,
    required this.remaining,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // ratio: mood 계산에는 원시값(음수 허용), bar fill에는 clamp(0,1)
    final ratio = total > 0 ? remaining / total : 0.0;
    final mood = CharacterMood.fromRatio(ratio);
    final barRatio = ratio.clamp(0.0, 1.0);

    final Color barColor = switch (mood) {
      CharacterMood.comfortable || CharacterMood.newWeek =>
        isDark ? AppColors.budgetComfortableDark : AppColors.budgetComfortable,
      CharacterMood.normal => AppColors.budgetWarning,
      CharacterMood.danger => AppColors.budgetDanger,
      CharacterMood.over   => AppColors.budgetOver,
    };

    const double catSize      = 88.0;
    const double bubbleHeight = 32.0;
    const double barHeight    = 4.0;
    const double totalHeight  = catSize + bubbleHeight + barHeight + 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: totalHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final catCenterX = (availableWidth * barRatio).clamp(
              catSize / 2,
              availableWidth - catSize / 2,
            );
            final catLeft = catCenterX - catSize / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── 프로그레스 바 (최하단) ──────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1.0, end: barRatio),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: barHeight,
                          backgroundColor:
                              isDark ? AppColors.darkDivider : AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        );
                      },
                    ),
                  ),
                ),

                // ── 말풍선 + 고양이 마커 ────────────────────────────
                Positioned(
                  left: catLeft,
                  bottom: barHeight + 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    width: catSize,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SpeechBubble(text: mood.comment, isDark: isDark),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: ColorFiltered(
                            colorFilter: isDark
                                ? const ColorFilter.matrix([
                                    -1, 0, 0, 0, 255,
                                     0,-1, 0, 0, 255,
                                     0, 0,-1, 0, 255,
                                     0, 0, 0, 1,   0,
                                  ])
                                : const ColorFilter.matrix([
                                    1, 0, 0, 0, 0,
                                    0, 1, 0, 0, 0,
                                    0, 0, 1, 0, 0,
                                    0, 0, 0, 1, 0,
                                  ]),
                            child: Image.asset(
                              mood.assetPath,
                              key: ValueKey(mood),
                              width: catSize,
                              height: catSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 고양이 말풍선 — mood 코멘트 표시용 소형 말풍선
class _SpeechBubble extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SpeechBubble({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor   = isDark ? AppColors.darkSurface  : AppColors.background;
    final textColor = isDark ? AppColors.darkTextSub  : AppColors.textSub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
