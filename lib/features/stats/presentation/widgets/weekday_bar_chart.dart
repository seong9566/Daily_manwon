import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/weekday_stat.dart';
import 'stats_bar_chart.dart';

/// 최근 4주 요일별 평균 지출 바 차트
/// [stats]: WeekdayStat 목록 (weekday: 0=일 … 6=토)
class WeekdayBarChart extends StatelessWidget {
  final int selectedMonth;
  final List<WeekdayStat> stats;
  final bool isDark;

  const WeekdayBarChart({
    super.key,
    required this.selectedMonth,
    required this.stats,
    required this.isDark,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final barDefault = isDark ? AppColors.darkDivider : AppColors.divider;
    final todayWeekday = DateTime.now().weekday % 7; // Dart Mon=1 → Sun=0

    final statMap = {for (final s in stats) s.weekday: s.avgAmount};
    final bars = List.generate(7, (i) {
      final isToday = i == todayWeekday;
      return StatsBarChartBar(
        value: (statMap[i] ?? 0).toDouble(),
        color: isToday ? AppColors.budgetWarning : barDefault,
        isHighlighted: isToday,
      );
    });

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
            '$selectedMonth월 요일별 평균 소비 패턴',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),
          if (stats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '아직 지출 데이터가 없어요',
                  style: AppTypography.bodySmall.copyWith(color: textSub),
                ),
              ),
            )
          else
            StatsBarChart(
              bars: bars,
              labels: _weekdayLabels,
              height: 100,
              isDark: isDark,
            ),
        ],
      ),
    );
  }
}
