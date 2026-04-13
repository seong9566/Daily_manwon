import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../viewmodels/calendar_view_model.dart';
import 'weekly_calendar_day_cell.dart';

/// 주간 캘린더 슬라이딩 그리드
///
/// - 3주분(이전/현재/다음) 가로 배치
/// - GestureDetector + AnimationController 드래그/스냅 (280ms easeOutCubic)
/// - 좌우 스와이프로 이전/다음 주 이동
/// - 각 주를 Row(7개 WeeklyCalendarDayCell)로 렌더링
class SlidingWeeklyGrid extends ConsumerStatefulWidget {
  final void Function(int delta) onWeekChange;
  final void Function(DateTime) onDateSelected;
  final bool isDark;

  const SlidingWeeklyGrid({
    super.key,
    required this.onWeekChange,
    required this.onDateSelected,
    required this.isDark,
  });

  @override
  ConsumerState<SlidingWeeklyGrid> createState() => _SlidingWeeklyGridState();
}

class _SlidingWeeklyGridState extends ConsumerState<SlidingWeeklyGrid>
    with SingleTickerProviderStateMixin {
  /// 드래그 / 스냅 오프셋 (픽셀 단위)
  double _dragOffset = 0.0;

  /// LayoutBuilder에서 측정된 가용 너비
  double _width = 300.0;

  double _snapStart = 0.0;
  double _snapEnd = 0.0;

  /// 스냅 완료 후 실행할 주 이동 방향 (0이면 스냅백)
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
  void dispose() {
    _snapCurved.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _onSnapTick() {
    if (!_isDragging && mounted) {
      setState(() {
        _dragOffset = _snapStart + (_snapEnd - _snapStart) * _snapCurved.value;
      });
    }
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_snapDelta != 0) {
      // 주 이동 — selectedWeekStart 업데이트 후 ref.listen이 _dragOffset 리셋
      widget.onWeekChange(_snapDelta);
    } else {
      // 스냅백 — 즉시 리셋
      if (mounted) setState(() => _dragOffset = 0.0);
    }
    _snapDelta = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _isDragging = true;
    _snapController.stop();
    _snapDelta = 0;
    setState(() {
      final maxOffset = _width * 2.1;
      _dragOffset = (_dragOffset + details.delta.dx).clamp(
        -maxOffset,
        maxOffset,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    _snapStart = _dragOffset;

    if (_dragOffset < -_width / 3 || velocity < -600) {
      _snapEnd = -_width;
      _snapDelta = 1; // 다음 주
    } else if (_dragOffset > _width / 3 || velocity > 600) {
      _snapEnd = _width;
      _snapDelta = -1; // 이전 주
    } else {
      _snapEnd = 0.0;
      _snapDelta = 0;
    }

    _snapController.forward(from: 0.0);
  }

  /// 특정 주의 7일 셀 Row를 빌드한다.
  /// getCachedExpenses를 사용하여 월 경계 주도 올바르게 처리한다.
  Widget _buildWeekRow(DateTime weekStart, CalendarState state) {
    final notifier = ref.read(calendarViewModelProvider.notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = AppDateUtils.weekDaysFrom(weekStart);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: days.map((day) {
          final isToday = day == today;
          final isFuture = day.isAfter(today);
          final isSelected = state.selectedDate == day;

          // 월 경계 주를 위해 해당 날짜 소속 월의 캐시에서 지출 조회
          final monthExpenses = notifier.getCachedExpenses(day.year, day.month);
          final dayExpenses = monthExpenses[day];

          final monthEffectiveBudgets =
              notifier.getCachedEffectiveBudgets(day.year, day.month);
          final monthBaseAmounts =
              notifier.getCachedBaseAmounts(day.year, day.month);
          final dayBudget = monthEffectiveBudgets[day]
              ?? monthBaseAmounts[day]
              ?? AppConstants.dailyBudget;

          // 지출 합계 → mood 계산 (금액 뱃지 표시용)
          // 월간 그리드와 동일한 규칙:
          //   - 지출 있음       → 실제 합계로 mood 결정
          //   - 지출 없는 과거  → totalSpent = null → 뱃지 미표시
          int? totalSpent;
          if (!isFuture) {
            if (dayExpenses != null && dayExpenses.isNotEmpty) {
              totalSpent = dayExpenses.fold<int>(0, (s, e) => s + e.amount);
            }
            // 지출 없는 과거 날짜: totalSpent = null → 뱃지 미표시
          }

          final CharacterMood? mood =
              (!isFuture && totalSpent != null)
                  ? CharacterMood.fromSpent(dayBudget, totalSpent)
                  : null;

          return Expanded(
            child: Center(
              child: WeeklyCalendarDayCell(
                date: day,
                isToday: isToday,
                isSelected: isSelected,
                isFuture: isFuture,
                onTap: () => widget.onDateSelected(day),
                mood: mood,
                totalSpent: totalSpent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarViewModelProvider);
    final currentWeekStart = state.selectedWeekStart;

    // selectedWeekStart 변경 시 드래그 오프셋 초기화
    ref.listen<DateTime>(
      calendarViewModelProvider.select((s) => s.selectedWeekStart),
      (prev, next) {
        if (!_isDragging && mounted) {
          setState(() => _dragOffset = 0.0);
        }
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        // 월간 셀 높이(cellWidth/0.90)와 시각적으로 통일
        // 390px 기준 ≈ 58px → 60px로 정렬
        const rowHeight = 60.0;

        return GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: rowHeight,
            child: ClipRect(
              child: Stack(
                children: [
                  for (int i = -1; i <= 1; i++)
                    Transform.translate(
                      key: ValueKey(
                        '${currentWeekStart.year}-'
                        '${currentWeekStart.month}-'
                        '${currentWeekStart.day}-$i',
                      ),
                      offset: Offset(i * _width + _dragOffset, 0),
                      child: SizedBox(
                        width: _width,
                        height: rowHeight,
                        child: _buildWeekRow(
                          currentWeekStart.add(Duration(days: i * 7)),
                          state,
                        ),
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
