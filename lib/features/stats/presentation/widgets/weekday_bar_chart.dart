import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/weekday_stat.dart';

/// 최근 4주 요일별 평균 지출 바 차트
/// [stats]: WeekdayStat 목록 (weekday: 0=일 … 6=토)
class WeekdayBarChart extends StatelessWidget {
  final List<WeekdayStat> stats;
  final bool isDark;

  const WeekdayBarChart({
    super.key,
    required this.stats,
    required this.isDark,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  String _insightMessage(List<WeekdayStat> sorted) {
    if (sorted.isEmpty) return '';
    final top = sorted.take(2).map((s) => _weekdayLabels[s.weekday]).toList();
    if (top.length == 1) {
      return '${top[0]}요일에 지출이 가장 많아요';
    }
    return '${top[0]}·${top[1]}요일에 지출이 집중되는 편이에요';
  }

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final barDefault = isDark ? AppColors.darkDivider : AppColors.divider;
    final todayWeekday = DateTime.now().weekday % 7; // Dart Mon=1 → Sun=0

    final statMap = {for (final s in stats) s.weekday: s.avgAmount};
    final amounts = List.generate(7, (i) => statMap[i] ?? 0);
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

    final sortedByAmount = stats.toList()
      ..sort((a, b) => b.avgAmount.compareTo(a.avgAmount));
    final insightMsg = _insightMessage(sortedByAmount);

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
            '요일별 소비 패턴',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '최근 4주 일평균 기준',
            style: AppTypography.bodySmall.copyWith(color: textSub, fontSize: 11),
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
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  maxY: maxAmount > 0 ? maxAmount * 1.3 : 10,
                  barGroups: List.generate(7, (i) {
                    final isToday = i == todayWeekday;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: amounts[i].toDouble(),
                          color: isToday ? AppColors.budgetWarning : barDefault,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          final isToday = idx == todayWeekday;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _weekdayLabels[idx],
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: isToday
                                    ? AppColors.budgetWarning
                                    : textSub,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          if (insightMsg.isNotEmpty) ...[
            Divider(color: dividerColor, height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.budgetWarning.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      insightMsg,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.budgetWarning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
