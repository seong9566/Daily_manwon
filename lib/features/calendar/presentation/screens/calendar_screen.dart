import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../expense/presentation/screens/expense_add_screen.dart';
import '../../../stats/presentation/screens/stats_screen.dart';
import '../../../../core/widgets/acorn_streak_badge.dart';
import '../viewmodels/calendar_view_model.dart';
import '../widgets/daily_expense_detail.dart';
import '../widgets/sliding_calendar_grid.dart';
import '../widgets/sliding_weekly_grid.dart';
import '../widgets/view_mode_toggle.dart';
import '../widgets/weekly_summary_header.dart';

/// 월간/주간 캘린더 화면 (캘린더 탭 + 통계 탭)
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final summary =
        ref.read(calendarViewModelProvider.notifier).getWeeklySummary();

    final isCalendarTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: isCalendarTab
          ? FloatingActionButton(
              heroTag: 'calendar_add_expense',
              backgroundColor:
                  isDark ? AppColors.darkTextMain : AppColors.textMain,
              foregroundColor:
                  isDark ? AppColors.darkBackground : AppColors.white,
              onPressed: () async {
                final date = state.selectedDate ?? DateTime.now();
                await showExpenseAddBottomSheet(context, date: date);
              },
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ── 탭 바 ──────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              labelStyle: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              unselectedLabelStyle: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              labelColor: textMain,
              unselectedLabelColor:
                  isDark ? AppColors.darkTextSub : AppColors.textSub,
              indicatorColor: textMain,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: '캘린더'),
                Tab(text: '통계'),
              ],
            ),

            // ── 탭 콘텐츠 ──────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── 탭 0: 캘린더 ──────────────────────────────────
                  state.isLoading
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
                                              ? _MonthlyNavRow(
                                                  selectedMonth:
                                                      state.selectedMonth,
                                                  onPrev: () =>
                                                      _onMonthChange(-1),
                                                  onNext: () =>
                                                      _onMonthChange(1),
                                                  isDark: isDark,
                                                )
                                              : _WeeklyNavRow(
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
                                    builder: (_) {
                                      final isMonthly = state.viewMode ==
                                          CalendarViewMode.monthly;
                                      final successCount = isMonthly
                                          ? state.monthlySuccessCount
                                          : summary.savingDays;
                                      return AcornStreakBadge(
                                        totalAcorns: successCount,
                                        streakDays: state.streakDays,
                                        rewardLabel: isMonthly
                                            ? '이번달 절약 성공'
                                            : '이번주 성공',
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 요일 헤더
                                _WeekdayHeader(isDark: isDark),
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

                                // 선택된 날짜 지출 내역
                                if (state.selectedDate != null)
                                  DailyExpenseDetail(
                                    date: state.selectedDate!,
                                    expenses: ref
                                        .read(calendarViewModelProvider.notifier)
                                        .getExpensesForDate(state.selectedDate),
                                    onExpenseTap: (expense) {
                                      showExpenseAddBottomSheet(
                                        context,
                                        expense: expense,
                                      );
                                    },
                                  ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                  // ── 탭 1: 통계 ────────────────────────────────────
                  const StatsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 월간 네비게이터 ──────────────────────────────────────────────────

class _MonthlyNavRow extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;

  const _MonthlyNavRow({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
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
    final textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPrev,
            icon: Icon(Icons.chevron_left, color: textColor, size: 24),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _label,
              style: AppTypography.titleMedium.copyWith(color: textColor),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: textColor, size: 24),
          ),
        ),
      ],
    );
  }
}

// ── 주간 네비게이터 ──────────────────────────────────────────────────

class _WeeklyNavRow extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;

  const _WeeklyNavRow({
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPrev,
            icon: Icon(Icons.chevron_left, color: textColor, size: 24),
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppDateUtils.weekRangeLabel(weekStart),
              style: AppTypography.titleMedium.copyWith(color: textColor),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onNext,
            icon: Icon(Icons.chevron_right, color: textColor, size: 24),
          ),
        ),
      ],
    );
  }
}

// ── 요일 헤더 위젯 ───────────────────────────────────────────────────

class _WeekdayHeader extends StatelessWidget {
  final bool isDark;

  const _WeekdayHeader({required this.isDark});

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _weekdays.map((day) {
            final isWeekend = day == '일' || day == '토';
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: AppTypography.bodySmall.copyWith(
                    color: isWeekend
                        ? (day == '일'
                              ? AppColors.statusDanger.withAlpha(200)
                              : AppColors.categoryTransport.withAlpha(200))
                        : textSubColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
