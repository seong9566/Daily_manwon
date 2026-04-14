import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 통계 화면 공용 바 차트
///
/// [bars] 길이와 [labels] 길이는 반드시 일치해야 한다.
/// 툴팁은 값이 0이거나 [minBarHeight] 이하인 막대에는 표시되지 않는다.
class StatsBarChart extends StatelessWidget {
  /// 막대 데이터 목록
  final List<StatsBarChartBar> bars;

  /// x축 레이블 (bars와 동일한 길이)
  final List<String> labels;

  /// 차트 영역 높이
  final double height;

  final bool isDark;

  /// 수평 기준선 목록 (예산선 등), 기본 없음
  final List<HorizontalLine> horizontalLines;

  /// 값이 0인 막대의 최소 표시 높이 (0이면 적용 안 함)
  final double minBarHeight;

  /// 막대 너비
  final double barWidth;

  const StatsBarChart({
    super.key,
    required this.bars,
    required this.labels,
    required this.isDark,
    this.height = 110,
    this.horizontalLines = const [],
    this.minBarHeight = 0,
    this.barWidth = 24,
  });

  @override
  Widget build(BuildContext context) {
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final tooltipBg = isDark ? AppColors.white : AppColors.textMain;
    final tooltipText = isDark ? AppColors.textMain : AppColors.white;

    final maxValue = bars.fold(0.0, (max, b) => b.value > max ? b.value : max);
    final maxLineY = horizontalLines.fold(
      0.0,
      (max, l) => l.y > max ? l.y : max,
    );
    final effectiveMax = maxValue > maxLineY ? maxValue : maxLineY;
    final chartMax = effectiveMax > 0 ? effectiveMax * 1.3 : 10.0;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          barGroups: List.generate(bars.length, (i) {
            final bar = bars[i];
            final displayY = (bar.value == 0 && minBarHeight > 0)
                ? minBarHeight
                : bar.value;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: displayY,
                  color: bar.color,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => tooltipBg,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final amount = bars[group.x].value.toInt();
                if (amount <= 0) return null;
                return BarTooltipItem(
                  CurrencyFormatter.format(amount),
                  AppTypography.bodySmall.copyWith(
                    color: tooltipText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          extraLinesData: horizontalLines.isEmpty
              ? const ExtraLinesData()
              : ExtraLinesData(horizontalLines: horizontalLines),
          titlesData: FlTitlesData(
            // 요일
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  final bar = bars[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[idx],
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: bar.isHighlighted
                            ? AppColors.budgetWarning
                            : textSub,
                        fontWeight: bar.isHighlighted
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
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
    );
  }
}

/// [StatsBarChart] 단일 막대 데이터
class StatsBarChartBar {
  /// 실제 금액 — 툴팁과 높이 계산 기준
  final double value;

  /// 막대 색상
  final Color color;

  /// true이면 레이블을 강조 색상(budgetWarning)·굵게 표시
  final bool isHighlighted;

  const StatsBarChartBar({
    required this.value,
    required this.color,
    this.isHighlighted = false,
  });
}
