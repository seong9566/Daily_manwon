import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/calendar_view_model.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/daily_expense_detail.dart';

/// 월간 캘린더 화면
/// 월 네비게이션, 날짜 그리드, 선택일 지출 내역을 표시한다
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final vm = ref.read(calendarViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.background;
    final textMainColor =
        isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: vm.loadMonthData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── 월 네비게이션 ────────────────────────────
                      _MonthNavigator(
                        selectedMonth: state.selectedMonth,
                        isDark: isDark,
                        textMainColor: textMainColor,
                        onPrev: () => vm.changeMonth(-1),
                        onNext: () => vm.changeMonth(1),
                      ),
                      const SizedBox(height: 8),

                      // ── 연속일 · 성공 횟수 통계 ──────────────────
                      Center(
                        child: Text(
                          '연속 ${state.streakDays}일 · 성공 ${state.successCount}회',
                          style: AppTypography.bodySmall.copyWith(
                            color: textSubColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── 요일 헤더 ────────────────────────────────
                      _WeekdayHeader(isDark: isDark),
                      const SizedBox(height: 4),

                      // ── 날짜 그리드 ──────────────────────────────
                      _CalendarGrid(
                        state: state,
                        isDark: isDark,
                        onDateSelected: vm.selectDate,
                      ),
                      const SizedBox(height: 8),

                      // ── 선택된 날짜 지출 내역 ────────────────────
                      if (state.selectedDate != null)
                        DailyExpenseDetail(
                          date: state.selectedDate!,
                          expenses: state.selectedDateExpenses,
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ── 월 네비게이션 위젯 ───────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final bool isDark;
  final Color textMainColor;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.selectedMonth,
    required this.isDark,
    required this.textMainColor,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // "2026. 03" 형식 — 월은 2자리 패딩
    final monthLabel =
        '${selectedMonth.year}. ${selectedMonth.month.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 이전 달 버튼
        IconButton(
          onPressed: onPrev,
          icon: Icon(
            Icons.chevron_left_rounded,
            color: textMainColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          monthLabel,
          style: AppTypography.titleMedium.copyWith(color: textMainColor),
        ),
        const SizedBox(width: 8),
        // 다음 달 버튼
        IconButton(
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: textMainColor,
            size: 28,
          ),
        ),
      ],
    );
  }
}

// ── 요일 헤더 위젯 ───────────────────────────────────────────────

class _WeekdayHeader extends StatelessWidget {
  final bool isDark;

  const _WeekdayHeader({required this.isDark});

  // 일~토 순서 — DateTime.weekday: 월=1, 일=7
  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final textSubColor =
        isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _weekdays.map((day) {
          // 일요일은 빨강, 토요일은 파랑 강조
          final isWeekend =
              day == '일' || day == '토';
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
    );
  }
}

// ── 날짜 그리드 위젯 ─────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final CalendarState state;
  final bool isDark;
  final void Function(DateTime) onDateSelected;

  const _CalendarGrid({
    required this.state,
    required this.isDark,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final year = state.selectedMonth.year;
    final month = state.selectedMonth.month;

    // 해당 월의 1일 요일 (0=일, 1=월, ... 6=토)
    // DateTime.weekday: 월=1 ... 일=7 → 일요일 시작 그리드에 맞게 변환
    final firstDayOfMonth = DateTime(year, month, 1);
    // weekday를 일요일=0 기준으로 변환
    final startOffset = firstDayOfMonth.weekday % 7;

    // 해당 월의 마지막 날
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 그리드 총 셀 수 = offset + 일수, 7의 배수로 올림
    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          // 셀 높이를 너비보다 약간 크게 — dot 공간 확보
          childAspectRatio: 0.85,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          // 날짜 계산: offset 이전과 월 마지막 이후는 빈 셀
          final dayNumber = index - startOffset + 1;
          final isCurrentMonth =
              dayNumber >= 1 && dayNumber <= daysInMonth;

          if (!isCurrentMonth) {
            // 다른 달 날짜 — 빈 셀로 처리
            return const SizedBox.shrink();
          }

          final cellDate = DateTime(year, month, dayNumber);
          final isToday = cellDate == today;
          final isFuture = cellDate.isAfter(today);
          final isSelected = state.selectedDate == cellDate;

          // 해당일 지출 존재 시 성공/실패 판별
          final expenses = state.monthlyExpenses[cellDate];
          bool? isSuccess;
          if (expenses != null && expenses.isNotEmpty) {
            final total =
                expenses.fold<int>(0, (sum, e) => sum + e.amount);
            isSuccess = total <= AppConstants.dailyBudget;
          }

          return CalendarDayCell(
            date: cellDate,
            isToday: isToday,
            isSelected: isSelected,
            isCurrentMonth: isCurrentMonth,
            isFuture: isFuture,
            isSuccess: isSuccess,
            onTap: () => onDateSelected(cellDate),
          );
        },
      ),
    );
  }
}
