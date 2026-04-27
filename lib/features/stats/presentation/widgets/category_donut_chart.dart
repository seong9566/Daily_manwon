import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category_stat.dart';

/// 월별 카테고리 지출 도넛 차트
/// [stats]: CategoryStat 목록 (비어 있으면 "지출 없음" 메시지 표시)
class CategoryDonutChart extends StatelessWidget {
  final List<CategoryStat> stats;
  final DateTime selectedMonth;
  final bool isDark;

  const CategoryDonutChart({
    super.key,
    required this.stats,
    required this.selectedMonth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final validStats = stats
        .where((s) =>
            s.categoryIndex >= 0 &&
            s.categoryIndex < ExpenseCategory.values.length)
        .toList();
    final totalAmount = validStats.fold(0, (s, c) => s + c.totalAmount);

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
            '카테고리별 소비',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          if (validStats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '이번 달 지출이 없어요',
                  style: AppTypography.bodySmall.copyWith(color: textSub),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: validStats.map((s) {
                            final category =
                                ExpenseCategory.values[s.categoryIndex];
                            return PieChartSectionData(
                              value: s.totalAmount.toDouble(),
                              color: category.color,
                              radius: 30,
                              showTitle: false,
                            );
                          }).toList(),
                          centerSpaceRadius: 38,
                          sectionsSpace: 2,
                        ),
                      ),
                      _CenterLabel(
                        selectedMonth: selectedMonth,
                        totalAmount: totalAmount,
                        textMain: textMain,
                        textSub: textSub,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: validStats.map((s) {
                      final category = ExpenseCategory.values[s.categoryIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                category.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(
                                  color: textMain,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(s.percentage * 100).toStringAsFixed(0)}%',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: textMain,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatWithWon(s.totalAmount),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: textSub,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Divider(color: divider, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            '캘린더 탭에서 월을 선택하면 해당 월 통계로 바뀌어요',
            style: AppTypography.bodySmall.copyWith(
              color: textSub,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// 도넛 차트 중앙 레이블 — 월 + 총 금액 표시
class _CenterLabel extends StatelessWidget {
  final DateTime selectedMonth;
  final int totalAmount;
  final Color textMain;
  final Color textSub;

  const _CenterLabel({
    required this.selectedMonth,
    required this.totalAmount,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${selectedMonth.month}월',
          style: AppTypography.bodySmall.copyWith(
            color: textMain,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        Text(
          CurrencyFormatter.format(totalAmount),
          style: AppTypography.bodySmall.copyWith(color: textSub, fontSize: 9),
        ),
      ],
    );
  }
}
