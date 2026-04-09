import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'acorn_streak_badge.dart';
import 'hero_budget_number.dart';

/// 홈 화면 상단 예산 정보 섹션 (날짜 ~ 도토리/스트릭)
class HomeBudgetHeader extends StatelessWidget {
  final int remainingBudget;
  final int totalBudget;
  final int totalAcorns;
  final int streakDays;
  final bool isDark;
  final Color subTextColor;

  /// 마지막으로 추가된 지출 ID — 변경 시 고양이 마이크로 애니메이션 재트리거
  final int? lastExpenseId;

  const HomeBudgetHeader({
    super.key,
    required this.remainingBudget,
    required this.totalBudget,
    required this.totalAcorns,
    required this.streakDays,
    required this.isDark,
    required this.subTextColor,
    this.lastExpenseId,
  });

  @override
  Widget build(BuildContext context) {
    final mood = CharacterMood.fromRatio(
      totalBudget > 0 ? remainingBudget / totalBudget : 0.0,
    );

    return Column(
      children: [
        const SizedBox(height: 24),
        // 날짜 표시
        Text(
          DateFormat('yyyy. MM. dd').format(DateTime.now()),
          style: AppTypography.bodySmall.copyWith(color: subTextColor),
        ),
        const SizedBox(height: 8),
        // "오늘 남은 금액" 라벨
        Text(
          '오늘 남은 금액',
          style: AppTypography.bodySmall.copyWith(color: subTextColor),
        ),
        const SizedBox(height: 4),
        // [Idea 4] 소형 고양이 + 히어로 금액 Row
        HeroBudgetNumber(remainingBudget: remainingBudget),
        const SizedBox(height: 20),
        // [Idea 2+3] 고양이 마커 + 말풍선 통합 progress bar
        _CatProgressBar(
          remaining: remainingBudget,
          total: totalBudget,
          isDark: isDark,
          mood: mood,
          lastExpenseId: lastExpenseId,
        ),
        const SizedBox(height: 16),
        // 도토리 + 스트릭
        AcornStreakBadge(totalAcorns: totalAcorns, streakDays: streakDays),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// 고양이가 progress bar 위 마커로 표시되는 통합 위젯 (Idea 2+3)
class _CatProgressBar extends StatelessWidget {
  final int remaining;
  final int total;
  final bool isDark;
  final CharacterMood mood;
  final int? lastExpenseId;

  const _CatProgressBar({
    required this.remaining,
    required this.total,
    required this.isDark,
    required this.mood,
    this.lastExpenseId,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    Color barColor;
    if (remaining >= 5000) {
      barColor = isDark
          ? AppColors.budgetComfortableDark
          : AppColors.budgetComfortable;
    } else if (remaining >= 1000) {
      barColor = AppColors.budgetWarning;
    } else {
      barColor = AppColors.budgetDanger;
    }

    const double catSize = 88.0;
    const double bubbleHeight = 32.0;
    const double barHeight = 4.0;
    const double totalHeight = catSize + bubbleHeight + barHeight + 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: totalHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            // 고양이 중심 x 위치 (ratio 기반, 양끝 clamp)
            final catCenterX = (availableWidth * ratio).clamp(
              catSize / 2,
              availableWidth - catSize / 2,
            );
            final catLeft = catCenterX - catSize / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // 프로그레스 바 (최하단)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1.0, end: ratio),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: barHeight,
                          backgroundColor: isDark
                              ? AppColors.darkDivider
                              : AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        );
                      },
                    ),
                  ),
                ),
                // 말풍선 + 고양이 마커
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
                        // [Idea 3] 말풍선
                        _SpeechBubble(text: mood.comment, isDark: isDark),
                        const SizedBox(height: 2),
                        // [Idea 2] 고양이 마커 (다크모드: RGB 반전으로 흰 아웃라인 대응)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: ColorFiltered(
                            colorFilter: isDark
                                ? const ColorFilter.matrix([
                                    -1, 0, 0, 0, 255,
                                    0, -1, 0, 0, 255,
                                    0, 0, -1, 0, 255,
                                    0, 0, 0, 1, 0,
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

/// 고양이 말풍선 — mood 코멘트를 표시하는 소형 말풍선
class _SpeechBubble extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SpeechBubble({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.background;
    final textColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
