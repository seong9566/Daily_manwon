import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/budget_progress_bar.dart';
import 'hero_budget_number.dart';

/// 홈 화면 상단 예산 정보 섹션 (날짜 ~ 프로그레스 바)
class HomeBudgetHeader extends StatelessWidget {
  final int remainingBudget;
  final int totalBudget;
  final bool isDark;
  final Color subTextColor;

  const HomeBudgetHeader({
    super.key,
    required this.remainingBudget,
    required this.totalBudget,
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
        // 히어로 금액
        HeroBudgetNumber(remainingBudget: remainingBudget),
        const SizedBox(height: 20),
        // 고양이 마커 + 말풍선 통합 progress bar
        BudgetProgressBar(
          remaining: remainingBudget,
          total: totalBudget,
          isDark: isDark,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
