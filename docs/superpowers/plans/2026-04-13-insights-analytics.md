# Insights Analytics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 캘린더 화면에 "통계" 탭을 추가하고, 카테고리 도넛 차트·요일별 바 차트·주간/월간 요약 바텀시트를 구현한다.

**Architecture:** 기존 `lib/features/calendar/` 구조와 동일하게 `lib/features/stats/` 피처를 새로 만든다. `StatsLocalDatasource`가 기존 `Expenses` + `DailyBudgets` 테이블을 집계 쿼리로만 읽고 (DB 스키마 변경 없음), 결과를 freezed 엔티티로 변환하여 use case → `StatsViewModel` → UI에 전달한다. `CalendarScreen`은 `DefaultTabController`로 감싸 "캘린더" / "통계" 2개 탭을 제공한다.

**Tech Stack:** Flutter 3.x, Drift 2.23 (customSelect), fl_chart 0.69, flutter_riverpod 3.x (NotifierProvider), freezed, injectable/GetIt, mocktail

---

## File Map

| 상태 | 경로 | 역할 |
|------|------|------|
| 신규 | `lib/features/stats/domain/entities/category_stat.dart` | 카테고리별 지출 집계 엔티티 |
| 신규 | `lib/features/stats/domain/entities/weekday_stat.dart` | 요일별 평균 지출 엔티티 |
| 신규 | `lib/features/stats/domain/entities/expense_summary.dart` | 주간/월간 요약 엔티티 |
| 신규 | `lib/features/stats/domain/repositories/stats_repository.dart` | 통계 레포지토리 인터페이스 |
| 신규 | `lib/features/stats/data/datasources/stats_local_datasource.dart` | Drift 집계 쿼리 |
| 신규 | `lib/features/stats/data/repositories/stats_repository_impl.dart` | 레포지토리 구현체 |
| 신규 | `lib/features/stats/domain/usecases/get_category_stats_use_case.dart` | 카테고리 집계 유스케이스 |
| 신규 | `lib/features/stats/domain/usecases/get_weekday_stats_use_case.dart` | 요일별 집계 유스케이스 |
| 신규 | `lib/features/stats/domain/usecases/get_expense_summary_use_case.dart` | 요약 유스케이스 |
| 신규 | `lib/features/stats/presentation/viewmodels/stats_view_model.dart` | 통계 ViewModel (NotifierProvider) |
| 신규 | `lib/features/stats/presentation/widgets/category_donut_chart.dart` | fl_chart PieChart |
| 신규 | `lib/features/stats/presentation/widgets/weekday_bar_chart.dart` | fl_chart BarChart + 인사이트 메시지 |
| 신규 | `lib/features/stats/presentation/widgets/expense_summary_sheet.dart` | 주간/월간 요약 바텀시트 |
| 신규 | `lib/features/stats/presentation/screens/stats_screen.dart` | 통계 화면 |
| 신규 | `lib/core/widgets/month_navigator_row.dart` | 캘린더·통계 공용 월 이동 위젯 |
| 수정 | `pubspec.yaml` | fl_chart 패키지 추가 |
| 수정 | `lib/features/calendar/presentation/screens/calendar_screen.dart` | 탭 통합, MonthNavigatorRow 교체 |
| 신규 (테스트) | `test/features/stats/data/datasources/stats_local_datasource_test.dart` | 집계 쿼리 단위 테스트 |
| 신규 (테스트) | `test/features/stats/domain/usecases/get_category_stats_use_case_test.dart` | 유스케이스 단위 테스트 |

---

## Task 1: fl_chart 패키지 추가 + 도메인 엔티티 (freezed)

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/stats/domain/entities/category_stat.dart`
- Create: `lib/features/stats/domain/entities/weekday_stat.dart`
- Create: `lib/features/stats/domain/entities/expense_summary.dart`

- [ ] **Step 1: pubspec.yaml에 fl_chart 추가**

`pubspec.yaml`의 `dependencies` 섹션 `flutter_animate:` 줄 아래에 추가:

```yaml
  fl_chart: ^0.69.0
```

- [ ] **Step 2: pub get 실행**

```bash
flutter pub get
```

Expected: "Got dependencies!"

- [ ] **Step 3: CategoryStat 엔티티 생성**

`lib/features/stats/domain/entities/category_stat.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_stat.freezed.dart';

/// 특정 월의 카테고리별 지출 집계
/// [categoryIndex]: ExpenseCategory.index
/// [totalAmount]: 해당 월 카테고리 총 지출 (원)
/// [percentage]: 전체 대비 비율 (0.0~1.0)
@freezed
sealed class CategoryStat with _$CategoryStat {
  const factory CategoryStat({
    required int categoryIndex,
    required int totalAmount,
    required double percentage,
  }) = _CategoryStat;
}
```

- [ ] **Step 4: WeekdayStat 엔티티 생성**

`lib/features/stats/domain/entities/weekday_stat.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekday_stat.freezed.dart';

/// 최근 4주 요일별 일평균 지출
/// [weekday]: SQLite strftime('%w') 기준 (0=일, 1=월 … 6=토)
/// [avgAmount]: 해당 요일 일평균 지출 (원, 소수 버림)
@freezed
sealed class WeekdayStat with _$WeekdayStat {
  const factory WeekdayStat({
    required int weekday,
    required int avgAmount,
  }) = _WeekdayStat;
}
```

- [ ] **Step 5: ExpenseSummary 엔티티 생성**

`lib/features/stats/domain/entities/expense_summary.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_summary.freezed.dart';

/// 주간 또는 월간 지출 요약
/// [totalSpent]: 기간 내 총 지출 (원)
/// [totalDays]: 집계 대상 날짜 수 (오늘 포함, 미래 제외)
/// [successDays]: 예산 이하 달성일 수
/// [topCategoryIndex]: 가장 많이 지출한 카테고리 index (지출 없으면 null)
@freezed
sealed class ExpenseSummary with _$ExpenseSummary {
  const factory ExpenseSummary({
    required int totalSpent,
    required int totalDays,
    required int successDays,
    required int? topCategoryIndex,
  }) = _ExpenseSummary;
}
```

- [ ] **Step 6: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: 3개 `.freezed.dart` 파일 생성 (`category_stat.freezed.dart`, `weekday_stat.freezed.dart`, `expense_summary.freezed.dart`)

- [ ] **Step 7: 컴파일 확인**

```bash
flutter analyze lib/features/stats/
```

Expected: "No issues found!"

- [ ] **Step 8: 커밋**

```bash
git add pubspec.yaml pubspec.lock \
  lib/features/stats/domain/entities/
git commit -m "feat(stats): fl_chart 추가 및 통계 도메인 엔티티 정의"
```

---

## Task 2: StatsLocalDatasource (TDD)

**Files:**
- Create: `lib/features/stats/data/datasources/stats_local_datasource.dart`
- Create: `test/features/stats/data/datasources/stats_local_datasource_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

`test/features/stats/data/datasources/stats_local_datasource_test.dart`:

```dart
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/stats/data/datasources/stats_local_datasource.dart';

void main() {
  late AppDatabase db;
  late StatsLocalDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    datasource = StatsLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getCategoryStats', () {
    test('지출이 없을 때 빈 리스트를 반환한다', () async {
      final result = await datasource.getCategoryStats(year: 2026, month: 4);
      expect(result, isEmpty);
    });

    test('같은 달 카테고리별 합계를 내림차순으로 반환한다', () async {
      final april1 = DateTime(2026, 4, 1);
      final april2 = DateTime(2026, 4, 2);
      // food 3000+2000=5000, cafe 1500
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 3000, category: 0, createdAt: april1),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 2000, category: 0, createdAt: april2),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 1500, category: 2, createdAt: april1),
      );

      final result = await datasource.getCategoryStats(year: 2026, month: 4);

      expect(result.length, 2);
      expect(result[0].categoryIndex, 0); // food = 5000 (1위)
      expect(result[0].totalAmount, 5000);
      expect(result[0].percentage, closeTo(5000 / 6500, 0.001));
      expect(result[1].categoryIndex, 2); // cafe = 1500 (2위)
    });

    test('다른 달 지출은 포함하지 않는다', () async {
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 5000,
          category: 0,
          createdAt: DateTime(2026, 3, 31), // 3월
        ),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 1000,
          category: 1,
          createdAt: DateTime(2026, 4, 1), // 4월
        ),
      );

      final result = await datasource.getCategoryStats(year: 2026, month: 4);
      expect(result.length, 1);
      expect(result[0].totalAmount, 1000);
    });
  });

  group('getWeekdayStats', () {
    test('지출이 없을 때 빈 리스트를 반환한다', () async {
      final result = await datasource.getWeekdayStats();
      expect(result, isEmpty);
    });

    test('최근 28일 내 요일별 평균 지출을 반환한다', () async {
      final now = DateTime.now();
      // 오늘로부터 1일 전 (28일 이내)
      final recentDate = now.subtract(const Duration(days: 1));
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 6000,
          category: 0,
          createdAt: recentDate,
        ),
      );

      final result = await datasource.getWeekdayStats();
      expect(result, isNotEmpty);
      // 해당 요일 데이터가 포함돼 있어야 한다
      final sqlWeekday = recentDate.weekday % 7; // Dart Mon=1→0이 아닌 SQL 기준 변환
      expect(result.any((s) => s.avgAmount > 0), isTrue);
    });
  });

  group('getExpenseSummary', () {
    test('지출이 없을 때 0을 반환한다', () async {
      final from = DateTime(2026, 4, 7); // 월요일
      final to = DateTime(2026, 4, 13);
      final result = await datasource.getExpenseSummary(from: from, to: to);
      expect(result.totalSpent, 0);
      expect(result.successDays, 0);
      expect(result.topCategoryIndex, isNull);
    });

    test('기간 내 총 지출, 성공일, 최다 카테고리를 반환한다', () async {
      // 4/7 food 8000 (예산 10000 → 성공)
      // 4/8 transport 12000 (예산 10000 → 실패)
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 8000,
          category: 0,
          createdAt: DateTime(2026, 4, 7, 12),
        ),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 12000,
          category: 1,
          createdAt: DateTime(2026, 4, 8, 12),
        ),
      );

      final result = await datasource.getExpenseSummary(
        from: DateTime(2026, 4, 7),
        to: DateTime(2026, 4, 9), // 7,8일 포함
        dailyBudget: 10000,
      );

      expect(result.totalSpent, 20000);
      expect(result.successDays, 1);
      expect(result.topCategoryIndex, 1); // transport 12000 최다
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 → FAIL 확인**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart -v
```

Expected: 컴파일 오류 — `StatsLocalDatasource` 클래스 미존재

- [ ] **Step 3: StatsLocalDatasource 구현**

`lib/features/stats/data/datasources/stats_local_datasource.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';

/// 통계 화면용 Drift 로컬 데이터 접근 객체
/// Expenses + DailyBudgets 테이블을 읽기 전용으로 집계한다
@lazySingleton
class StatsLocalDatasource {
  final AppDatabase _db;

  StatsLocalDatasource(this._db);

  /// 특정 월의 카테고리별 지출 합계를 내림차순으로 반환한다
  /// DB 스키마 변경 없음 — expenses 테이블 GROUP BY
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final rows = await _db.customSelect(
      'SELECT category, SUM(amount) AS total '
      'FROM expenses '
      'WHERE created_at >= ? AND created_at < ? '
      'GROUP BY category '
      'ORDER BY total DESC',
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
      readsFrom: {_db.expenses},
    ).get();

    if (rows.isEmpty) return [];

    final grandTotal =
        rows.fold<int>(0, (sum, r) => sum + (r.read<int>('total')));
    return rows.map((r) {
      final total = r.read<int>('total');
      return CategoryStat(
        categoryIndex: r.read<int>('category'),
        totalAmount: total,
        percentage: grandTotal > 0 ? total / grandTotal : 0.0,
      );
    }).toList();
  }

  /// 최근 28일(4주) 요일별 일평균 지출을 반환한다
  /// weekday: 0=일, 1=월 … 6=토 (SQLite strftime('%w') 기준)
  Future<List<WeekdayStat>> getWeekdayStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day + 1); // 오늘 자정 이후 제외
    final from = DateTime(now.year, now.month, now.day - 27); // 28일 전

    final rows = await _db.customSelect(
      // 먼저 일별 합계를 구한 뒤, 요일별 평균을 계산한다
      'SELECT weekday, AVG(day_total) AS avg_amount '
      'FROM ('
      '  SELECT strftime(\'%w\', datetime(created_at, \'unixepoch\')) AS weekday, '
      '         strftime(\'%Y-%m-%d\', datetime(created_at, \'unixepoch\')) AS day_str, '
      '         SUM(amount) AS day_total '
      '  FROM expenses '
      '  WHERE created_at >= ? AND created_at < ? '
      '  GROUP BY day_str'
      ') '
      'GROUP BY weekday '
      'ORDER BY CAST(weekday AS INTEGER)',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(today),
      ],
      readsFrom: {_db.expenses},
    ).get();

    return rows.map((r) {
      return WeekdayStat(
        weekday: int.parse(r.read<String>('weekday')),
        avgAmount: (r.read<double>('avg_amount')).round(),
      );
    }).toList();
  }

  /// [from] 이상 [to] 미만 기간의 지출 요약을 반환한다
  /// [to]는 exclusive (e.g., 다음 날 00:00)
  Future<ExpenseSummary> getExpenseSummary({
    required DateTime from,
    required DateTime to,
    int dailyBudget = AppConstants.dailyBudget,
  }) async {
    // 기간 내 지출 전체 조회
    final expenses = await (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.createdAt.isBiggerOrEqualValue(from) &
                e.createdAt.isSmallerThanValue(to),
          ))
        .get();

    if (expenses.isEmpty) {
      return const ExpenseSummary(
        totalSpent: 0,
        totalDays: 0,
        successDays: 0,
        topCategoryIndex: null,
      );
    }

    // 일별 합계 집계 (Dart에서 처리)
    final Map<DateTime, int> dailyTotals = {};
    final Map<int, int> categoryTotals = {};
    for (final e in expenses) {
      final dayKey = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + e.amount;
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    // DailyBudgets에서 effective budget 조회 (없으면 dailyBudget fallback)
    final budgetRows = await (_db.select(_db.dailyBudgets)
          ..where(
            (b) =>
                b.date.isBiggerOrEqualValue(from) &
                b.date.isSmallerThanValue(to),
          ))
        .get();
    final Map<DateTime, int> effectiveBudgets = {
      for (final b in budgetRows)
        DateTime(b.date.year, b.date.month, b.date.day): b.baseAmount + b.carryOver,
    };

    final totalSpent = dailyTotals.values.fold(0, (s, v) => s + v);
    final successDays = dailyTotals.entries.where((entry) {
      final budget = effectiveBudgets[entry.key] ?? dailyBudget;
      return entry.value <= budget;
    }).length;

    int? topCategory;
    if (categoryTotals.isNotEmpty) {
      topCategory =
          categoryTotals.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    }

    return ExpenseSummary(
      totalSpent: totalSpent,
      totalDays: dailyTotals.length,
      successDays: successDays,
      topCategoryIndex: topCategory,
    );
  }
}
```

- [ ] **Step 4: 테스트 실행 → PASS 확인**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart -v
```

Expected: "All tests passed!"

- [ ] **Step 5: 커밋**

```bash
git add lib/features/stats/data/datasources/ \
  test/features/stats/data/datasources/
git commit -m "feat(stats): StatsLocalDatasource 집계 쿼리 구현 (TDD)"
```

---

## Task 3: 레포지토리 인터페이스 + 구현체 + DI 등록

**Files:**
- Create: `lib/features/stats/domain/repositories/stats_repository.dart`
- Create: `lib/features/stats/data/repositories/stats_repository_impl.dart`

- [ ] **Step 1: 레포지토리 인터페이스 작성**

`lib/features/stats/domain/repositories/stats_repository.dart`:

```dart
import '../entities/category_stat.dart';
import '../entities/expense_summary.dart';
import '../entities/weekday_stat.dart';

abstract interface class StatsRepository {
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  });

  Future<List<WeekdayStat>> getWeekdayStats();

  Future<ExpenseSummary> getWeeklySummary({
    required DateTime weekStart,
  });

  Future<ExpenseSummary> getMonthlySummary({
    required int year,
    required int month,
  });
}
```

- [ ] **Step 2: 구현체 작성**

`lib/features/stats/data/repositories/stats_repository_impl.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/category_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_datasource.dart';

@LazySingleton(as: StatsRepository)
class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDatasource _datasource;

  StatsRepositoryImpl(this._datasource);

  @override
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  }) => _datasource.getCategoryStats(year: year, month: month);

  @override
  Future<List<WeekdayStat>> getWeekdayStats() =>
      _datasource.getWeekdayStats();

  @override
  Future<ExpenseSummary> getWeeklySummary({required DateTime weekStart}) {
    final from = weekStart;
    final to = weekStart.add(const Duration(days: 7));
    return _datasource.getExpenseSummary(from: from, to: to);
  }

  @override
  Future<ExpenseSummary> getMonthlySummary({
    required int year,
    required int month,
  }) {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 1);
    return _datasource.getExpenseSummary(from: from, to: to);
  }
}
```

- [ ] **Step 3: injectable 코드 재생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `injection.config.dart` 업데이트됨 — `StatsLocalDatasource`, `StatsRepositoryImpl` 등록

- [ ] **Step 4: 분석 확인**

```bash
flutter analyze lib/features/stats/
```

Expected: "No issues found!"

- [ ] **Step 5: 커밋**

```bash
git add lib/features/stats/domain/repositories/ \
  lib/features/stats/data/repositories/ \
  lib/core/di/
git commit -m "feat(stats): StatsRepository 인터페이스 및 구현체 등록"
```

---

## Task 4: Use Cases (TDD)

**Files:**
- Create: `lib/features/stats/domain/usecases/get_category_stats_use_case.dart`
- Create: `lib/features/stats/domain/usecases/get_weekday_stats_use_case.dart`
- Create: `lib/features/stats/domain/usecases/get_expense_summary_use_case.dart`
- Create: `test/features/stats/domain/usecases/get_category_stats_use_case_test.dart`

- [ ] **Step 1: GetCategoryStats 테스트 작성**

`test/features/stats/domain/usecases/get_category_stats_use_case_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/stats/domain/entities/category_stat.dart';
import 'package:daily_manwon/features/stats/domain/repositories/stats_repository.dart';
import 'package:daily_manwon/features/stats/domain/usecases/get_category_stats_use_case.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late MockStatsRepository repository;
  late GetCategoryStatsUseCase useCase;

  setUp(() {
    repository = MockStatsRepository();
    useCase = GetCategoryStatsUseCase(repository);
  });

  test('레포지토리 결과를 그대로 반환한다', () async {
    final stats = [
      const CategoryStat(categoryIndex: 0, totalAmount: 5000, percentage: 0.5),
      const CategoryStat(categoryIndex: 2, totalAmount: 5000, percentage: 0.5),
    ];
    when(() => repository.getCategoryStats(year: 2026, month: 4))
        .thenAnswer((_) async => stats);

    final result = await useCase.execute(year: 2026, month: 4);

    expect(result, stats);
    verify(() => repository.getCategoryStats(year: 2026, month: 4)).called(1);
  });
}
```

- [ ] **Step 2: 테스트 실행 → FAIL 확인**

```bash
flutter test test/features/stats/domain/usecases/get_category_stats_use_case_test.dart -v
```

Expected: 컴파일 오류 — `GetCategoryStatsUseCase` 미존재

- [ ] **Step 3: 3개 유스케이스 구현**

`lib/features/stats/domain/usecases/get_category_stats_use_case.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../entities/category_stat.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetCategoryStatsUseCase {
  final StatsRepository _repository;

  GetCategoryStatsUseCase(this._repository);

  Future<List<CategoryStat>> execute({required int year, required int month}) =>
      _repository.getCategoryStats(year: year, month: month);
}
```

`lib/features/stats/domain/usecases/get_weekday_stats_use_case.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../entities/weekday_stat.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetWeekdayStatsUseCase {
  final StatsRepository _repository;

  GetWeekdayStatsUseCase(this._repository);

  Future<List<WeekdayStat>> execute() => _repository.getWeekdayStats();
}
```

`lib/features/stats/domain/usecases/get_expense_summary_use_case.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../entities/expense_summary.dart';
import '../repositories/stats_repository.dart';

@lazySingleton
class GetExpenseSummaryUseCase {
  final StatsRepository _repository;

  GetExpenseSummaryUseCase(this._repository);

  Future<ExpenseSummary> executeWeekly({required DateTime weekStart}) =>
      _repository.getWeeklySummary(weekStart: weekStart);

  Future<ExpenseSummary> executeMonthly({required int year, required int month}) =>
      _repository.getMonthlySummary(year: year, month: month);
}
```

- [ ] **Step 4: build_runner 재실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: 3개 use case가 DI에 등록됨

- [ ] **Step 5: 테스트 실행 → PASS 확인**

```bash
flutter test test/features/stats/domain/usecases/get_category_stats_use_case_test.dart -v
```

Expected: "All tests passed!"

- [ ] **Step 6: 커밋**

```bash
git add lib/features/stats/domain/usecases/ \
  test/features/stats/domain/usecases/ \
  lib/core/di/
git commit -m "feat(stats): 통계 유스케이스 3종 구현 (TDD)"
```

---

## Task 5: StatsViewModel

**Files:**
- Create: `lib/features/stats/presentation/viewmodels/stats_view_model.dart`

- [ ] **Step 1: StatsState + StatsViewModel 작성**

`lib/features/stats/presentation/viewmodels/stats_view_model.dart`:

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

class StatsState {
  final DateTime selectedMonth;
  final List<CategoryStat> categoryStats;
  final List<WeekdayStat> weekdayStats;
  final bool isLoading;
  final String? errorMessage;

  const StatsState({
    required this.selectedMonth,
    this.categoryStats = const [],
    this.weekdayStats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StatsState copyWith({
    DateTime? selectedMonth,
    List<CategoryStat>? categoryStats,
    List<WeekdayStat>? weekdayStats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatsState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      categoryStats: categoryStats ?? this.categoryStats,
      weekdayStats: weekdayStats ?? this.weekdayStats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 통계 화면 ViewModel
class StatsViewModel extends Notifier<StatsState> {
  GetCategoryStatsUseCase get _categoryStats =>
      getIt<GetCategoryStatsUseCase>();
  GetWeekdayStatsUseCase get _weekdayStats => getIt<GetWeekdayStatsUseCase>();
  GetExpenseSummaryUseCase get _summary => getIt<GetExpenseSummaryUseCase>();

  @override
  StatsState build() {
    final now = DateTime.now();
    final initialState = StatsState(
      selectedMonth: DateTime(now.year, now.month, 1),
      isLoading: true,
    );
    Future.microtask(loadStats);
    return initialState;
  }

  /// 선택된 월을 delta만큼 이동하고 통계를 다시 로드한다
  Future<void> changeMonth(int delta) async {
    final current = state.selectedMonth;
    final newMonth = DateTime(current.year, current.month + delta, 1);
    state = state.copyWith(selectedMonth: newMonth, isLoading: true, clearError: true);
    await loadStats();
  }

  /// 현재 선택된 월의 카테고리 통계와 요일별 통계를 로드한다
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final (categoryStats, weekdayStats) = await (
        _categoryStats.execute(
          year: state.selectedMonth.year,
          month: state.selectedMonth.month,
        ),
        _weekdayStats.execute(),
      ).wait;
      state = state.copyWith(
        categoryStats: categoryStats,
        weekdayStats: weekdayStats,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '통계를 불러오지 못했습니다.',
      );
    }
  }

  /// 선택된 월의 월간 요약을 반환한다
  Future<ExpenseSummary> getMonthlySummary() => _summary.executeMonthly(
        year: state.selectedMonth.year,
        month: state.selectedMonth.month,
      );

  /// 현재 주(일요일 기준)의 주간 요약을 반환한다
  Future<ExpenseSummary> getWeeklySummary() {
    final weekStart = AppDateUtils.weekStartOf(DateTime.now());
    return _summary.executeWeekly(weekStart: weekStart);
  }
}

final statsViewModelProvider = NotifierProvider<StatsViewModel, StatsState>(
  StatsViewModel.new,
);
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/stats/presentation/viewmodels/
```

Expected: "No issues found!"

- [ ] **Step 3: 커밋**

```bash
git add lib/features/stats/presentation/viewmodels/
git commit -m "feat(stats): StatsViewModel 구현 (NotifierProvider)"
```

---

## Task 6: CategoryDonutChart 위젯

**Files:**
- Create: `lib/features/stats/presentation/widgets/category_donut_chart.dart`

- [ ] **Step 1: CategoryDonutChart 구현**

`lib/features/stats/presentation/widgets/category_donut_chart.dart`:

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category_stat.dart';

/// 월별 카테고리 지출 도넛 차트
/// [stats]: CategoryStat 목록 (비어 있으면 "지출 없음" 메시지 표시)
class CategoryDonutChart extends StatelessWidget {
  final List<CategoryStat> stats;
  final DateTime selectedMonth;
  final bool isDark;

  const CategoryDonutChart({
    super.key,
    required this.stats,
    required this.selectedMonth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

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
            '카테고리별 소비',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '이번 달 지출이 없어요',
                  style: AppTypography.bodySmall.copyWith(color: textSub),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 도넛 차트
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: stats.map((s) {
                            final category = ExpenseCategory.values[s.categoryIndex];
                            return PieChartSectionData(
                              value: s.totalAmount.toDouble(),
                              color: category.color,
                              radius: 30,
                              showTitle: false,
                            );
                          }).toList(),
                          centerSpaceRadius: 38,
                          sectionsSpace: 2,
                        ),
                      ),
                      // 중앙 레이블
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${selectedMonth.month}월',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMain,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(
                              stats.fold(0, (s, c) => s + c.totalAmount),
                            ),
                            style: AppTypography.labelSmall.copyWith(
                              color: textSub,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // 범례
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: stats.map((s) {
                      final category = ExpenseCategory.values[s.categoryIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.label,
                              style: AppTypography.bodySmall.copyWith(
                                color: textMain,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(s.percentage * 100).toStringAsFixed(0)}%',
                              style: AppTypography.bodySmall.copyWith(
                                color: textMain,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Divider(color: divider, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            '캘린더 탭에서 월을 선택하면 해당 월 통계로 바뀌어요',
            style: AppTypography.bodySmall.copyWith(color: textSub, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/stats/presentation/widgets/category_donut_chart.dart
```

Expected: "No issues found!"

- [ ] **Step 3: 커밋**

```bash
git add lib/features/stats/presentation/widgets/category_donut_chart.dart
git commit -m "feat(stats): 카테고리 도넛 차트 위젯 구현"
```

---

## Task 7: WeekdayBarChart 위젯 + 인사이트 메시지

**Files:**
- Create: `lib/features/stats/presentation/widgets/weekday_bar_chart.dart`

- [ ] **Step 1: WeekdayBarChart 구현**

`lib/features/stats/presentation/widgets/weekday_bar_chart.dart`:

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/weekday_stat.dart';

/// 최근 4주 요일별 평균 지출 바 차트
/// [stats]: WeekdayStat 목록 (weekday: 0=일 … 6=토)
class WeekdayBarChart extends StatelessWidget {
  final List<WeekdayStat> stats;
  final bool isDark;

  const WeekdayBarChart({
    super.key,
    required this.stats,
    required this.isDark,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  String _insightMessage(List<WeekdayStat> sorted) {
    if (sorted.isEmpty) return '';
    // 평균 지출 상위 2개 요일 추출
    final top = sorted.take(2).map((s) => _weekdayLabels[s.weekday]).toList();
    if (top.length == 1) {
      return '${top[0]}요일에 지출이 가장 많아요';
    }
    return '${top[0]}·${top[1]}요일에 지출이 집중되는 편이에요';
  }

  @override
  Widget build(BuildContext context) {
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final cardBg = isDark ? AppColors.darkCard : AppColors.card;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;
    final barDefault = isDark ? AppColors.darkDivider : AppColors.divider;
    final todayWeekday = DateTime.now().weekday % 7; // Dart Mon=1 → Sun=0

    // 7개 슬롯 채우기 (데이터 없는 요일은 0으로)
    final statMap = {for (final s in stats) s.weekday: s.avgAmount};
    final amounts = List.generate(7, (i) => statMap[i] ?? 0);
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);

    // 인사이트: 평균 지출 상위 요일
    final sortedByAmount = stats.toList()
      ..sort((a, b) => b.avgAmount.compareTo(a.avgAmount));
    final insightMsg = _insightMessage(sortedByAmount);

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
            '요일별 소비 패턴',
            style: AppTypography.labelMedium.copyWith(
              color: textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '최근 4주 일평균 기준',
            style: AppTypography.bodySmall.copyWith(color: textSub, fontSize: 11),
          ),
          const SizedBox(height: 16),
          if (stats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '아직 지출 데이터가 없어요',
                  style: AppTypography.bodySmall.copyWith(color: textSub),
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  maxY: maxAmount > 0 ? maxAmount * 1.3 : 10,
                  barGroups: List.generate(7, (i) {
                    final isToday = i == todayWeekday;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: amounts[i].toDouble(),
                          color: isToday ? AppColors.budgetWarning : barDefault,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          final isToday = idx == todayWeekday;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _weekdayLabels[idx],
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: isToday
                                    ? AppColors.budgetWarning
                                    : textSub,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
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
          if (insightMsg.isNotEmpty) ...[
            Divider(color: divider, height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.budgetWarning.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      insightMsg,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.budgetWarning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/stats/presentation/widgets/weekday_bar_chart.dart
```

Expected: "No issues found!"

- [ ] **Step 3: 커밋**

```bash
git add lib/features/stats/presentation/widgets/weekday_bar_chart.dart
git commit -m "feat(stats): 요일별 소비 바 차트 위젯 구현"
```

---

## Task 8: ExpenseSummarySheet

**Files:**
- Create: `lib/features/stats/presentation/widgets/expense_summary_sheet.dart`

- [ ] **Step 1: ExpenseSummarySheet 구현**

`lib/features/stats/presentation/widgets/expense_summary_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense_summary.dart';
import '../viewmodels/stats_view_model.dart';

/// 주간/월간 요약 바텀시트
/// [showExpenseSummarySheet]를 통해 호출한다
Future<void> showExpenseSummarySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExpenseSummarySheetBody(),
  );
}

class _ExpenseSummarySheetBody extends ConsumerWidget {
  const _ExpenseSummarySheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final vm = ref.read(statsViewModelProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FutureBuilder(
        future: Future.wait([
          vm.getWeeklySummary(),
          vm.getMonthlySummary(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final weekly = snapshot.data![0];
          final monthly = snapshot.data![1];
          final selectedMonth = ref.read(statsViewModelProvider).selectedMonth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                title: '이번 주',
                titleColor: AppColors.budgetWarning,
                summary: weekly,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: '${selectedMonth.month}월',
                titleColor: isDark ? AppColors.darkTextMain : AppColors.textMain,
                summary: monthly,
                isDark: isDark,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final ExpenseSummary summary;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.titleColor,
    required this.summary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : const Color(0xFFFFF9F5);
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final topCategory = summary.topCategoryIndex != null
        ? ExpenseCategory.values[summary.topCategoryIndex!]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          _Row(
            label: '총 지출',
            value: CurrencyFormatter.format(summary.totalSpent),
            textMain: textMain,
            textSub: textSub,
            divider: divider,
          ),
          _Row(
            label: '예산 달성일',
            value: '${summary.successDays}일 / ${summary.totalDays}일',
            valueColor: const Color(0xFF2DBD8E),
            textMain: textMain,
            textSub: textSub,
            divider: divider,
          ),
          _Row(
            label: '가장 많은 카테고리',
            value: topCategory != null
                ? '${topCategory.emoji} ${topCategory.label}'
                : '—',
            isLast: true,
            textMain: textMain,
            textSub: textSub,
            divider: divider,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;
  final Color textMain;
  final Color textSub;
  final Color divider;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
    required this.textMain,
    required this.textSub,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isLast) Divider(color: divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: textSub,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  color: valueColor ?? textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/stats/presentation/widgets/expense_summary_sheet.dart
```

Expected: "No issues found!"

- [ ] **Step 3: 커밋**

```bash
git add lib/features/stats/presentation/widgets/expense_summary_sheet.dart
git commit -m "feat(stats): 주간/월간 요약 바텀시트 구현"
```

---

## Task 9: StatsScreen

**Files:**
- Create: `lib/features/stats/presentation/screens/stats_screen.dart`

- [ ] **Step 1: StatsScreen 구현**

`lib/features/stats/presentation/screens/stats_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/stats_view_model.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/expense_summary_sheet.dart';
import '../widgets/weekday_bar_chart.dart';

/// 통계 화면 — CalendarScreen의 "통계" 탭으로 진입
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

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

// 통계 화면 전용 월 선택기 (CalendarScreen의 _MonthlyNavRow와 동일 구조)
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

- [ ] **Step 2: 분석 확인**

```bash
flutter analyze lib/features/stats/presentation/screens/
```

Expected: "No issues found!"

- [ ] **Step 3: 커밋**

```bash
git add lib/features/stats/presentation/screens/
git commit -m "feat(stats): StatsScreen 구현 (도넛·바 차트, 요약 버튼)"
```

---

## Task 10: CalendarScreen 탭 통합

**Files:**
- Modify: `lib/features/calendar/presentation/screens/calendar_screen.dart`

CalendarScreen을 `DefaultTabController`로 감싸고 "캘린더" / "통계" 2개 탭을 추가한다. 기존 FloatingActionButton은 캘린더 탭에서만 표시한다.

- [ ] **Step 1: CalendarScreen 수정**

`lib/features/calendar/presentation/screens/calendar_screen.dart` 전체를 아래로 교체한다.

**변경 내용 요약:**
- `ConsumerStatefulWidget`에 `SingleTickerProviderStateMixin` 추가
- `TabController _tabController` 선언 및 `initState`/`dispose` 처리
- `Scaffold.floatingActionButton`을 탭 인덱스 조건부로 표시
- `Scaffold.body`를 `Column(TabBar + Expanded(TabBarView))`으로 구성
- Tab 0 = 기존 캘린더 콘텐츠, Tab 1 = `StatsScreen()`

```dart
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
      // 탭 전환 시 FAB 표시 여부를 갱신한다
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
              backgroundColor: isDark ? AppColors.darkTextMain : AppColors.textMain,
              foregroundColor: isDark ? AppColors.darkBackground : AppColors.white,
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
                                        .read(calendarViewModelProvider.notifier)
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
```

- [ ] **Step 2: 전체 분석 실행**

```bash
flutter analyze lib/
```

Expected: "No issues found!" (경고는 허용, 오류 없어야 함)

- [ ] **Step 3: 전체 테스트 실행**

```bash
flutter test
```

Expected: 모든 테스트 통과

- [ ] **Step 4: 최종 커밋**

```bash
git add lib/features/calendar/presentation/screens/calendar_screen.dart \
  lib/features/stats/
git commit -m "feat(stats): 캘린더 화면에 통계 탭 통합 — 도넛/바 차트, 요약 바텀시트"
```

---

## 자가 검수

### 1. 스펙 커버리지

| 스펙 요구사항 | 구현 태스크 |
|---|---|
| 캘린더 화면 상단 "통계" 탭 추가 | Task 10 |
| 카테고리별 도넛 차트 (선택 월 기준) | Task 6 |
| 월 선택 가능 | Task 9 (`_MonthNavRow`) + Task 5 (`changeMonth`) |
| 기존 `AppColors.category*` 색상 사용 | Task 6 (ExpenseCategory.color 사용) |
| 요일별 바 차트 (최근 4주 평균) | Task 7 |
| 오늘 요일 `#F5A623` 강조 | Task 7 (`AppColors.budgetWarning`) |
| 인사이트 메시지 (상위 요일) | Task 7 (`_insightMessage`) |
| 주간/월간 요약 리포트 바텀시트 | Task 8 + Task 9 (요약 보기 버튼) |
| 요약: 총 지출, 예산 달성일, 최다 카테고리 | Task 8 (`_SummaryCard`) |
| DB 스키마 변경 없음 | Task 2 (기존 테이블 집계 쿼리만 사용) ✅ |

### 2. 플레이스홀더 스캔

- 모든 코드 스텝에 실제 Dart 코드 포함됨 ✅
- "TBD", "TODO" 없음 ✅

### 3. 타입 일관성

- `WeekdayStat.weekday`: int (SQLite strftime '%w' 기준 0=일 … 6=토) — Task 2, Task 7 모두 동일하게 적용 ✅
- `ExpenseSummary.topCategoryIndex`: `int?` — Task 2, Task 8 모두 nullable 처리 ✅
- `statsViewModelProvider`: `NotifierProvider<StatsViewModel, StatsState>` — Task 5, Task 9, Task 10 모두 동일하게 참조 ✅
- `CategoryStat.color`: Task 6에서 `ExpenseCategory.values[categoryIndex].color` 사용 — categoryIndex 범위 0~4로 제한됨, DB에서 올바른 값만 저장되므로 안전 ✅

---

**Plan complete and saved to `docs/superpowers/plans/2026-04-13-insights-analytics.md`.**

**Two execution options:**

**1. Subagent-Driven (recommended)** — 태스크별 새 서브에이전트 파견, 태스크 간 리뷰 가능, 빠른 반복

**2. Inline Execution** — 이 세션에서 executing-plans 스킬로 일괄 실행, 체크포인트마다 검토

**어떤 방식으로 진행할까요?**
