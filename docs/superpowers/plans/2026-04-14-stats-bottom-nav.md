# 통계 탭 바텀 네비 독립 분리 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 캘린더 화면 내 통계 탭을 바텀 네비게이션의 독립 탭으로 분리해 홈/캘린더/통계/설정 4탭 구조를 만든다.

**Architecture:** `StatsScreen`에 `Scaffold` 래퍼를 추가해 독립 화면으로 만든 후, GoRouter에 `/stats` 브랜치를 추가하고 `AppShell`에 네비 아이템을 삽입한다. `CalendarScreen`에서는 `TabController`, `TabBar`, `TabBarView`를 제거하고 캘린더 UI만 남긴다.

**Tech Stack:** Flutter, GoRouter (`StatefulShellRoute.indexedStack`), flutter_riverpod, flutter_test

---

## 파일 맵

| 파일 | 작업 |
|---|---|
| `lib/features/stats/presentation/screens/stats_screen.dart` | `ColoredBox` → `Scaffold` 교체 |
| `lib/core/router/app_router.dart` | `/stats` 상수 + 브랜치 추가 |
| `lib/core/router/app_shell.dart` | 통계 `NavigationDestination` 추가 |
| `lib/features/calendar/presentation/screens/calendar_screen.dart` | 탭 구조 전체 제거 |
| `test/features/stats/presentation/screens/stats_screen_test.dart` | 신규 — 독립 화면 렌더링 테스트 |

---

## Task 1: StatsScreen 독립화 — Scaffold 래퍼 추가

**Files:**
- Modify: `lib/features/stats/presentation/screens/stats_screen.dart`
- Create: `test/features/stats/presentation/screens/stats_screen_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/stats/presentation/screens/` 디렉터리를 만들고 아래 파일을 생성한다.

```dart
// test/features/stats/presentation/screens/stats_screen_test.dart
import 'package:daily_manwon/features/stats/presentation/screens/stats_screen.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubStatsViewModel extends StatsViewModel {
  @override
  StatsState build() {
    return StatsState(
      selectedMonth: DateTime(2024, 4, 1),
      isLoading: true,
    );
  }
}

Widget _buildApp() => ProviderScope(
      overrides: [
        statsViewModelProvider.overrideWith(_StubStatsViewModel.new),
      ],
      child: const MaterialApp(home: StatsScreen()),
    );

void main() {
  group('StatsScreen 독립 화면', () {
    testWidgets('Scaffold를 포함한다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('로딩 상태에서 CircularProgressIndicator를 표시한다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 실패 확인**

```bash
flutter test test/features/stats/presentation/screens/stats_screen_test.dart
```

예상 결과: `FAIL` — `StatsScreen`의 최상위가 `ColoredBox`이므로 `Scaffold`를 찾지 못함.

- [ ] **Step 3: StatsScreen 최상위를 Scaffold로 교체**

`lib/features/stats/presentation/screens/stats_screen.dart`에서 `build` 메서드의 `return` 문을 수정한다.

변경 전:
```dart
return ColoredBox(
  color: bgColor,
  child: state.isLoading
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
                    CategoryDonutChart(
                      stats: state.categoryStats,
                      selectedMonth: state.selectedMonth,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    WeekdayBarChart(
                      stats: state.weekdayStats,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
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
```

변경 후 (`ColoredBox` → `Scaffold`):
```dart
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
                    CategoryDonutChart(
                      stats: state.categoryStats,
                      selectedMonth: state.selectedMonth,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    WeekdayBarChart(
                      stats: state.weekdayStats,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
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
```

- [ ] **Step 4: 테스트 실행 — 통과 확인**

```bash
flutter test test/features/stats/presentation/screens/stats_screen_test.dart
```

예상 결과: `PASS` 2/2

- [ ] **Step 5: 커밋**

```bash
git add lib/features/stats/presentation/screens/stats_screen.dart \
        test/features/stats/presentation/screens/stats_screen_test.dart
git commit -m "feat(stats): StatsScreen 독립 화면 전환 — Scaffold 래퍼 추가"
```

---

## Task 2: 라우터에 /stats 브랜치 추가

**Files:**
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: AppRoutes 상수 + StatsScreen import + 브랜치 추가**

`lib/core/router/app_router.dart` 전체를 아래로 교체한다.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/achievement/presentation/screens/achievement_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

// 라우트 경로 상수
abstract class AppRoutes {
  static const home = '/home';
  static const calendar = '/calendar';
  static const stats = '/stats';
  static const settings = '/settings';
  static const achievement = '/achievement';
  static const onboarding = '/onboarding';
}

// 네비게이션 키
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({bool isOnboardingCompleted = true}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        isOnboardingCompleted ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      // 바텀 네비게이션 탭 (ShellRoute)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 홈 탭
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 캘린더 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // 통계 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          // 설정 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // 풀스크린 라우트
      GoRoute(
        path: AppRoutes.achievement,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
```

- [ ] **Step 2: 정적 분석 실행**

```bash
flutter analyze lib/core/router/app_router.dart
```

예상 결과: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat(router): /stats 브랜치 추가 — 통계 탭 독립 라우트"
```

---

## Task 3: AppShell에 통계 NavigationDestination 추가

**Files:**
- Modify: `lib/core/router/app_shell.dart`

- [ ] **Step 1: destinations 배열에 통계 아이템 삽입**

`lib/core/router/app_shell.dart`의 `destinations` 배열을 아래로 교체한다.

변경 전:
```dart
destinations: const [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: '홈',
  ),
  NavigationDestination(
    icon: Icon(Icons.calendar_month_outlined),
    selectedIcon: Icon(Icons.calendar_month_rounded),
    label: '캘린더',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings_rounded),
    label: '설정',
  ),
],
```

변경 후:
```dart
destinations: const [
  NavigationDestination(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: '홈',
  ),
  NavigationDestination(
    icon: Icon(Icons.calendar_month_outlined),
    selectedIcon: Icon(Icons.calendar_month_rounded),
    label: '캘린더',
  ),
  NavigationDestination(
    icon: Icon(Icons.bar_chart_outlined),
    selectedIcon: Icon(Icons.bar_chart_rounded),
    label: '통계',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings_rounded),
    label: '설정',
  ),
],
```

- [ ] **Step 2: 정적 분석 실행**

```bash
flutter analyze lib/core/router/app_shell.dart
```

예상 결과: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/core/router/app_shell.dart
git commit -m "feat(shell): 통계 탭 NavigationDestination 추가"
```

---

## Task 4: CalendarScreen 탭 구조 제거

**Files:**
- Modify: `lib/features/calendar/presentation/screens/calendar_screen.dart`
- Verify: `test/features/calendar/presentation/screens/calendar_screen_fab_test.dart`

- [ ] **Step 1: 기존 FAB 테스트 실행 — 현재 상태 확인**

```bash
flutter test test/features/calendar/presentation/screens/calendar_screen_fab_test.dart
```

예상 결과: `PASS` (리팩토링 전 기준선 확인)

- [ ] **Step 2: CalendarScreen 전체 교체**

`lib/features/calendar/presentation/screens/calendar_screen.dart` 전체를 아래로 교체한다. 제거 항목: `SingleTickerProviderStateMixin`, `TabController`, `initState`, `dispose`, `TabBar`, `TabBarView`, `StatsScreen` import, `isCalendarTab` 조건.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/acorn_streak_badge.dart';
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
          await showExpenseAddBottomSheet(context, date: date);
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
      ),
    );
  }
}
```

- [ ] **Step 3: FAB 테스트 실행 — 통과 확인**

```bash
flutter test test/features/calendar/presentation/screens/calendar_screen_fab_test.dart
```

예상 결과: `PASS` 2/2 (FAB은 여전히 항상 렌더링됨)

- [ ] **Step 4: 커밋**

```bash
git add lib/features/calendar/presentation/screens/calendar_screen.dart
git commit -m "refactor(calendar): 탭 구조 제거 — 캘린더 UI만 유지"
```

---

## Task 5: 전체 검증

**Files:** (변경 없음 — 검증만)

- [ ] **Step 1: 정적 분석 전체 실행**

```bash
flutter analyze
```

예상 결과: `No issues found!`

- [ ] **Step 2: 전체 테스트 실행**

```bash
flutter test
```

예상 결과: 모든 테스트 PASS. 새로 추가된 테스트 포함 실패 0건.

- [ ] **Step 3: 수동 스모크 테스트 체크리스트**

앱을 실행(`flutter run`)한 뒤 아래 항목을 확인한다.

1. 바텀 네비에 **홈 / 캘린더 / 통계 / 설정** 4개 탭이 표시된다
2. 통계 탭 선택 시 도넛 차트 / 바 차트 / 요약 버튼이 정상 렌더링된다
3. 캘린더 탭에 상단 탭바(캘린더/통계 토글)가 없다
4. 캘린더 화면 우하단 FAB(+)이 표시되고 탭하면 지출 추가 바텀시트가 열린다
5. 각 탭 간 이동 후 돌아와도 스크롤 위치·선택 상태가 유지된다

- [ ] **Step 4: 최종 커밋 (필요 시)**

테스트 결과 이상 없으면 추가 커밋 불필요.
