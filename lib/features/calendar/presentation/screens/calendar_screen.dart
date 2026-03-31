import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/calendar_view_model.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/daily_expense_detail.dart';

/// 월간 캘린더 화면
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  void _onMonthChange(int delta) {
    ref.read(calendarViewModelProvider.notifier).changeMonth(delta);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textMainColor =
        isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Scaffold(
      backgroundColor: bgColor,
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

                      // ── 월 네비게이션 ────────────────────────────
                      _MonthNavigator(
                        selectedMonth: state.selectedMonth,
                        isDark: isDark,
                        textMainColor: textMainColor,
                        onPrev: () => _onMonthChange(-1),
                        onNext: () => _onMonthChange(1),
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

                      // ── 요일 헤더 — 고정 앵커 ────────────────────
                      _WeekdayHeader(isDark: isDark),
                      const SizedBox(height: 4),

                      // ── ±2달 프리렌더링 + 실시간 드래그 슬라이드 ─
                      // 손가락 움직임에 즉시 반응하고 뗄 때 스냅한다
                      _SlidingCalendarGrid(
                        state: state,
                        onMonthChange: _onMonthChange,
                        isDark: isDark,
                        onDateSelected: (date) => ref
                            .read(calendarViewModelProvider.notifier)
                            .selectDate(date),
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

// ── 실시간 드래그 슬라이드 위젯 ─────────────────────────────────
//
// ±2달 그리드를 미리 렌더링하고 손가락 위치를 실시간으로 추적한다.
// 각 달의 x 위치 = i * width + _dragOffset
// 어떤 t에서도 인접 달 간격이 정확히 1 width이므로 겹침이 없다.

class _SlidingCalendarGrid extends ConsumerStatefulWidget {
  final CalendarState state;
  final void Function(int delta) onMonthChange;
  final bool isDark;
  final void Function(DateTime) onDateSelected;

  const _SlidingCalendarGrid({
    required this.state,
    required this.onMonthChange,
    required this.isDark,
    required this.onDateSelected,
  });

  @override
  ConsumerState<_SlidingCalendarGrid> createState() =>
      _SlidingCalendarGridState();
}

class _SlidingCalendarGridState extends ConsumerState<_SlidingCalendarGrid>
    with SingleTickerProviderStateMixin {
  /// 드래그 / 스냅 오프셋 (픽셀 단위)
  double _dragOffset = 0.0;

  /// LayoutBuilder에서 측정된 가용 너비 — 드래그 핸들러에서 참조
  double _width = 300.0;

  // 스냅 애니메이션 파라미터
  double _snapStart = 0.0;
  double _snapEnd = 0.0;

  /// 스냅 완료 후 실행할 월 이동 방향 (0이면 스냅백)
  int _snapDelta = 0;

  /// 드래그 중일 때 true — 컨트롤러 리스너와 충돌 방지
  bool _isDragging = false;

  late final AnimationController _snapController;
  late final CurvedAnimation _snapCurved;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _snapCurved = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic,
    );
    _snapController.addListener(_onSnapTick);
    _snapController.addStatusListener(_onSnapStatus);
  }

  @override
  void didUpdateWidget(covariant _SlidingCalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // VM이 selectedMonth를 업데이트한 뒤 드래그 오프셋을 초기화한다.
    // 스냅 애니메이션 완료 → onMonthChange → VM 업데이트 → 여기서 리셋 순서로
    // 시각적 점프 없이 자연스럽게 전환된다.
    if (oldWidget.state.selectedMonth != widget.state.selectedMonth) {
      setState(() => _dragOffset = 0.0);
    }
  }

  @override
  void dispose() {
    _snapCurved.dispose();
    _snapController.dispose();
    super.dispose();
  }

  /// 스냅 애니메이션 틱 — 드래그 중이 아닐 때만 _dragOffset을 업데이트한다
  void _onSnapTick() {
    if (!_isDragging && mounted) {
      setState(() {
        // lerp: _snapStart → _snapEnd (곡선 적용)
        _dragOffset =
            _snapStart + (_snapEnd - _snapStart) * _snapCurved.value;
      });
    }
  }

  /// 스냅 완료 처리
  void _onSnapStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (_snapDelta != 0) {
      // 인접 달로 이동 — didUpdateWidget에서 _dragOffset을 리셋한다
      widget.onMonthChange(_snapDelta);
    } else {
      // 스냅백 (원위치) — VM 업데이트 없으므로 즉시 리셋
      if (mounted) setState(() => _dragOffset = 0.0);
    }
    _snapDelta = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _isDragging = true;
    _snapController.stop();
    _snapDelta = 0; // 진행 중이던 스냅 취소

    setState(() {
      // ±2달 경계(±2 * width)에서 추가 저항
      final maxOffset = _width * 2.1;
      _dragOffset =
          (_dragOffset + details.delta.dx).clamp(-maxOffset, maxOffset);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;

    _snapStart = _dragOffset;

    if (_dragOffset < -_width / 3 || velocity < -600) {
      _snapEnd = -_width;
      _snapDelta = 1; // 다음 달
    } else if (_dragOffset > _width / 3 || velocity > 600) {
      _snapEnd = _width;
      _snapDelta = -1; // 이전 달
    } else {
      _snapEnd = 0.0; // 스냅백
      _snapDelta = 0;
    }

    _snapController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(calendarViewModelProvider.notifier);
    final currentMonth = widget.state.selectedMonth;

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;

        // 셀 크기 계산 — _CalendarGrid의 패딩(12*2)과 childAspectRatio(0.85)에 맞춤
        final cellWidth = (_width - 24) / 7;
        final cellHeight = cellWidth / 0.85;
        final gridHeight = cellHeight * 6; // 6행 고정 (42칸)

        return GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          // 드래그 중 자식 위젯의 포인터 이벤트 차단
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: gridHeight,
            child: ClipRect(
              child: Stack(
                children: [
                  // ±2달 그리드를 나란히 배치하여 PageView 방식으로 슬라이드
                  for (int i = -2; i <= 2; i++)
                    Transform.translate(
                      offset: Offset(i * _width + _dragOffset, 0),
                      child: _CalendarGrid(
                        state: CalendarState(
                          selectedMonth: DateTime(
                            currentMonth.year,
                            currentMonth.month + i,
                          ),
                          // 현재 달만 선택 날짜 표시, 나머지는 생략
                          selectedDate: i == 0 ? widget.state.selectedDate : null,
                          monthlyExpenses: notifier.getCachedExpenses(
                            DateTime(currentMonth.year, currentMonth.month + i).year,
                            DateTime(currentMonth.year, currentMonth.month + i).month,
                          ),
                        ),
                        isDark: widget.isDark,
                        // 현재 달만 날짜 선택 활성화
                        onDateSelected:
                            i == 0 ? widget.onDateSelected : (_) {},
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
    final monthLabel =
        '${selectedMonth.year}. ${selectedMonth.month.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrev,
          tooltip: '이전 달',
          icon: Icon(Icons.chevron_left_rounded, color: textMainColor, size: 28),
        ),
        const SizedBox(width: 8),
        Text(
          monthLabel,
          style: AppTypography.titleMedium.copyWith(color: textMainColor),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onNext,
          tooltip: '다음 달',
          icon: Icon(Icons.chevron_right_rounded, color: textMainColor, size: 28),
        ),
      ],
    );
  }
}

// ── 요일 헤더 위젯 ───────────────────────────────────────────────

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

    final firstDayOfMonth = DateTime(year, month, 1);
    final startOffset = firstDayOfMonth.weekday % 7; // 일요일=0 기준
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 항상 42칸(6행) 고정 — _SlidingCalendarGrid의 SizedBox height와 일치
    const totalCells = 42;

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
          childAspectRatio: 0.85,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayNumber = index - startOffset + 1;
          final isCurrentMonth = dayNumber >= 1 && dayNumber <= daysInMonth;

          if (!isCurrentMonth) return const SizedBox.shrink();

          final cellDate = DateTime(year, month, dayNumber);
          final isToday = cellDate == today;
          final isFuture = cellDate.isAfter(today);
          final isSelected = state.selectedDate == cellDate;

          final expenses = state.monthlyExpenses[cellDate];
          bool? isSuccess;
          if (expenses != null && expenses.isNotEmpty) {
            final total = expenses.fold<int>(0, (sum, e) => sum + e.amount);
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
