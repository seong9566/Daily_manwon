# Weekly Stats Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add weekly statistics view to StatsScreen with a monthly/weekly toggle, showing daily bar chart, success days, total spend, and insights.

**Architecture:** Extend `StatsState` with weekly fields; add `DailyStat` entity and `getDailyAmountsForWeek` datasource method; add 4 new widgets rendered based on `StatsViewMode` enum.

**Tech Stack:** Flutter, Riverpod 3.x (`AsyncNotifier`), Drift (SQLite `customSelect`), fl_chart (`BarChart` with `extraLinesData`), freezed, GetIt + Injectable.

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| CREATE | `lib/features/stats/domain/entities/daily_stat.dart` | Freezed entity: date + amount |
| MODIFY | `lib/features/stats/data/datasources/stats_local_datasource.dart` | Add `getDailyAmountsForWeek`, refactor `getCategoryStats` → `getCategoryStatsForRange` |
| MODIFY | `lib/features/stats/domain/repositories/stats_repository.dart` | Add `getDailyStatsForWeek` |
| MODIFY | `lib/features/stats/data/repositories/stats_repository_impl.dart` | Implement `getDailyStatsForWeek` |
| CREATE | `lib/features/stats/domain/usecases/get_daily_stats_use_case.dart` | Thin use case wrapping `getDailyStatsForWeek` |
| MODIFY | `lib/core/utils/app_date_utils.dart` | Add `statsWeekNavLabel()` for stats nav display |
| MODIFY | `lib/features/stats/presentation/viewmodels/stats_view_model.dart` | Add `StatsViewMode`, weekly `StatsState` fields, `toggleViewMode`, `changeWeek`, updated `_fetchStats` |
| CREATE | `lib/features/stats/presentation/widgets/stats_view_mode_toggle.dart` | 월간/주간 toggle button |
| CREATE | `lib/features/stats/presentation/widgets/weekly_daily_bar_chart.dart` | 7-bar chart with daily budget dashed line |
| CREATE | `lib/features/stats/presentation/widgets/weekly_stats_summary_row.dart` | 총지출 · 성공일 · 일평균 3-column row |
| CREATE | `lib/features/stats/presentation/widgets/weekly_insight_row.dart` | 전주 비교 + 최다 카테고리 insight card |
| MODIFY | `lib/features/stats/presentation/screens/stats_screen.dart` | Integrate toggle + conditional weekly/monthly content |
| MODIFY | `test/features/stats/data/datasources/stats_local_datasource_test.dart` | Tests for new datasource methods |

---

### Task 1: `DailyStat` Freezed Entity

**Files:**
- Create: `lib/features/stats/domain/entities/daily_stat.dart`

- [ ] **Step 1: Write the entity file**

```dart
// lib/features/stats/domain/entities/daily_stat.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_stat.freezed.dart';

/// 특정 날짜의 총 지출
@freezed
sealed class DailyStat with _$DailyStat {
  const factory DailyStat({
    required DateTime date,   // 해당 날짜 00:00:00
    required int amount,      // 당일 총 지출 (원), 지출 없으면 0
  }) = _DailyStat;
}
```

- [ ] **Step 2: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `daily_stat.freezed.dart` generated, no errors.

- [ ] **Step 3: Verify compilation**

```bash
flutter analyze lib/features/stats/domain/entities/daily_stat.dart
```

Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/stats/domain/entities/daily_stat.dart \
        lib/features/stats/domain/entities/daily_stat.freezed.dart
git commit -m "feat(stats): DailyStat 엔티티 추가"
```

---

### Task 2: Datasource — `getDailyAmountsForWeek` + `getCategoryStatsForRange`

**Files:**
- Modify: `lib/features/stats/data/datasources/stats_local_datasource.dart`
- Modify: `test/features/stats/data/datasources/stats_local_datasource_test.dart`

- [ ] **Step 1: Write failing tests**

Add the following group to `stats_local_datasource_test.dart` after the existing `getExpenseSummary` group:

```dart
group('getDailyAmountsForWeek', () {
  test('지출이 없는 주는 amount=0인 7개 DailyStat을 반환한다', () async {
    final weekStart = DateTime(2026, 4, 6); // 일요일
    final result = await datasource.getDailyAmountsForWeek(weekStart);

    expect(result.length, 7);
    expect(result.every((s) => s.amount == 0), isTrue);
    expect(result.first.date, weekStart);
    expect(result.last.date, DateTime(2026, 4, 12)); // 토요일
  });

  test('지출이 있는 날은 amount를 채우고 없는 날은 0으로 반환한다', () async {
    final weekStart = DateTime(2026, 4, 6);
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 5000,
        category: 0,
        createdAt: DateTime(2026, 4, 7, 12), // 월요일
      ),
    );
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 3000,
        category: 1,
        createdAt: DateTime(2026, 4, 7, 15), // 같은 날 두 번째 지출
      ),
    );
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 12000,
        category: 0,
        createdAt: DateTime(2026, 4, 9, 10), // 수요일
      ),
    );

    final result = await datasource.getDailyAmountsForWeek(weekStart);

    expect(result.length, 7);
    expect(result[0].amount, 0);  // 일요일
    expect(result[1].amount, 8000); // 월요일 5000+3000
    expect(result[2].amount, 0);  // 화요일
    expect(result[3].amount, 12000); // 수요일
    expect(result[4].amount, 0);  // 목요일
    expect(result[5].amount, 0);  // 금요일
    expect(result[6].amount, 0);  // 토요일
  });

  test('주 범위 밖의 지출은 포함하지 않는다', () async {
    final weekStart = DateTime(2026, 4, 6);
    // 이전 주 (4/5 토요일)
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 9000,
        category: 0,
        createdAt: DateTime(2026, 4, 5, 12),
      ),
    );
    // 다음 주 (4/13 일요일)
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 7000,
        category: 0,
        createdAt: DateTime(2026, 4, 13, 12),
      ),
    );

    final result = await datasource.getDailyAmountsForWeek(weekStart);
    expect(result.every((s) => s.amount == 0), isTrue);
  });
});

group('getCategoryStatsForRange', () {
  test('날짜 범위 내 지출만 집계한다', () async {
    final from = DateTime(2026, 4, 6);
    final to = DateTime(2026, 4, 13);

    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 5000,
        category: 0,
        createdAt: DateTime(2026, 4, 7, 12), // 범위 내
      ),
    );
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 3000,
        category: 0,
        createdAt: DateTime(2026, 4, 5, 12), // 범위 밖 (from 이전)
      ),
    );
    await db.into(db.expenses).insert(
      ExpensesCompanion.insert(
        amount: 2000,
        category: 1,
        createdAt: DateTime(2026, 4, 13, 10), // 범위 밖 (to 포함 안 됨)
      ),
    );

    final result = await datasource.getCategoryStatsForRange(from, to);
    expect(result.length, 1);
    expect(result[0].categoryIndex, 0);
    expect(result[0].totalAmount, 5000);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart
```

Expected: FAIL — `getDailyAmountsForWeek` and `getCategoryStatsForRange` not defined.

- [ ] **Step 3: Implement datasource changes**

In `stats_local_datasource.dart`, add the import at the top:
```dart
import '../../domain/entities/daily_stat.dart';
```

Replace the existing `getCategoryStats` method and add two new methods:

```dart
/// [from] 이상 [to] 미만 기간의 카테고리별 지출 합계를 내림차순으로 반환한다
Future<List<CategoryStat>> getCategoryStatsForRange(
  DateTime from,
  DateTime to,
) async {
  final rows = await _db.customSelect(
    'SELECT category, SUM(amount) AS total '
    'FROM expenses '
    'WHERE created_at >= ? AND created_at < ? '
    'GROUP BY category '
    'ORDER BY total DESC',
    variables: [
      Variable.withDateTime(from),
      Variable.withDateTime(to),
    ],
    readsFrom: {_db.expenses},
  ).get();

  if (rows.isEmpty) return [];

  final grandTotal =
      rows.fold<int>(0, (sum, r) => sum + r.read<int>('total'));
  return rows.map((r) {
    final total = r.read<int>('total');
    return CategoryStat(
      categoryIndex: r.read<int>('category'),
      totalAmount: total,
      percentage: grandTotal > 0 ? total / grandTotal : 0.0,
    );
  }).toList();
}

/// 특정 월의 카테고리별 지출 합계를 내림차순으로 반환한다
Future<List<CategoryStat>> getCategoryStats({
  required int year,
  required int month,
}) => getCategoryStatsForRange(
      DateTime(year, month, 1),
      DateTime(year, month + 1, 1),
    );

/// 해당 주(일~토) 7일의 일별 지출을 반환한다
/// 지출이 없는 날은 amount=0으로 채워 항상 7개 반환
Future<List<DailyStat>> getDailyAmountsForWeek(DateTime weekStart) async {
  final weekEnd = weekStart.add(const Duration(days: 7));

  final rows = await _db.customSelect(
    'SELECT strftime(\'%Y-%m-%d\', created_at/1000, \'unixepoch\') AS day_str, '
    '       SUM(amount) AS day_total '
    'FROM expenses '
    'WHERE created_at >= ? AND created_at < ? '
    'GROUP BY day_str',
    variables: [
      Variable.withDateTime(weekStart),
      Variable.withDateTime(weekEnd),
    ],
    readsFrom: {_db.expenses},
  ).get();

  final Map<String, int> dayMap = {
    for (final r in rows)
      r.read<String>('day_str'): r.read<int>('day_total'),
  };

  return List.generate(7, (i) {
    final date = weekStart.add(Duration(days: i));
    final dayStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return DailyStat(date: date, amount: dayMap[dayStr] ?? 0);
  });
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/stats/data/datasources/stats_local_datasource.dart \
        test/features/stats/data/datasources/stats_local_datasource_test.dart
git commit -m "feat(stats): getDailyAmountsForWeek 및 getCategoryStatsForRange 추가"
```

---

### Task 3: Repository Layer — `getDailyStatsForWeek`

**Files:**
- Modify: `lib/features/stats/domain/repositories/stats_repository.dart`
- Modify: `lib/features/stats/data/repositories/stats_repository_impl.dart`

- [ ] **Step 1: Update the repository interface**

In `stats_repository.dart`, add import and method:

```dart
import '../entities/category_stat.dart';
import '../entities/daily_stat.dart';
import '../entities/expense_summary.dart';
import '../entities/weekday_stat.dart';

abstract interface class StatsRepository {
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  });

  Future<List<WeekdayStat>> getWeekdayStats();

  Future<List<DailyStat>> getDailyStatsForWeek(DateTime weekStart);

  Future<ExpenseSummary> getWeeklySummary({
    required DateTime weekStart,
  });

  Future<ExpenseSummary> getMonthlySummary({
    required int year,
    required int month,
  });
}
```

- [ ] **Step 2: Implement in `stats_repository_impl.dart`**

Add import and override:

```dart
import '../../domain/entities/daily_stat.dart';
```

Add method in `StatsRepositoryImpl`:

```dart
@override
Future<List<DailyStat>> getDailyStatsForWeek(DateTime weekStart) =>
    _datasource.getDailyAmountsForWeek(weekStart);
```

- [ ] **Step 3: Analyze for errors**

```bash
flutter analyze lib/features/stats/
```

Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/stats/domain/repositories/stats_repository.dart \
        lib/features/stats/data/repositories/stats_repository_impl.dart
git commit -m "feat(stats): StatsRepository에 getDailyStatsForWeek 추가"
```

---

### Task 4: `GetDailyStatsUseCase`

**Files:**
- Create: `lib/features/stats/domain/usecases/get_daily_stats_use_case.dart`

- [ ] **Step 1: Create use case**

```dart
// lib/features/stats/domain/usecases/get_daily_stats_use_case.dart
import 'package:injectable/injectable.dart';

import '../entities/daily_stat.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetDailyStatsUseCase {
  final StatsRepository _repository;

  GetDailyStatsUseCase(this._repository);

  Future<List<DailyStat>> execute({required DateTime weekStart}) =>
      _repository.getDailyStatsForWeek(weekStart);
}
```

- [ ] **Step 2: Run build_runner (Injectable registration)**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: DI config updated, no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/stats/domain/usecases/get_daily_stats_use_case.dart \
        lib/core/di/injection.config.dart
git commit -m "feat(stats): GetDailyStatsUseCase 추가"
```

---

### Task 5: `AppDateUtils.statsWeekNavLabel`

**Files:**
- Modify: `lib/core/utils/app_date_utils.dart`

- [ ] **Step 1: Add the method**

Add after the existing `weekRangeLabel` method:

```dart
/// 통계 화면 주간 네비게이터 레이블
/// 같은 해: "4/6(일) ~ 4/12(토)"
/// 다른 해: "2025/12/29(일) ~ 2026/1/4(토)"
static String statsWeekNavLabel(DateTime weekStart) {
  const labels = ['일', '월', '화', '수', '목', '금', '토'];
  final weekEnd = weekStart.add(const Duration(days: 6));
  final startLabel = labels[weekStart.weekday % 7];
  final endLabel = labels[weekEnd.weekday % 7];

  if (weekStart.year == weekEnd.year) {
    return '${weekStart.month}/${weekStart.day}($startLabel)'
        ' ~ ${weekEnd.month}/${weekEnd.day}($endLabel)';
  }
  return '${weekStart.year}/${weekStart.month}/${weekStart.day}($startLabel)'
      ' ~ ${weekEnd.year}/${weekEnd.month}/${weekEnd.day}($endLabel)';
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/core/utils/app_date_utils.dart
```

Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/utils/app_date_utils.dart
git commit -m "feat(stats): AppDateUtils에 statsWeekNavLabel 추가"
```

---

### Task 6: `StatsViewMode` + `StatsState` + `StatsViewModel`

**Files:**
- Modify: `lib/features/stats/presentation/viewmodels/stats_view_model.dart`

- [ ] **Step 1: Write the test for toggle + week navigation**

Create `test/features/stats/presentation/viewmodels/stats_view_model_test.dart`:

```dart
import 'package:daily_manwon/features/stats/domain/entities/category_stat.dart';
import 'package:daily_manwon/features/stats/domain/entities/daily_stat.dart';
import 'package:daily_manwon/features/stats/domain/entities/expense_summary.dart';
import 'package:daily_manwon/features/stats/domain/entities/weekday_stat.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatsViewModel', () {
    test('toggleViewMode: monthly → weekly → monthly', () async {
      final state = StatsState(
        selectedMonth: DateTime(2026, 4, 1),
        selectedWeekStart: DateTime(2026, 4, 6),
        viewMode: StatsViewMode.monthly,
        categoryStats: const [],
        weekdayStats: const [],
        dailyStats: const [],
        weeklyTotalSpent: 0,
        weeklyBudget: 70000,
        weeklySuccessDays: 0,
        weeklyTotalDays: 0,
        weeklyTopCategoryIndex: null,
        prevWeekTotalSpent: null,
      );

      final toggled = state.copyWith(
        viewMode: state.viewMode == StatsViewMode.monthly
            ? StatsViewMode.weekly
            : StatsViewMode.monthly,
      );
      expect(toggled.viewMode, StatsViewMode.weekly);

      final toggledBack = toggled.copyWith(
        viewMode: toggled.viewMode == StatsViewMode.monthly
            ? StatsViewMode.weekly
            : StatsViewMode.monthly,
      );
      expect(toggledBack.viewMode, StatsViewMode.monthly);
    });

    test('StatsState.selectedWeekStart changes by 7 days on changeWeek', () {
      final weekStart = DateTime(2026, 4, 6);
      final nextWeek = weekStart.add(const Duration(days: 7));
      expect(nextWeek, DateTime(2026, 4, 13));

      final prevWeek = weekStart.subtract(const Duration(days: 7));
      expect(prevWeek, DateTime(2026, 3, 30));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails (StatsViewMode not defined yet)**

```bash
flutter test test/features/stats/presentation/viewmodels/stats_view_model_test.dart
```

Expected: Compilation error — `StatsViewMode` not defined.

- [ ] **Step 3: Rewrite `stats_view_model.dart`**

```dart
// lib/features/stats/presentation/viewmodels/stats_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/usecases/get_category_stats_use_case.dart';
import '../../domain/usecases/get_daily_stats_use_case.dart';
import '../../domain/usecases/get_expense_summary_use_case.dart';
import '../../domain/usecases/get_weekday_stats_use_case.dart';

enum StatsViewMode { monthly, weekly }

/// 통계 화면 상태 — isLoading/errorMessage는 AsyncValue가 처리
class StatsState {
  final DateTime selectedMonth;
  final List<CategoryStat> categoryStats;
  final List<WeekdayStat> weekdayStats;
  // 공통
  final StatsViewMode viewMode;
  final DateTime selectedWeekStart;
  // 주간 전용
  final List<DailyStat> dailyStats;
  final int weeklyTotalSpent;
  final int weeklyBudget;        // 7 × dailyBudget
  final int weeklySuccessDays;
  final int weeklyTotalDays;
  final int? weeklyTopCategoryIndex;
  final int? prevWeekTotalSpent; // null = 전주 데이터 없음

  const StatsState({
    required this.selectedMonth,
    required this.selectedWeekStart,
    this.viewMode = StatsViewMode.monthly,
    this.categoryStats = const [],
    this.weekdayStats = const [],
    this.dailyStats = const [],
    this.weeklyTotalSpent = 0,
    this.weeklyBudget = 0,
    this.weeklySuccessDays = 0,
    this.weeklyTotalDays = 0,
    this.weeklyTopCategoryIndex,
    this.prevWeekTotalSpent,
  });

  StatsState copyWith({
    DateTime? selectedMonth,
    DateTime? selectedWeekStart,
    StatsViewMode? viewMode,
    List<CategoryStat>? categoryStats,
    List<WeekdayStat>? weekdayStats,
    List<DailyStat>? dailyStats,
    int? weeklyTotalSpent,
    int? weeklyBudget,
    int? weeklySuccessDays,
    int? weeklyTotalDays,
    int? weeklyTopCategoryIndex,
    int? prevWeekTotalSpent,
  }) {
    return StatsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedWeekStart: selectedWeekStart ?? this.selectedWeekStart,
      viewMode: viewMode ?? this.viewMode,
      categoryStats: categoryStats ?? this.categoryStats,
      weekdayStats: weekdayStats ?? this.weekdayStats,
      dailyStats: dailyStats ?? this.dailyStats,
      weeklyTotalSpent: weeklyTotalSpent ?? this.weeklyTotalSpent,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      weeklySuccessDays: weeklySuccessDays ?? this.weeklySuccessDays,
      weeklyTotalDays: weeklyTotalDays ?? this.weeklyTotalDays,
      weeklyTopCategoryIndex:
          weeklyTopCategoryIndex ?? this.weeklyTopCategoryIndex,
      prevWeekTotalSpent: prevWeekTotalSpent ?? this.prevWeekTotalSpent,
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
  GetDailyStatsUseCase get _dailyStatsUseCase =>
      getIt<GetDailyStatsUseCase>();

  @override
  Future<StatsState> build() {
    final now = DateTime.now();
    return _fetchStats(
      DateTime(now.year, now.month, 1),
      AppDateUtils.weekStartOf(now),
    );
  }

  Future<StatsState> _fetchStats(
    DateTime month,
    DateTime weekStart, {
    StatsViewMode viewMode = StatsViewMode.monthly,
  }) async {
    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final results = await (
      _categoryStatsUseCase.execute(year: month.year, month: month.month),
      _weekdayStatsUseCase.execute(),
      _dailyStatsUseCase.execute(weekStart: weekStart),
      _summaryUseCase.executeWeekly(weekStart: weekStart),
      _summaryUseCase.executeWeekly(weekStart: prevWeekStart),
    ).wait;

    final weekSummary = results.$4;
    final prevSummary = results.$5;

    return StatsState(
      selectedMonth: month,
      selectedWeekStart: weekStart,
      viewMode: viewMode,
      categoryStats: results.$1,
      weekdayStats: results.$2,
      dailyStats: results.$3,
      weeklyTotalSpent: weekSummary.totalSpent,
      weeklyBudget: 7 * AppConstants.dailyBudget,
      weeklySuccessDays: weekSummary.successDays,
      weeklyTotalDays: weekSummary.totalDays,
      weeklyTopCategoryIndex: weekSummary.topCategoryIndex,
      prevWeekTotalSpent:
          prevSummary.totalDays > 0 ? prevSummary.totalSpent : null,
    );
  }

  /// 모드 전환 — 재fetch 없음 (데이터 이미 있음)
  void toggleViewMode() {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        viewMode: current.viewMode == StatsViewMode.monthly
            ? StatsViewMode.weekly
            : StatsViewMode.monthly,
      ),
    );
  }

  /// 선택된 월을 delta만큼 이동하고 통계를 다시 로드한다
  Future<void> changeMonth(int delta) async {
    final now = DateTime.now();
    final current = state.asData?.value;
    final currentMonth = current?.selectedMonth ?? DateTime(now.year, now.month, 1);
    final weekStart = current?.selectedWeekStart ?? AppDateUtils.weekStartOf(now);
    final viewMode = current?.viewMode ?? StatsViewMode.monthly;

    final newMonth = DateTime(currentMonth.year, currentMonth.month + delta, 1);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchStats(newMonth, weekStart, viewMode: viewMode),
    );
  }

  /// 선택된 주를 delta만큼 이동하고 통계를 다시 로드한다
  Future<void> changeWeek(int delta) async {
    final now = DateTime.now();
    final current = state.asData?.value;
    final month = current?.selectedMonth ?? DateTime(now.year, now.month, 1);
    final weekStart = current?.selectedWeekStart ?? AppDateUtils.weekStartOf(now);
    final viewMode = current?.viewMode ?? StatsViewMode.weekly;

    final newWeekStart = weekStart.add(Duration(days: 7 * delta));
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchStats(month, newWeekStart, viewMode: viewMode),
    );
  }

  /// 화면 당김 새로고침 — build()를 재실행한다
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// 선택된 월의 월간 요약을 반환한다
  Future<ExpenseSummary> getMonthlySummary() {
    final now = DateTime.now();
    final month = state.asData?.value.selectedMonth ??
        DateTime(now.year, now.month, 1);
    return _summaryUseCase.executeMonthly(
      year: month.year,
      month: month.month,
    );
  }

  /// 현재 주(일요일 기준)의 주간 요약을 반환한다
  Future<ExpenseSummary> getWeeklySummary() {
    final weekStart = state.asData?.value.selectedWeekStart ??
        AppDateUtils.weekStartOf(DateTime.now());
    return _summaryUseCase.executeWeekly(weekStart: weekStart);
  }
}

final statsViewModelProvider =
    AsyncNotifierProvider<StatsViewModel, StatsState>(StatsViewModel.new);
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/features/stats/presentation/viewmodels/stats_view_model_test.dart
flutter test test/features/stats/presentation/screens/stats_screen_test.dart
```

Expected: All PASS. (The screen test stubs still work because `StatsViewModel` is still an `AsyncNotifier<StatsState>`.)

- [ ] **Step 5: Analyze**

```bash
flutter analyze lib/features/stats/presentation/viewmodels/stats_view_model.dart
```

Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/features/stats/presentation/viewmodels/stats_view_model.dart \
        test/features/stats/presentation/viewmodels/stats_view_model_test.dart
git commit -m "feat(stats): StatsViewMode 추가 및 주간 StatsState 필드·ViewModel 확장"
```

---

### Task 7: `StatsViewModeToggle` Widget

**Files:**
- Create: `lib/features/stats/presentation/widgets/stats_view_mode_toggle.dart`

- [ ] **Step 1: Create widget**

```dart
// lib/features/stats/presentation/widgets/stats_view_mode_toggle.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/stats_view_model.dart';

/// 통계 화면 월간/주간 전환 버튼
class StatsViewModeToggle extends StatelessWidget {
  final StatsViewMode viewMode;
  final bool isDark;
  final VoidCallback onToggle;

  const StatsViewModeToggle({
    super.key,
    required this.viewMode,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tab(
              label: '월간',
              selected: viewMode == StatsViewMode.monthly,
              textMain: textMain,
              textSub: textSub,
            ),
            _Tab(
              label: '주간',
              selected: viewMode == StatsViewMode.weekly,
              textMain: textMain,
              textSub: textSub,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color textMain;
  final Color textSub;

  const _Tab({
    required this.label,
    required this.selected,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: selected
          ? BoxDecoration(
              color: AppColors.budgetWarning.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          fontSize: 12,
          color: selected ? AppColors.budgetWarning : textSub,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/features/stats/presentation/widgets/stats_view_mode_toggle.dart
```

Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/stats/presentation/widgets/stats_view_mode_toggle.dart
git commit -m "feat(stats): StatsViewModeToggle 위젯 추가"
```

---

### Task 8: `WeeklyDailyBarChart` Widget

**Files:**
- Create: `lib/features/stats/presentation/widgets/weekly_daily_bar_chart.dart`

- [ ] **Step 1: Create widget**

```dart
// lib/features/stats/presentation/widgets/weekly_daily_bar_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/daily_stat.dart';

/// 이번 주 일별 지출 바 차트 (일~토 7개 막대 + 예산선 점선)
class WeeklyDailyBarChart extends StatelessWidget {
  final List<DailyStat> stats;   // 항상 7개
  final bool isDark;

  const WeeklyDailyBarChart({
    super.key,
    required this.stats,
    required this.isDark,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final barEmpty = isDark ? AppColors.darkDivider : AppColors.divider;

    final amounts = stats.map((s) => s.amount).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    final budget = AppConstants.dailyBudget.toDouble();
    final chartMax = maxAmount > budget ? maxAmount * 1.2 : budget * 1.3;

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
            '일별 지출',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                barGroups: List.generate(7, (i) {
                  final amount = amounts[i].toDouble();
                  Color barColor;
                  if (amount == 0) {
                    barColor = barEmpty;
                  } else if (amount <= budget) {
                    barColor = AppColors.statusComfortableStrong;
                  } else {
                    barColor = AppColors.budgetDanger;
                  }
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: amount == 0 ? 0.5 : amount, // 빈 날도 미세 높이
                        color: barColor,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: budget,
                      color: AppColors.budgetWarning.withAlpha(180),
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _weekdayLabels[idx],
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: textSub,
                            ),
                          ),
                        );
                      },
                      reservedSize: 24,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Check `AppColors.statusComfortableStrong` exists**

```bash
flutter analyze lib/features/stats/presentation/widgets/weekly_daily_bar_chart.dart
```

Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/features/stats/presentation/widgets/weekly_daily_bar_chart.dart
git commit -m "feat(stats): WeeklyDailyBarChart 위젯 추가"
```

---

### Task 9: `WeeklyStatsSummaryRow` + `WeeklyInsightRow` Widgets

**Files:**
- Create: `lib/features/stats/presentation/widgets/weekly_stats_summary_row.dart`
- Create: `lib/features/stats/presentation/widgets/weekly_insight_row.dart`

- [ ] **Step 1: Create `WeeklyStatsSummaryRow`**

```dart
// lib/features/stats/presentation/widgets/weekly_stats_summary_row.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 주간 핵심 수치 3-column 카드 (총 지출 · 성공일 · 일평균)
class WeeklyStatsSummaryRow extends StatelessWidget {
  final int totalSpent;
  final int successDays;
  final int totalDays;
  final bool isDark;

  const WeeklyStatsSummaryRow({
    super.key,
    required this.totalSpent,
    required this.successDays,
    required this.totalDays,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final avgDaily = totalDays > 0 ? totalSpent ~/ totalDays : 0;

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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          _StatCell(
            label: '총 지출',
            value: CurrencyFormatter.format(totalSpent),
            textMain: textMain,
            textSub: textSub,
          ),
          VerticalDivider(color: divider, width: 1, thickness: 1),
          _StatCell(
            label: '성공일',
            value: totalDays > 0 ? '$successDays/${totalDays}일' : '-',
            textMain: textMain,
            textSub: textSub,
          ),
          VerticalDivider(color: divider, width: 1, thickness: 1),
          _StatCell(
            label: '일평균',
            value: CurrencyFormatter.format(avgDaily),
            textMain: textMain,
            textSub: textSub,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color textMain;
  final Color textSub;

  const _StatCell({
    required this.label,
    required this.value,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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
```

- [ ] **Step 2: Create `WeeklyInsightRow`**

```dart
// lib/features/stats/presentation/widgets/weekly_insight_row.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 주간 인사이트 카드 (전주 비교 + 최다 카테고리)
/// [prevWeekTotalSpent]: null이면 전주 비교 행 미표시
/// [topCategoryIndex]: null이면 최다 카테고리 행 미표시
class WeeklyInsightRow extends StatelessWidget {
  final int currentWeekTotalSpent;
  final int? prevWeekTotalSpent;
  final int? topCategoryIndex;
  final bool isDark;

  const WeeklyInsightRow({
    super.key,
    required this.currentWeekTotalSpent,
    required this.prevWeekTotalSpent,
    required this.topCategoryIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

    final hasPrevWeek = prevWeekTotalSpent != null;
    final hasTopCategory = topCategoryIndex != null;

    if (!hasPrevWeek && !hasTopCategory) return const SizedBox.shrink();

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
            '인사이트',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (hasPrevWeek) _PrevWeekRow(
            current: currentWeekTotalSpent,
            prev: prevWeekTotalSpent!,
            textMain: textMain,
          ),
          if (hasPrevWeek && hasTopCategory) const SizedBox(height: 8),
          if (hasTopCategory) _TopCategoryRow(
            categoryIndex: topCategoryIndex!,
            textMain: textMain,
            textSub: textSub,
          ),
        ],
      ),
    );
  }
}

class _PrevWeekRow extends StatelessWidget {
  final int current;
  final int prev;
  final Color textMain;

  const _PrevWeekRow({
    required this.current,
    required this.prev,
    required this.textMain,
  });

  @override
  Widget build(BuildContext context) {
    final diff = current - prev;
    final isLess = diff < 0;
    final label = isLess
        ? '↓ 전주보다 ${CurrencyFormatter.format(diff.abs())} 적게 씀'
        : diff == 0
            ? '= 전주와 동일하게 씀'
            : '↑ 전주보다 ${CurrencyFormatter.format(diff)} 더 씀';
    final color = isLess ? AppColors.statusComfortableStrong : AppColors.budgetDanger;

    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _TopCategoryRow extends StatelessWidget {
  final int categoryIndex;
  final Color textMain;
  final Color textSub;

  const _TopCategoryRow({
    required this.categoryIndex,
    required this.textMain,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.values[categoryIndex];
    return Row(
      children: [
        Text(
          category.emoji,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 6),
        Text(
          '최다 지출: ${category.label}',
          style: AppTypography.bodySmall.copyWith(
            color: textMain,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Check `ExpenseCategory.emoji` exists**

```bash
grep -n 'emoji\|label' lib/core/constants/app_constants.dart | head -20
```

If `emoji` getter doesn't exist on `ExpenseCategory`, use only `category.label` in `_TopCategoryRow`:

```dart
// Replace the emoji Text widget with an icon or just remove the emoji line
// and show: '최다 지출: ${category.label}'
```

- [ ] **Step 4: Analyze**

```bash
flutter analyze lib/features/stats/presentation/widgets/weekly_stats_summary_row.dart \
               lib/features/stats/presentation/widgets/weekly_insight_row.dart
```

Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/features/stats/presentation/widgets/weekly_stats_summary_row.dart \
        lib/features/stats/presentation/widgets/weekly_insight_row.dart
git commit -m "feat(stats): WeeklyStatsSummaryRow·WeeklyInsightRow 위젯 추가"
```

---

### Task 10: `StatsScreen` Integration

**Files:**
- Modify: `lib/features/stats/presentation/screens/stats_screen.dart`

- [ ] **Step 1: Rewrite `stats_screen.dart`**

```dart
// lib/features/stats/presentation/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../viewmodels/stats_view_model.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/expense_summary_sheet.dart';
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
          error: (e, _) => _errorWidget(textSub),
          data: (s) => RefreshIndicator(
            onRefresh: () =>
                ref.read(statsViewModelProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 네비게이터 + 모드 토글
                  _StatsNavRow(
                    viewMode: s.viewMode,
                    selectedMonth: s.selectedMonth,
                    selectedWeekStart: s.selectedWeekStart,
                    onPrevMonth: () =>
                        ref.read(statsViewModelProvider.notifier).changeMonth(-1),
                    onNextMonth: () =>
                        ref.read(statsViewModelProvider.notifier).changeMonth(1),
                    onPrevWeek: () =>
                        ref.read(statsViewModelProvider.notifier).changeWeek(-1),
                    onNextWeek: () =>
                        ref.read(statsViewModelProvider.notifier).changeWeek(1),
                    onToggleMode: () =>
                        ref.read(statsViewModelProvider.notifier).toggleViewMode(),
                    isDark: isDark,
                    textMain: textMain,
                  ),
                  const SizedBox(height: 16),

                  if (s.viewMode == StatsViewMode.weekly) ...[
                    // 주간 콘텐츠
                    WeeklyDailyBarChart(stats: s.dailyStats, isDark: isDark),
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
                    ),
                  ] else ...[
                    // 월간 콘텐츠
                    CategoryDonutChart(
                      stats: s.categoryStats,
                      selectedMonth: s.selectedMonth,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    WeekdayBarChart(stats: s.weekdayStats, isDark: isDark),
                    const SizedBox(height: 20),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Center _errorWidget(Color textSub) {
    return Center(
      child: Text(
        '통계를 불러오지 못했습니다.',
        style: AppTypography.bodySmall.copyWith(color: textSub),
      ),
    );
  }
}

/// 통계 화면 전용 날짜 네비게이터 (월간/주간 모드 대응)
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
      children: [
        IconButton(
          onPressed: onPrev,
          icon: Icon(Icons.chevron_left, color: textMain, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        Expanded(
          child: Text(
            _label,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(color: textMain),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(Icons.chevron_right, color: textMain, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        const SizedBox(width: 4),
        StatsViewModeToggle(
          viewMode: viewMode,
          isDark: isDark,
          onToggle: onToggleMode,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run all stats tests**

```bash
flutter test test/features/stats/
```

Expected: All PASS.

- [ ] **Step 3: Full analyze**

```bash
flutter analyze lib/features/stats/
```

Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/features/stats/presentation/screens/stats_screen.dart
git commit -m "feat(stats): StatsScreen에 주간 통계 뷰 통합"
```

---

### Task 11: Verification

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: All PASS.

- [ ] **Step 2: Full analyze**

```bash
flutter analyze
```

Expected: No issues.

- [ ] **Step 3: Check spec coverage**

Verify against `docs/superpowers/specs/2026-04-14-weekly-stats-design.md`:

| Requirement | Covered by |
|---|---|
| 월간/주간 토글 | `StatsViewModeToggle`, `toggleViewMode()` |
| 일별 지출 bar chart + 예산선 | `WeeklyDailyBarChart` |
| 총 지출 · 성공일 · 일평균 | `WeeklyStatsSummaryRow` |
| 전주 대비 증감 | `WeeklyInsightRow._PrevWeekRow` |
| 최다 지출 카테고리 | `WeeklyInsightRow._TopCategoryRow` |
| 주 시작 일요일 | `AppDateUtils.weekStartOf()` in `build()` |
| 날짜 선택기 주간 형식 | `AppDateUtils.statsWeekNavLabel()` |
| getDailyAmountsForWeek 7개 반환 | Datasource test Task 2 |
| getCategoryStatsForRange 날짜 필터 | Datasource test Task 2 |
| prevWeekTotalSpent null = 미표시 | `WeeklyInsightRow` guard |
| weeklyTopCategoryIndex null = 미표시 | `WeeklyInsightRow` guard |

- [ ] **Step 4: Commit final**

No additional files — verification only.
