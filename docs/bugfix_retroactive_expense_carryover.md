# 버그 분석 & 수정 계획 — 과거 지출 소급 입력 시 이월 금액 미반영

> Codex 리뷰(2026-04-28) 반영 완료

---

## 재현 조건

- 일일 예산: 20,000원
- 이월(carryover) 기능 활성화
- 기준 주: 일 ~ 토, 오늘 = **화요일**
- 일·월요일 지출: 0원으로 앱 사용
- **화요일에** 일요일 지출 5,000원 소급 입력

### 기대 동작

| 날짜 | baseAmount | 실제 지출 | carryOver | effectiveBudget |
|------|-----------|----------|-----------|-----------------|
| 일요일 | 20,000 | 5,000 | 0 (주 시작) | 20,000 |
| 월요일 | 20,000 | 0 | **15,000** | 35,000 |
| 화요일 | 20,000 | 0 | **35,000** | 55,000 |

### 실제 동작 (버그)

| 날짜 | DB 저장 carryOver | effectiveBudget |
|------|-----------------|-----------------|
| 월요일 | 20,000 (stale) | 40,000 ← 틀림 |
| 화요일 | 40,000 (stale) | 60,000 ← 틀림 |

---

## 음수 carryOver 정책

**음수 carryOver는 그대로 이월한다. clamp(최솟값 0) 처리를 하지 않는다.**

예산을 초과 지출한 날의 경우:

| 날짜 | baseAmount | 실제 지출 | carryOver | effectiveBudget |
|------|-----------|----------|-----------|-----------------|
| 일요일 | 20,000 | 25,000 | 0 (주 시작) | 20,000 |
| 월요일 | 20,000 | 0 | **-5,000** | 15,000 |
| 화요일 | 20,000 | 0 | **15,000** | 35,000 |

초과 지출한 금액만큼 다음 날 예산이 줄어드는 것이 의도된 설계다.
`_syncWeeklyCarryOvers()`와 `_computeTodayCarryOver()`는 음수를 그대로 전파한다.

---

## 근본 원인 — 두 가지 결함이 결합

### Bug A — 핵심 로직: 중간 날짜 row의 carryOver가 소급 수정 후 보정되지 않음

**위치:** `lib/features/home/domain/usecases/get_today_budget_use_case.dart:62-72`

```dart
// 현재 코드
Future<int> _computeTodayCarryOver() async {
  final yesterday = today.subtract(const Duration(days: 1));
  final yesterdayBudget = await _repository.getBudgetByDate(yesterday);
  final yesterdaySpent = await _repository.getTotalExpensesByDate(yesterday);
  return yesterdayBudget.effectiveBudget - yesterdaySpent;
  //          ↑ baseAmount + storedCarryOver — 소급 입력 이후에도 그대로
}
```

`yesterdayBudget.effectiveBudget`은 `baseAmount + storedCarryOver`를 반환한다.
월요일 row의 `storedCarryOver`는 **월요일 최초 생성 시점** (일요일 지출 0원 기준)에 저장된 20,000원이며,
이후 일요일에 5,000원이 소급 입력되어도 **업데이트되지 않는다.**

진짜 근본 원인은 `_computeTodayCarryOver()` 단독이 아니라, **과거 일자 budget row가 최초 생성 후 다시 보정되지 않는 구조** 전체다.
`_fillMissingDays()`는 당시 시점의 `prevSpent`로 carryOver를 저장하고,
`getOrCreateBudgetForDate()`는 row가 이미 있으면 그대로 반환하므로 중간 row는 영원히 stale 상태로 남는다.

```
_computeTodayCarryOver() 실행 시 (today = 화요일):
  월요일 DB row = {baseAmount: 20000, carryOver: 20000}  ← stale
  effectiveBudget = 20000 + 20000 = 40000               ← 틀림
  yesterdaySpent = 0
  return 40000                                           ← 정답은 35000
```

### Bug B — 트리거 결함: 과거 지출 추가 후 홈 재계산이 발생하지 않음

**위치:** `lib/features/expense/presentation/viewmodels/expense_add_view_model.dart:120-127`

`ExpenseAddViewModel.save()`는 `AddExpenseUseCase.execute()`만 호출하고 끝난다.
`HomeViewModel._loadData()`를 재실행시킬 신호가 없다.

```
HomeViewModel._watchExpenses()
  → watchExpensesByDate(DateTime.now())  // 오늘(화요일) 스트림만 감시
  → 일요일 지출 추가 → 오늘 스트림 미발화
  → _loadData() 호출 없음
  → 홈 화면 carryOver 표시 변화 없음

budgetChangeProvider
  → 설정 화면 예산 금액 변경 시만 increment
  → 지출 추가·수정·삭제 시 미동작
```

> Bug A만 고쳐도 `_loadData()`가 호출되지 않으므로 화면에 반영되지 않는다.
> Bug B만 고쳐도 `_computeTodayCarryOver()`가 stale 값을 읽으므로 계산이 틀린다.
> **두 버그를 모두 수정해야 한다.**

---

## 수정 계획

### Fix 1 — Bug A: 주간 carryOver 동기화

`getOrCreateTodayBudget()` 내에 `_syncWeeklyCarryOvers()` 호출을 추가한다.

#### `_syncWeeklyCarryOvers()` 동작 (순차 반복, 저장값 미신뢰)

```
weekStart = 일요일 (carryOver 항상 0)
cursor = 월요일 (weekStart + 1일)

iteration (today = 화요일, 어제 = 월요일까지 반복):
  prev = 일요일
  prevBudget.baseAmount = 20000
  runningCarryOver = 0  // 일요일 고정값
  prevEffective = 20000 + 0 = 20000
  prevSpent = 5000 (소급 입력된 실제 값)
  newCarryOver = 15000  // 음수여도 그대로 전파
  → 월요일 DB carryOver 20000 → 15000 업데이트 ✓

_computeTodayCarryOver() 재실행:
  월요일 DB row = {baseAmount: 20000, carryOver: 15000}  // 이제 정확
  effectiveBudget = 35000
  yesterdaySpent = 0
  return 35000 ✓
```

**핵심:** 반복 시 `storedCarryOver`를 읽지 않고, 앞 iteration에서 계산한 `runningCarryOver`를 누적해 순방향으로 chain을 재구성한다. 음수 값도 `max(0, ...)` 없이 그대로 전파한다.

#### 필요한 추가 메서드

`DailyBudgetRepository` (인터페이스 & 구현체):
```dart
Future<void> updateCarryOverForDate(DateTime date, int carryOver);
```

`DailyBudgetLocalDatasource` 구현:
```dart
Future<void> updateCarryOverForDate(DateTime date, int carryOver) async {
  final existing = await getBudgetByDate(date);
  if (existing == null) return;
  await (_db.update(_db.dailyBudgets)
        ..where((t) => t.id.equals(existing.id)))
      .write(DailyBudgetsCompanion(carryOver: Value(carryOver)));
}
```

#### `get_today_budget_use_case.dart` 변경 요약

```dart
Future<DailyBudgetEntity> getOrCreateTodayBudget() async {
  await _fillMissingDays();
  await _syncWeeklyCarryOvers();          // ← 추가
  final carryOver = await _computeTodayCarryOver();
  return _repository.getOrCreateTodayBudget(carryOver: carryOver);
}

Future<void> _syncWeeklyCarryOvers() async {
  final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
  if (!carryoverEnabled) return;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final weekStart = AppDateUtils.weekStartOf(today);

  // 일요일(주 시작) carryOver = 0 고정
  // 월요일 ~ 어제까지 순방향으로 재계산
  var cursor = weekStart.add(const Duration(days: 1));
  int runningCarryOver = 0;

  while (cursor.isBefore(todayDate)) {
    final prev = cursor.subtract(const Duration(days: 1));
    final prevBudget = await _repository.getBudgetByDate(prev);
    if (prevBudget == null) break;

    final prevEffective = prevBudget.baseAmount + runningCarryOver;
    final prevSpent = await _repository.getTotalExpensesByDate(prev);
    final newCarryOver = prevEffective - prevSpent; // 음수 clamp 없음 — 정책상 의도된 설계

    final cursorBudget = await _repository.getBudgetByDate(cursor);
    if (cursorBudget != null && cursorBudget.carryOver != newCarryOver) {
      await _repository.updateCarryOverForDate(cursor, newCarryOver);
    }

    runningCarryOver = newCarryOver;
    cursor = cursor.add(const Duration(days: 1));
  }
}
```

---

### Fix 2 — Bug B: 과거 지출 변경 후 홈·캘린더·통계 재계산 트리거

**위치:** `lib/features/expense/presentation/viewmodels/expense_add_view_model.dart`

#### `budgetChangeProvider` 의미 범위 확장

기존에는 설정 화면의 일일 예산 금액 변경 시만 increment 했다.
이번 수정으로 **"이월에 영향을 주는 모든 변경"** (과거 지출 추가·수정·삭제 포함)으로 역할을 확장한다.

`budgetChangeProvider` increment 시 세 화면이 모두 갱신된다:
- `HomeViewModel.ref.listen(budgetChangeProvider)` → `_loadData()` → `_syncWeeklyCarryOvers()` → DB carryOver 보정 → 홈 화면 정상 반영
- `CalendarViewModel.ref.listen(budgetChangeProvider)` → `loadMonthData(forceRefresh: true)` → DB에서 갱신된 `carryOver` 반영 → 캘린더 정상 반영
- `StatsViewModel.ref.listen(budgetChangeProvider)` → 통계 정상 반영

Fix 1에서 DB carryOver를 먼저 보정하기 때문에, 캘린더와 통계가 DB를 직접 읽어도 정확한 값을 얻게 된다.

#### `save()` 및 `delete()` 변경

```dart
// save() 성공 시
if (result.isSuccess) {
  if (!AppDateUtils.isSameDay(state.saveCreatedAt, DateTime.now())) {
    ref.read(budgetChangeProvider.notifier).increment();  // ← 추가
  }
  if (state.addToFavorite) { ... }
}

// delete() — state.recordDate 활용 (날짜 인자 추가 불필요)
Future<void> delete(int id) async {
  await getIt<DeleteExpenseUseCase>().execute(id);
  if (!AppDateUtils.isSameDay(state.recordDate, DateTime.now())) {
    ref.read(budgetChangeProvider.notifier).increment();  // ← 추가
  }
}
```

#### 알려진 한계 — 지출 변경 경로 다중 존재

`ExpenseAddViewModel` 외에도 지출 변경이 발생하는 경로가 있다:
- `HomeViewModel.deleteExpense()` — 홈 화면 스와이프 삭제 (오늘 날짜만 해당, 현재는 문제 없음)
- `widget_background_callback.dart` — 위젯 버튼 탭 즉시 저장 (오늘 날짜만 해당, 현재는 문제 없음)

현재 두 경로 모두 오늘 날짜 지출만 다루므로 즉각적 버그는 없다.
향후 과거 날짜 지출을 다른 경로에서 변경하는 기능이 추가될 경우, 해당 경로에도 동일한 트리거를 추가해야 한다.

---

## 수정 파일 목록

| # | 파일 | 변경 내용 |
|---|------|-----------|
| 1 | `lib/features/home/domain/repositories/daily_budget_repository.dart` | `updateCarryOverForDate` 인터페이스 추가 |
| 2 | `lib/features/home/data/datasources/daily_budget_local_datasource.dart` | `updateCarryOverForDate` Drift 구현 |
| 3 | `lib/features/home/data/repositories/daily_budget_repository_impl.dart` | `updateCarryOverForDate` 위임 |
| 4 | `lib/features/home/domain/usecases/get_today_budget_use_case.dart` | `_syncWeeklyCarryOvers()` 추가 + `getOrCreateTodayBudget()`에서 호출 |
| 5 | `lib/features/expense/presentation/viewmodels/expense_add_view_model.dart` | 과거 날짜 save·delete 후 `budgetChangeProvider.increment()` |

---

## 수정 후 데이터 플로우

```
사용자: 화요일에 일요일 지출 5,000원 소급 입력
  │
  ▼
ExpenseAddViewModel.save()
  ├── AddExpenseUseCase.execute()  → DB expenses 저장
  └── !isSameDay(일요일, 화요일) → budgetChangeProvider.increment()  [Fix 2]
  │
  ▼
HomeViewModel / CalendarViewModel / StatsViewModel
  모두 ref.listen(budgetChangeProvider) 발화
  │
  ▼
GetTodayBudgetUseCase.getOrCreateTodayBudget()
  ├── _fillMissingDays()
  ├── _syncWeeklyCarryOvers()  [Fix 1]
  │     └── 월요일 carryOver: 20000 → 15000 업데이트 (DB 보정)
  └── _computeTodayCarryOver()
        └── 월요일 effectiveBudget = 20000 + 15000 = 35000
        └── return 35000 ✓
  │
  ▼
state.carryOver = 35000 (화요일 기준 — 오늘의 이월 금액)
state.totalBudget = 55000 (화요일 effectiveBudget)
홈·캘린더·통계 화면 정상 반영 ✓
```

---

## 알려진 한계 (이번 수정 범위 외)

| 항목 | 내용 |
|------|------|
| `carryoverEnabled` 이력 미보존 | 주중에 이월 기능을 껐다 켰을 경우, "당시 설정"이 아닌 "현재 설정"으로 과거 row를 재계산함. 설정 이력을 DB에 저장하지 않는 한 정확한 재현 불가. |
| 이월 토글 즉시 반영 누락 | `setCarryoverEnabled()` 저장 후 `budgetChangeProvider.increment()`를 호출하지 않아 홈 화면이 즉시 갱신되지 않음. 별도 버그로 관리 필요. |
