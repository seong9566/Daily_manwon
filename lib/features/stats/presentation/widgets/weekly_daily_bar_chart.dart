import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/daily_stat.dart';
import 'stats_bar_chart.dart';

/// 이번 주 일별 지출 바 차트 (일~토 7개 막대 + 예산선 점선)
/// [stats]: 항상 7개의 DailyStat (일~토 순서)
class WeeklyDailyBarChart extends StatelessWidget {
  final double dailyBudget;
  final List<DailyStat> stats;
  final bool isDark;

  const WeeklyDailyBarChart({
    super.key,
    required this.stats,
    required this.isDark,
    required this.dailyBudget,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
  static const _emptyBarMinHeight = 0.5;

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final barEmpty = isDark ? AppColors.darkDivider : AppColors.divider;

    final bars = List.generate(7, (i) {
      final amount = stats[i].amount.toDouble();
      final Color barColor;
      if (amount == 0) {
        barColor = barEmpty;
      } else if (amount <= dailyBudget) {
        barColor = AppColors.statusComfortableStrong;
      } else {
        barColor = AppColors.budgetDanger;
      }
      return StatsBarChartBar(value: amount, color: barColor);
    });

    final budgetLine = HorizontalLine(
      y: dailyBudget,
      color: AppColors.budgetWarning.withAlpha(180),
      strokeWidth: 1.5,
      dashArray: [4, 4],
      label: HorizontalLineLabel(
        show: true,
        alignment: Alignment.topRight,
        labelResolver: (_) => CurrencyFormatter.format(dailyBudget.toInt()),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.budgetWarning,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일별 지출',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          StatsBarChart(
            bars: bars,
            labels: _weekdayLabels,
            height: 110,
            isDark: isDark,
            horizontalLines: [budgetLine],
            minBarHeight: _emptyBarMinHeight,
          ),
        ],
      ),
    );
  }
}
