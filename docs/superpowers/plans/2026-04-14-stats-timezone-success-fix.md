# Stats Timezone & Success Days Bug Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 주간 통계에서 UTC 날짜 버킷팅 오류(KST 이른 아침 지출이 전날로 분류)와 지출 없는 날이 성공일 계산에서 빠지는 두 가지 P2 버그를 수정한다.

**Architecture:** Dart 레이어에서 로컬 시간으로 직접 날짜를 정규화해 SQLite UTC 의존을 제거한다. `getDailyAmountsForWeek`와 `getWeekdayStats` 모두 raw 행을 Dart에서 집계하도록 변경하고, `StatsViewModel._fetchStats`에서 성공일 계산 시 `dailyStats` 7개 항목 기반으로 재산출한다.

**Tech Stack:** Dart, Drift 2.x (SQLite), flutter_riverpod 3.x, flutter_test

---

## File Map

| 파일 | 변경 내용 |
|------|-----------|
| `lib/features/stats/data/datasources/stats_local_datasource.dart` | `getDailyAmountsForWeek`, `getWeekdayStats` — SQL strftime 제거, Dart 로컬 날짜 집계로 교체 |
| `lib/features/stats/presentation/viewmodels/stats_view_model.dart` | `_fetchStats` — `weeklySuccessDays` 계산을 `dailyStats` 기반으로 교체 |
| `test/features/stats/data/datasources/stats_local_datasource_test.dart` | `getDailyAmountsForWeek` 및 `getWeekdayStats` 그룹에 로컬 날짜 정규화 회귀 테스트 추가 |
| `test/features/stats/presentation/viewmodels/stats_view_model_test.dart` | 성공일 계산 — no-spend day 포함 케이스 테스트 추가 (파일이 없으면 새로 생성) |

---

## Task 1: `getDailyAmountsForWeek` — Dart-layer 로컬 날짜 정규화

**Files:**
- Modify: `lib/features/stats/data/datasources/stats_local_datasource.dart:63-91`
- Modify: `test/features/stats/data/datasources/stats_local_datasource_test.dart:148-195`

### 배경

기존 코드는 SQLite `strftime('%Y-%m-%d', created_at, 'unixepoch')`로 날짜를 포맷한다. Drift는 `DateTime`을 Unix 초 정수로 저장하므로, `unixepoch` 변환은 항상 UTC 기준이다. KST(UTC+9) 기기에서 일요일 08:00 KST(= 토요일 23:00 UTC)에 입력한 지출은 SQLite가 "토요일"로 분류하지만 Dart에서는 "일요일"로 조회해 값이 0이 된다.

**수정 전략:** SQL에서 날짜 그룹핑을 제거하고 raw 지출 행을 가져온 뒤 Dart에서 `createdAt.toLocal()`로 날짜 문자열을 만들어 집계한다.

- [ ] **Step 1: 실패 테스트 작성 — 로컬 날짜 경계 케이스**

`test/features/stats/data/datasources/stats_local_datasource_test.dart`의 `getDailyAmountsForWeek` group 맨 끝에 아래 테스트를 추가한다.

```dart
test('자정 직후(00:30) 지출은 해당 날짜 로컬 기준으로 집계한다', () async {
  final weekStart = DateTime(2026, 4, 6); // 일요일 (local)
  // 월요일 00:30 local — UTC+9에서는 일요일 15:30 UTC
  final mondayMorning = DateTime(2026, 4, 7, 0, 30); // local
  await db.into(db.expenses).insert(
    ExpensesCompanion.insert(
      amount: 4000,
      category: 0,
      createdAt: mondayMorning,
    ),
  );

  final result = await datasource.getDailyAmountsForWeek(weekStart);

  expect(result.length, 7);
  // 월요일(index 1)에 집계돼야 한다
  expect(result[1].amount, 4000); // Monday
  expect(result[0].amount, 0);    // Sunday
});
```

- [ ] **Step 2: 테스트 실행 — FAIL 확인**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart --name '자정 직후'
```

UTC 환경에서는 PASS될 수 있다. 그 경우 다음 단계로 넘어가도 무방하다.

- [ ] **Step 3: `getDailyAmountsForWeek` 구현 교체**

`stats_local_datasource.dart`의 `getDailyAmountsForWeek` 메서드 전체를 아래로 교체한다.

```dart
/// 해당 주(일~토) 7일의 일별 지출을 반환한다
/// [weekStart]: 해당 주 일요일 00:00:00 (로컬 시간)
/// [반환]: 지출 없는 날은 amount=0으로 채워 항상 7개 반환
Future<List<DailyStat>> getDailyAmountsForWeek(DateTime weekStart) async {
  final weekEnd = weekStart.add(const Duration(days: 7));

  final expenses = await (_db.select(_db.expenses)
        ..where(
          (e) =>
              e.createdAt.isBiggerOrEqualValue(weekStart) &
              e.createdAt.isSmallerThanValue(weekEnd),
        ))
      .get();

  // Dart 로컬 날짜 기준 집계 — SQLite strftime UTC 오류 방지
  final Map<String, int> dayMap = {};
  for (final e in expenses) {
    final local = e.createdAt.toLocal();
    final dayStr =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
    dayMap[dayStr] = (dayMap[dayStr] ?? 0) + e.amount;
  }

  return List.generate(7, (i) {
    final date = weekStart.add(Duration(days: i));
    final dayStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return DailyStat(date: date, amount: dayMap[dayStr] ?? 0);
  });
}
```

- [ ] **Step 4: 기존 테스트 + 신규 테스트 전체 통과 확인**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 5: 커밋**

```bash
git add lib/features/stats/data/datasources/stats_local_datasource.dart \
        test/features/stats/data/datasources/stats_local_datasource_test.dart
git commit -m "fix(stats): getDailyAmountsForWeek — Dart 로컬 날짜 정규화로 UTC 버킷팅 오류 수정"
```

---

## Task 2: `getWeekdayStats` — Dart-layer 로컬 날짜 정규화

**Files:**
- Modify: `lib/features/stats/data/datasources/stats_local_datasource.dart:97-129`
- Modify: `test/features/stats/data/datasources/stats_local_datasource_test.dart:72-106`

### 배경

`getWeekdayStats`도 동일한 패턴(`strftime('%Y-%m-%d', created_at, 'unixepoch')`)을 사용해 날짜를 UTC로 분류한다. 자정 근처 지출이 다른 요일로 분류되면 요일별 평균 차트가 잘못 표시된다.

- [ ] **Step 1: 실패 테스트 작성 — 자정 경계 요일 분류**

`getWeekdayStats` group에 추가한다.

```dart
test('자정 직후 지출은 로컬 날짜 기준 요일로 집계한다', () async {
  // 2026-04-13 월요일(weekday=1 in Dart, %w=1 in SQLite) 00:30 local
  final mondayMorning = DateTime(2026, 4, 13, 0, 30);
  await db.into(db.expenses).insert(
    ExpensesCompanion.insert(
      amount: 7000,
      category: 0,
      createdAt: mondayMorning,
    ),
  );

  final result = await datasource.getWeekdayStats(year: 2026, month: 4);

  // weekday=1 (월요일, SQLite %w 기준)이 있어야 한다
  expect(result.any((s) => s.weekday == 1 && s.avgAmount > 0), isTrue);
  // weekday=0 (일요일)은 없어야 한다
  expect(result.any((s) => s.weekday == 0 && s.avgAmount > 0), isFalse);
});
```

- [ ] **Step 2: 테스트 실행 — FAIL 확인**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart --name '자정 직후 지출은 로컬'
```

- [ ] **Step 3: `getWeekdayStats` 구현 교체**

`stats_local_datasource.dart`의 `getWeekdayStats` 메서드 전체를 아래로 교체한다.

```dart
/// 지정된 월의 요일별 일평균 지출을 반환한다
///
/// 요일 인덱스: 0=일, 1=월 … 6=토 (SQLite %w 동일)
/// Dart-layer에서 로컬 날짜 기준 집계 — SQLite unixepoch UTC 오류 방지
Future<List<WeekdayStat>> getWeekdayStats({
  required int year,
  required int month,
}) async {
  final from = DateTime(year, month, 1);
  final to = DateTime(year, month + 1, 1);

  final expenses = await (_db.select(_db.expenses)
        ..where(
          (e) =>
              e.createdAt.isBiggerOrEqualValue(from) &
              e.createdAt.isSmallerThanValue(to),
        ))
      .get();

  if (expenses.isEmpty) return [];

  // 로컬 날짜별 일 합계 및 요일 매핑
  final Map<String, int> dayTotals = {};
  final Map<String, int> dayWeekday = {};
  for (final e in expenses) {
    final local = e.createdAt.toLocal();
    final dayStr =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
    dayTotals[dayStr] = (dayTotals[dayStr] ?? 0) + e.amount;
    // Dart weekday: 1=Mon…7=Sun → % 7 → 0=Sun, 1=Mon…6=Sat
    dayWeekday[dayStr] = local.weekday % 7;
  }

  // 요일별 금액 리스트 집계
  final Map<int, List<int>> weekdayAmounts = {};
  for (final entry in dayTotals.entries) {
    final wd = dayWeekday[entry.key]!;
    (weekdayAmounts[wd] ??= []).add(entry.value);
  }

  return weekdayAmounts.entries
      .map(
        (e) => WeekdayStat(
          weekday: e.key,
          avgAmount:
              (e.value.fold(0, (s, v) => s + v) / e.value.length).round(),
        ),
      )
      .toList()
    ..sort((a, b) => a.weekday.compareTo(b.weekday));
}
```

- [ ] **Step 4: 전체 테스트 통과 확인**

```bash
flutter test test/features/stats/data/datasources/stats_local_datasource_test.dart
```

Expected: 모든 테스트 PASS

- [ ] **Step 5: 커밋**

```bash
git add lib/features/stats/data/datasources/stats_local_datasource.dart \
        test/features/stats/data/datasources/stats_local_datasource_test.dart
git commit -m "fix(stats): getWeekdayStats — Dart 로컬 날짜 정규화로 UTC 요일 분류 오류 수정"
```

---

## Task 3: `weeklySuccessDays` — no-spend day 포함 계산 수정

**Files:**
- Modify: `lib/features/stats/presentation/viewmodels/stats_view_model.dart:128-134`

### 배경

기존 코드는 `weekSummary.successDays`를 사용한다. `getExpenseSummary`는 `dailyTotals`에 있는 날(지출이 1건 이상인 날)만 카운트하므로, 지출이 전혀 없는 날은 성공일로 포함되지 않는다. 결과적으로 지출 없는 6일 + 예산 내 1일인 주가 `1/7`로 표시된다.

**수정 전략:** Task 1에서 이미 항상 7개의 `DailyStat`(지출 없으면 `amount=0`)을 반환하므로, `dailyStats.where((s) => s.amount <= dailyBudget).length`로 직접 계산한다.

- [ ] **Step 1: 테스트 파일 확인 또는 생성**

```bash
ls test/features/stats/presentation/viewmodels/
```

파일이 없으면 `test/features/stats/presentation/viewmodels/stats_view_model_test.dart` 생성 후 아래 내용으로 시작한다.

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_manwon/features/stats/domain/entities/daily_stat.dart';

void main() {
  group('weeklySuccessDays 계산', () {
    // 순수 로직 검증 — 실제 ViewModel을 테스트하려면 Riverpod mock 필요
    // 여기서는 계산 로직만 단위 검증한다

    int computeSuccessDays({
      required List<DailyStat> dailyStats,
      required int dailyBudget,
      required bool isFutureWeek,
    }) {
      if (isFutureWeek) return 0;
      return dailyStats.where((s) => s.amount <= dailyBudget).length;
    }

    test('지출 없는 날도 성공일로 포함한다', () {
      final dailyStats = [
        DailyStat(date: DateTime(2026, 4, 6), amount: 0),    // no-spend → 성공
        DailyStat(date: DateTime(2026, 4, 7), amount: 8000), // 예산 내 → 성공
        DailyStat(date: DateTime(2026, 4, 8), amount: 0),    // no-spend → 성공
        DailyStat(date: DateTime(2026, 4, 9), amount: 0),    // no-spend → 성공
        DailyStat(date: DateTime(2026, 4, 10), amount: 0),   // no-spend → 성공
        DailyStat(date: DateTime(2026, 4, 11), amount: 0),   // no-spend → 성공
        DailyStat(date: DateTime(2026, 4, 12), amount: 0),   // no-spend → 성공
      ];

      final result = computeSuccessDays(
        dailyStats: dailyStats,
        dailyBudget: 10000,
        isFutureWeek: false,
      );

      expect(result, 7); // 1/7 이 아닌 7/7
    });

    test('예산 초과 날은 성공일 제외', () {
      final dailyStats = [
        DailyStat(date: DateTime(2026, 4, 6), amount: 0),
        DailyStat(date: DateTime(2026, 4, 7), amount: 12000), // 초과 → 실패
        DailyStat(date: DateTime(2026, 4, 8), amount: 0),
        DailyStat(date: DateTime(2026, 4, 9), amount: 0),
        DailyStat(date: DateTime(2026, 4, 10), amount: 0),
        DailyStat(date: DateTime(2026, 4, 11), amount: 0),
        DailyStat(date: DateTime(2026, 4, 12), amount: 0),
      ];

      final result = computeSuccessDays(
        dailyStats: dailyStats,
        dailyBudget: 10000,
        isFutureWeek: false,
      );

      expect(result, 6);
    });

    test('미래 주는 성공일 0', () {
      final dailyStats = List.generate(
        7,
        (i) => DailyStat(date: DateTime(2026, 5, i + 1), amount: 0),
      );

      final result = computeSuccessDays(
        dailyStats: dailyStats,
        dailyBudget: 10000,
        isFutureWeek: true,
      );

      expect(result, 0);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — PASS 확인 (순수 함수 테스트)**

```bash
flutter test test/features/stats/presentation/viewmodels/stats_view_model_test.dart
```

Expected: PASS (로직 자체는 순수 함수 테스트라 ViewModel 수정 전에도 통과함)

- [ ] **Step 3: `_fetchStats` 성공일 계산 수정**

`stats_view_model.dart` 128~134줄의 `weeklySuccessDays` 계산 부분을 아래로 교체한다.

기존:
```dart
final now = DateTime.now();
final todayStart = DateTime(now.year, now.month, now.day);
// 선택 주의 일요일이 오늘보다 미래이면 성공일 0
final isFutureWeek = weekStart.isAfter(todayStart);
final weeklySuccessDays = isFutureWeek
    ? 0
    : (weekSummary.totalSpent == 0 ? 7 : weekSummary.successDays);
```

교체 후:
```dart
final now = DateTime.now();
final todayStart = DateTime(now.year, now.month, now.day);
// 선택 주의 일요일이 오늘보다 미래이면 성공일 0
final isFutureWeek = weekStart.isAfter(todayStart);
// no-spend day(amount=0)도 예산 이하이므로 성공으로 계산한다
final weeklySuccessDays = isFutureWeek
    ? 0
    : dailyStats.where((s) => s.amount <= dailyBudget).length;
```

- [ ] **Step 4: 분석 통과 확인**

```bash
flutter analyze lib/features/stats/presentation/viewmodels/stats_view_model.dart
```

Expected: No issues

- [ ] **Step 5: 전체 stats 테스트 통과 확인**

```bash
flutter test test/features/stats/
```

Expected: 모든 테스트 PASS

- [ ] **Step 6: 커밋**

```bash
git add lib/features/stats/presentation/viewmodels/stats_view_model.dart \
        test/features/stats/presentation/viewmodels/stats_view_model_test.dart
git commit -m "fix(stats): weeklySuccessDays — no-spend day 포함 계산으로 교체"
```

---

## Task 4: 전체 검증

- [ ] **Step 1: 전체 테스트 실행**

```bash
flutter test
```

Expected: 모든 테스트 PASS

- [ ] **Step 2: 정적 분석**

```bash
flutter analyze
```

Expected: No issues

- [ ] **Step 3: (선택) 시뮬레이터에서 주간 뷰 동작 확인**

```
flutter run
```

- 주간 뷰 → 지출 없는 날이 있는 주에서 성공일이 7/7로 표시되는지 확인
- 이른 아침 지출이 올바른 날짜 막대에 표시되는지 확인

---

## Self-Review

### Spec Coverage

| 버그 | 태스크 |
|------|--------|
| `getDailyAmountsForWeek` UTC 버킷팅 → Dart 로컬 정규화 | Task 1 |
| `getWeekdayStats` UTC 버킷팅 → Dart 로컬 정규화 | Task 2 |
| no-spend day 성공일 누락 → `dailyStats` 기반 계산 | Task 3 |

### Placeholder 점검
- 모든 step에 실제 코드 포함 ✓
- TBD/TODO 없음 ✓
- 타입 일관성: `DailyStat.amount: int`, `dailyBudget: int` (GetDailyBudgetUseCase 반환형) ✓

### 타입 일관성
- `dailyBudget`은 `GetDailyBudgetUseCase.execute()` → `int` 반환, `DailyStat.amount`도 `int` → `s.amount <= dailyBudget` 비교 타입 일치 ✓
- `WeekdayStat(weekday: int, avgAmount: int)` — Task 2 구현에서 동일하게 사용 ✓
