import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../expense/presentation/screens/expense_add_screen.dart';
import '../viewmodels/calendar_view_model.dart';
import '../widgets/daily_expense_detail.dart';
import '../widgets/sliding_calendar_grid.dart';
import '../widgets/sliding_weekly_grid.dart';
import '../widgets/monthly_nav_row.dart';
import '../widgets/view_mode_toggle.dart';
import '../widgets/weekday_header.dart';
import '../widgets/weekly_nav_row.dart';
import '../widgets/weekly_summary_header.dart';

/// 월간/주간 캘린더 화면
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  void _onMonthChange(int delta) {
    ref.read(calendarViewModelProvider.notifier).changeMonth(delta);
  }

  void _onWeekChange(int delta) {
    ref.read(calendarViewModelProvider.notifier).changeWeek(delta);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final summary =
        ref.read(calendarViewModelProvider.notifier).getWeeklySummary();

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_add_expense',
        backgroundColor:
            isDark ? AppColors.darkTextMain : AppColors.textMain,
        foregroundColor:
            isDark ? AppColors.darkBackground : AppColors.white,
        onPressed: () async {
          final date = state.selectedDate ?? DateTime.now();
          final saved = await showExpenseAddBottomSheet(context, date: date);
          if (saved == true && context.mounted) {
            ref
                .read(calendarViewModelProvider.notifier)
                .silentRefresh();
          }
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(calendarViewModelProvider.notifier)
                    .loadMonthData(forceRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 날짜 네비게이터 + 뷰 모드 토글
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: state.viewMode ==
                                        CalendarViewMode.monthly
                                    ? MonthlyNavRow(
                                        selectedMonth:
                                            state.selectedMonth,
                                        onPrev: () =>
                                            _onMonthChange(-1),
                                        onNext: () =>
                                            _onMonthChange(1),
                                        isDark: isDark,
                                      )
                                    : WeeklyNavRow(
                                        weekStart:
                                            state.selectedWeekStart,
                                        onPrev: () =>
                                            _onWeekChange(-1),
                                        onNext: () =>
                                            _onWeekChange(1),
                                        isDark: isDark,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ViewModeToggle(
                              mode: state.viewMode,
                              onChanged: (mode) {
                                if (mode != state.viewMode) {
                                  ref
                                      .read(calendarViewModelProvider
                                          .notifier)
                                      .toggleViewMode();
                                }
                              },
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 성공 통계 배지
                      Center(
                        child: Builder(
                          builder: (context) {
                            final isMonthly = state.viewMode ==
                                CalendarViewMode.monthly;
                            final successCount = isMonthly
                                ? state.monthlySuccessCount
                                : summary.savingDays;
                            return _SuccessBadge(
                              successCount: successCount,
                              label: isMonthly ? '이번 달 성공' : '이번 주 성공',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 요일 헤더
                      WeekdayHeader(isDark: isDark),
                      const SizedBox(height: 4),

                      // 캘린더 그리드
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        firstCurve: Curves.easeOut,
                        secondCurve: Curves.easeOut,
                        sizeCurve: Curves.easeInOut,
                        crossFadeState: state.viewMode ==
                                CalendarViewMode.monthly
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: SlidingCalendarGrid(
                          state: state,
                          onMonthChange: _onMonthChange,
                          isDark: isDark,
                          onDateSelected: (date) => ref
                              .read(
                                  calendarViewModelProvider.notifier)
                              .selectDate(date),
                        ),
                        secondChild: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SlidingWeeklyGrid(
                              onWeekChange: _onWeekChange,
                              onDateSelected: (date) => ref
                                  .read(calendarViewModelProvider
                                      .notifier)
                                  .selectDate(date),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: WeeklySummaryHeader(
                                totalSpent: summary.totalSpent,
                                dailyAverage: summary.dailyAverage,
                                savingDays: summary.savingDays,
                                totalDays: summary.totalDays,
                                weeklyBudget: summary.weeklyBudget,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 날짜 지출 내역 — 항상 표시, 날짜 미선택 시 오늘 기준
                      Builder(builder: (context) {
                        final now = DateTime.now();
                        final date = state.selectedDate ??
                            DateTime(now.year, now.month, now.day);
                        return DailyExpenseDetail(
                          date: date,
                          expenses: state.monthlyExpenses[date] ?? const [],
                          onExpenseTap: (item) {
                            showExpenseAddBottomSheet(
                              context,
                              expense: item.toExpenseEntity(),
                            ).then((saved) {
                              if (saved == true && context.mounted) {
                                ref
                                    .read(calendarViewModelProvider.notifier)
                                    .silentRefresh();
                              }
                            });
                          },
                          baseAmount: state.monthlyBaseAmounts[date],
                          effectiveBudget: state.monthlyEffectiveBudgets[date],
                        );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  final int successCount;
  final String label;

  const _SuccessBadge({required this.successCount, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.background;
    final mainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final subColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Semantics(
      label: '$label $successCount일',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$successCount일',
              style: AppTypography.bodyMedium.copyWith(
                color: mainColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: subColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
