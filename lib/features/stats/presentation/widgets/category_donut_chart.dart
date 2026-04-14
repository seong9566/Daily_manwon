import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category_stat.dart';

/// 월별 카테고리 지출 도넛 차트
/// [stats]: CategoryStat 목록 (비어 있으면 "지출 없음" 메시지 표시)
class CategoryDonutChart extends StatefulWidget {
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
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  void didUpdateWidget(CategoryDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 월이 바뀌면 선택 초기화
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _touchedIndex = -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final stats = widget.stats;
    final selectedMonth = widget.selectedMonth;

    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final totalAmount = stats.fold(0, (s, c) => s + c.totalAmount);

    final touched = (_touchedIndex >= 0 && _touchedIndex < stats.length)
        ? stats[_touchedIndex]
        : null;

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
          if (stats.isEmpty)
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
                // 도넛 차트
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    response?.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = response!
                                    .touchedSection!
                                    .touchedSectionIndex;
                              });
                            },
                          ),
                          sections: List.generate(stats.length, (i) {
                            final isTouched = i == _touchedIndex;
                            final category =
                                ExpenseCategory.values[stats[i].categoryIndex];
                            return PieChartSectionData(
                              value: stats[i].totalAmount.toDouble(),
                              color: category.color,
                              radius: isTouched ? 38 : 30,
                              showTitle: false,
                            );
                          }),
                          centerSpaceRadius: 38,
                          sectionsSpace: 2,
                        ),
                      ),
                      // 중앙 레이블 — 터치 시 해당 카테고리 금액 표시
                      _CenterLabel(
                        touched: touched,
                        selectedMonth: selectedMonth,
                        totalAmount: totalAmount,
                        textMain: textMain,
                        textSub: textSub,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: stats.map((s) {
                      final category = ExpenseCategory.values[s.categoryIndex];
                      final isSelected = stats.indexOf(s) == _touchedIndex;
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
                            Text(
                              category.label,
                              style: AppTypography.bodySmall.copyWith(
                                color: isSelected ? category.color : textMain,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(s.percentage * 100).toStringAsFixed(0)}%',
                              style: AppTypography.bodySmall.copyWith(
                                color: isSelected ? category.color : textMain,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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

/// 도넛 차트 중앙 레이블
/// 기본: 월 + 총 금액 / 터치 시: 카테고리명 + 해당 금액
class _CenterLabel extends StatelessWidget {
  final CategoryStat? touched;
  final DateTime selectedMonth;
  final int totalAmount;
  final Color textMain;
  final Color textSub;

  const _CenterLabel({
    required this.touched,
    required this.selectedMonth,
    required this.totalAmount,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    if (touched != null) {
      final category = ExpenseCategory.values[touched!.categoryIndex];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.label,
            style: TextStyle(
              color: category.color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            CurrencyFormatter.format(touched!.totalAmount),
            style: TextStyle(color: textSub, fontSize: 9),
          ),
        ],
      );
    }

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
