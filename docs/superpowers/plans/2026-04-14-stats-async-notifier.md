# StatsViewModel AsyncNotifier 전환 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `StatsViewModel`을 `Notifier<StatsState>`에서 `AsyncNotifier<StatsState>`로 전환해 `isLoading`/`errorMessage` 수동 관리를 제거하고 `AsyncValue`가 상태를 처리하도록 한다.

**Architecture:** `StatsState`에서 `isLoading`·`errorMessage`·`clearError`를 제거하고, `StatsViewModel`을 `AsyncNotifier<StatsState>`로 교체한다. `changeMonth()`는 `copyWithPrevious`로 이전 데이터를 유지하며 로딩 표시한다. `StatsScreen`은 `ref.watch(...).when(skipLoadingOnReload: true, ...)` 패턴으로 전환한다.

**Tech Stack:** flutter_riverpod 3.x (`AsyncNotifier`, `AsyncValue`, `AsyncNotifierProvider`), flutter_test

---

## 파일 맵

| 파일 | 작업 |
|---|---|
| `lib/features/stats/presentation/viewmodels/stats_view_model.dart` | `StatsState` 단순화 + `AsyncNotifier` 전환 |
| `lib/features/stats/presentation/screens/stats_screen.dart` | `.when()` 패턴으로 전환 |
| `test/features/stats/presentation/screens/stats_screen_test.dart` | 스텁을 `AsyncNotifier` 기반으로 교체 |

---

## Task 1: StatsState 단순화 + AsyncNotifier 전환

**Files:**
- Modify: `lib/features/stats/presentation/viewmodels/stats_view_model.dart`

- [ ] **Step 1: 테스트 먼저 — 현재 테스트가 통과하는지 확인 (기준선)**

```bash
flutter test test/features/stats/presentation/screens/stats_screen_test.dart
```

예상 결과: `PASS` 2/2 (기준선 확인)

- [ ] **Step 2: `stats_view_model.dart` 전체 교체**

`lib/features/stats/presentation/viewmodels/stats_view_model.dart` 전체를 아래로 교체한다.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/usecases/get_category_stats_use_case.dart';
import '../../domain/usecases/get_expense_summary_use_case.dart';
import '../../domain/usecases/get_weekday_stats_use_case.dart';

/// 통계 화면 상태 — isLoading/errorMessage는 AsyncValue가 처리
class StatsState {
  final DateTime selectedMonth;
  final List<CategoryStat> categoryStats;
  final List<WeekdayStat> weekdayStats;

  const StatsState({
    required this.selectedMonth,
    this.categoryStats = const [],
    this.weekdayStats = const [],
  });

  StatsState copyWith({
    DateTime? selectedMonth,
    List<CategoryStat>? categoryStats,
    List<WeekdayStat>? weekdayStats,
  }) {
    return StatsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      categoryStats: categoryStats ?? this.categoryStats,
      weekdayStats: weekdayStats ?? this.weekdayStats,
    );
  }
}

/// 통계 화면 ViewModel
class StatsViewModel extends AsyncNotifier<StatsState> {
  GetCategoryStatsUseCase get _categoryStatsUseCase =>
      getIt<GetCategoryStatsUseCase>();
  GetWeekdayStatsUseCase get _weekdayStatsUseCase =>
      getIt<GetWeekdayStatsUseCase>();
  GetExpenseSummaryUseCase get _summaryUseCase =>
      getIt<GetExpenseSummaryUseCase>();

  @override
  Future<StatsState> build() => _fetchStats(
        DateTime(DateTime.now().year, DateTime.now().month, 1),
      );

  Future<StatsState> _fetchStats(DateTime month) async {
    final (categoryStats, weekdayStats) = await (
      _categoryStatsUseCase.execute(year: month.year, month: month.month),
      _weekdayStatsUseCase.execute(),
    ).wait;
    return StatsState(
      selectedMonth: month,
      categoryStats: categoryStats,
      weekdayStats: weekdayStats,
    );
  }

  /// 선택된 월을 delta만큼 이동하고 통계를 다시 로드한다.
  /// 이전 데이터를 유지하며 로딩 상태를 표시한다.
  Future<void> changeMonth(int delta) async {
    final current = state.requireValue.selectedMonth;
    final newMonth = DateTime(current.year, current.month + delta, 1);
    state = const AsyncLoading<StatsState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetchStats(newMonth));
  }

  /// 화면 당김 새로고침 — build()를 재실행한다
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 선택된 월의 월간 요약을 반환한다
  Future<ExpenseSummary> getMonthlySummary() {
    final month = state.requireValue.selectedMonth;
    return _summaryUseCase.executeMonthly(
      year: month.year,
      month: month.month,
    );
  }

  /// 현재 주(일요일 기준)의 주간 요약을 반환한다
  Future<ExpenseSummary> getWeeklySummary() {
    final weekStart = AppDateUtils.weekStartOf(DateTime.now());
    return _summaryUseCase.executeWeekly(weekStart: weekStart);
  }
}

final statsViewModelProvider =
    AsyncNotifierProvider<StatsViewModel, StatsState>(StatsViewModel.new);
```

- [ ] **Step 3: 정적 분석**

```bash
flutter analyze lib/features/stats/presentation/viewmodels/stats_view_model.dart
```

예상 결과: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/features/stats/presentation/viewmodels/stats_view_model.dart
git commit -m "refactor(stats): StatsViewModel AsyncNotifier 전환 — isLoading/errorMessage 제거"
```

---

## Task 2: StatsScreen .when() 패턴 전환

**Files:**
- Modify: `lib/features/stats/presentation/screens/stats_screen.dart`

- [ ] **Step 1: `stats_screen.dart` 전체 교체**

```dart
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
    final asyncState = ref.watch(statsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Scaffold(
      backgroundColor: bgColor,
      body: asyncState.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            '통계를 불러오지 못했습니다.',
            style: AppTypography.bodySmall.copyWith(color: textSub),
          ),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () =>
              ref.read(statsViewModelProvider.notifier).refresh(),
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
                WeekdayBarChart(stats: state.weekdayStats, isDark: isDark),
                const SizedBox(height: 20),

                // 요약 보기 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => showExpenseSummarySheet(context),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
```

- [ ] **Step 2: 정적 분석**

```bash
flutter analyze lib/features/stats/presentation/screens/stats_screen.dart
```

예상 결과: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/features/stats/presentation/screens/stats_screen.dart
git commit -m "refactor(stats): StatsScreen .when() 패턴 전환"
```

---

## Task 3: 테스트 스텁 AsyncNotifier로 교체

**Files:**
- Modify: `test/features/stats/presentation/screens/stats_screen_test.dart`

- [ ] **Step 1: 테스트 파일 전체 교체**

`AsyncNotifier<StatsState>` 기반 스텁으로 교체한다. 로딩 스텁은 완료되지 않는 `Future`를 반환하고, 에러 스텁은 예외를 throw한다.

```dart
import 'dart:async';

import 'package:daily_manwon/features/stats/presentation/screens/stats_screen.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// StatsViewModel 로딩 스텁 — build()가 완료되지 않아 loading 상태 유지
class _StubLoading extends AsyncNotifier<StatsState> {
  @override
  Future<StatsState> build() => Completer<StatsState>().future;
}

/// StatsViewModel 에러 스텁 — build()가 예외를 throw해 error 상태 유지
class _StubError extends AsyncNotifier<StatsState> {
  @override
  Future<StatsState> build() async => throw Exception('load failed');
}

Widget _buildApp(AsyncNotifier<StatsState> Function() factory) =>
    ProviderScope(
      overrides: [
        statsViewModelProvider.overrideWith(factory),
      ],
      child: const MaterialApp(home: StatsScreen()),
    );

void main() {
  group('StatsScreen', () {
    testWidgets('로딩 상태에서 CircularProgressIndicator를 표시한다',
        (tester) async {
      await tester.pumpWidget(_buildApp(_StubLoading.new));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('에러 상태에서 에러 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(_buildApp(_StubError.new));
      await tester.pump();

      expect(find.text('통계를 불러오지 못했습니다.'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/stats/presentation/screens/stats_screen_test.dart
```

예상 결과: `PASS` 2/2

- [ ] **Step 3: 커밋**

```bash
git add test/features/stats/presentation/screens/stats_screen_test.dart
git commit -m "test(stats): 스텁을 AsyncNotifier 기반으로 교체"
```

---

## Task 4: 전체 검증

**Files:** (변경 없음 — 검증만)

- [ ] **Step 1: 전체 정적 분석**

```bash
flutter analyze
```

예상 결과: `No issues found!` (기존 pre-existing info/warning은 무시)

- [ ] **Step 2: 전체 테스트 실행**

```bash
flutter test
```

예상 결과: 신규 추가된 테스트 포함 실패 0건 (pre-existing 실패 4건은 이번 변경과 무관).
