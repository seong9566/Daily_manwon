import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/stats_view_model.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/expense_summary_sheet.dart';
import '../widgets/weekday_bar_chart.dart';

/// 통계 화면 — 바텀 네비게이션 독립 탭
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Scaffold(
      backgroundColor: bgColor,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Text(
                    state.errorMessage!,
                    style: AppTypography.bodySmall.copyWith(color: textSub),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(statsViewModelProvider.notifier).loadStats(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 월 선택기
                        _MonthNavRow(
                          selectedMonth: state.selectedMonth,
                          onPrev: () => ref
                              .read(statsViewModelProvider.notifier)
                              .changeMonth(-1),
                          onNext: () => ref
                              .read(statsViewModelProvider.notifier)
                              .changeMonth(1),
                          isDark: isDark,
                          textMain: textMain,
                        ),
                        const SizedBox(height: 16),

                        // 카테고리 도넛 차트
                        CategoryDonutChart(
                          stats: state.categoryStats,
                          selectedMonth: state.selectedMonth,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),

                        // 요일별 바 차트
                        WeekdayBarChart(
                          stats: state.weekdayStats,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),

                        // 요약 보기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                showExpenseSummarySheet(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textMain,
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.darkDivider
                                    : AppColors.divider,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              '주간 / 월간 요약 보기',
                              style: AppTypography.labelMedium.copyWith(
                                color: textMain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// 통계 화면 전용 월 선택기
class _MonthNavRow extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;
  final Color textMain;

  const _MonthNavRow({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
    required this.textMain,
  });

  String get _label {
    final now = DateTime.now();
    if (selectedMonth.year == now.year) {
      return '${selectedMonth.month}월';
    }
    return '${selectedMonth.year}년 ${selectedMonth.month}월';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: Icon(Icons.chevron_left, color: textMain, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Text(
          _label,
          style: AppTypography.titleMedium.copyWith(color: textMain),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.chevron_right, color: textMain, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }
}
