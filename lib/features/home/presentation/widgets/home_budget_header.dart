import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'acorn_streak_badge.dart';
import 'hero_budget_number.dart';

/// 홈 화면 상단 예산 정보 섹션 (날짜 ~ 도토리/스트릭)
class HomeBudgetHeader extends StatelessWidget {
  final int remainingBudget;
  final int totalBudget;
  final int carryOver;
  final int totalAcorns;
  final int streakDays;
  final bool isDark;
  final Color subTextColor;

  const HomeBudgetHeader({
    super.key,
    required this.remainingBudget,
    required this.totalBudget,
    required this.carryOver,
    required this.totalAcorns,
    required this.streakDays,
    required this.isDark,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
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
        // 히어로 금액 (디자인 가이드 Section 1)
        HeroBudgetNumber(remainingBudget: remainingBudget),
        // 이월 금액 표시 (디자인 가이드 Section 1.5)
        if (carryOver > 0)
          Text(
            '+ 어제 이월 ₩${NumberFormat('#,###').format(carryOver)}',
            style: AppTypography.bodySmall.copyWith(color: subTextColor),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms)
              .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut),
        const SizedBox(height: 16),
        // 프로그레스 바
        _BudgetProgressBar(
          remaining: remainingBudget,
          total: totalBudget,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        // 도토리 + 스트릭
        AcornStreakBadge(
          totalAcorns: totalAcorns,
          streakDays: streakDays,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

/// 예산 소비 현황 프로그레스 바
class _BudgetProgressBar extends StatelessWidget {
  final int remaining;
  final int total;
  final bool isDark;

  const _BudgetProgressBar({
    required this.remaining,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    Color barColor;
    if (remaining >= 5000) {
      barColor = AppColors.budgetComfortable;
    } else if (remaining >= 1000) {
      barColor = AppColors.budgetWarning;
    } else {
      barColor = AppColors.budgetDanger;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: TweenAnimationBuilder<double>(
          // 시작값을 1.0(100%)으로 두어, 항상 가득 찬 상태에서 현재 잔액 퍼센트(ratio)까지
          // 자연스럽게 깎이며(우측에서 좌측으로) 줄어드는 느낌의 애니메이션이 적용됩니다.
          tween: Tween<double>(begin: 1.0, end: ratio),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkDivider : AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            );
          },
        ),
      ),
    );
  }
}
