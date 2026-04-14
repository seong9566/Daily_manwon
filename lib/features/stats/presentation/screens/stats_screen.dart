import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../viewmodels/stats_view_model.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/stats_view_mode_toggle.dart';
import '../widgets/weekday_bar_chart.dart';
import '../widgets/weekly_daily_bar_chart.dart';
import '../widgets/weekly_insight_row.dart';
import '../widgets/weekly_stats_summary_row.dart';

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
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              '통계를 불러오지 못했습니다.',
              style: AppTypography.bodySmall.copyWith(color: textSub),
            ),
          ),
          data: (s) => RefreshIndicator(
            onRefresh: () =>
                ref.read(statsViewModelProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      // 날짜 네비게이터 + 모드 토글
                      _StatsNavRow(
                        viewMode: s.viewMode,
                        selectedMonth: s.selectedMonth,
                        selectedWeekStart: s.selectedWeekStart,
                        onPrevMonth: () => ref
                            .read(statsViewModelProvider.notifier)
                            .changeMonth(-1),
                        onNextMonth: () => ref
                            .read(statsViewModelProvider.notifier)
                            .changeMonth(1),
                        onPrevWeek: () => ref
                            .read(statsViewModelProvider.notifier)
                            .changeWeek(-1),
                        onNextWeek: () => ref
                            .read(statsViewModelProvider.notifier)
                            .changeWeek(1),
                        onToggleMode: () => ref
                            .read(statsViewModelProvider.notifier)
                            .toggleViewMode(),
                        isDark: isDark,
                        textMain: textMain,
                      ),
                      const SizedBox(height: 16),

                      if (s.viewMode == StatsViewMode.weekly) ...[
                        // 주간 콘텐츠
                        WeeklyDailyBarChart(
                          stats: s.dailyStats,
                          isDark: isDark,
                          dailyBudget: s.dailyBudget,
                        ),
                        const SizedBox(height: 12),
                        WeeklyStatsSummaryRow(
                          totalSpent: s.weeklyTotalSpent,
                          successDays: s.weeklySuccessDays,
                          totalDays: s.weeklyTotalDays,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        WeeklyInsightRow(
                          currentWeekTotalSpent: s.weeklyTotalSpent,
                          prevWeekTotalSpent: s.prevWeekTotalSpent,
                          topCategoryIndex: s.weeklyTopCategoryIndex,
                          isDark: isDark,
                          isFutureWeek: s.selectedWeekStart.isAfter(
                            DateTime.now(),
                          ),
                        ),
                      ] else ...[
                        // 월간 콘텐츠
                        CategoryDonutChart(
                          stats: s.categoryStats,
                          selectedMonth: s.selectedMonth,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        WeekdayBarChart(
                          selectedMonth: s.selectedMonth.month,
                          stats: s.weekdayStats,
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
                // 콘텐츠가 화면보다 짧을 때 나머지 영역을 채워 당김 새로고침 활성화
                const SliverFillRemaining(hasScrollBody: false),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 통계 화면 날짜 네비게이터 (월간/주간 모드 대응) + 모드 토글
///
/// 월간 모드: `< 4월 >` 형식으로 월 이동
/// 주간 모드: `< 4/6(일) ~ 4/12(토) >` 형식으로 주 이동
/// 우측에 [StatsViewModeToggle]이 배치된다.
class _StatsNavRow extends StatelessWidget {
  final StatsViewMode viewMode;
  final DateTime selectedMonth;
  final DateTime selectedWeekStart;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToggleMode;
  final bool isDark;
  final Color textMain;

  const _StatsNavRow({
    required this.viewMode,
    required this.selectedMonth,
    required this.selectedWeekStart,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onToggleMode,
    required this.isDark,
    required this.textMain,
  });

  String get _label {
    if (viewMode == StatsViewMode.weekly) {
      return AppDateUtils.statsWeekNavLabel(selectedWeekStart);
    }
    final now = DateTime.now();
    if (selectedMonth.year == now.year) {
      return '${selectedMonth.month}월';
    }
    return '${selectedMonth.year}년 ${selectedMonth.month}월';
  }

  @override
  Widget build(BuildContext context) {
    final onPrev = viewMode == StatsViewMode.weekly ? onPrevWeek : onPrevMonth;
    final onNext = viewMode == StatsViewMode.weekly ? onNextWeek : onNextMonth;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: Icon(Icons.chevron_left, color: textMain, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _label,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium.copyWith(color: textMain),
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: Icon(Icons.chevron_right, color: textMain, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),

        StatsViewModeToggle(
          viewMode: viewMode,
          isDark: isDark,
          onToggle: onToggleMode,
        ),
      ],
    );
  }
}
