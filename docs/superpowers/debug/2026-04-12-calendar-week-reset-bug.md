# 캘린더 주간 버그 디버깅 현황

**날짜:** 2026-04-12  
**상태:** Phase 1 조사 중 (중단)

---

## 보고된 이슈

### 이슈 1 — 주 시작일 오류
한 주의 시작은 **일요일**이어야 한다 (일 ~ 토 = 1주).  
현재 UI가 이 기준을 제대로 따르지 않는 것으로 의심됨.

### 이슈 2 — 주 전환 시 캘린더 데이터 리셋
새 주로 넘어갈 때 이전에 작성된 기록이 모두 초기화되어 보이는 현상.

---

## Phase 1: 조사 결과 (현재까지)

### 읽은 파일

#### `lib/core/utils/app_date_utils.dart`

```dart
/// 주어진 날짜가 속한 주의 시작일(일요일)을 반환한다
static DateTime weekStartOf(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday % 7));
}
```

**분석:**  
`DateTime.weekday` 반환값: 월=1, 화=2, …, 토=6, **일=7**  
`weekday % 7`: 월=1, 화=2, …, 토=6, **일=0**  
→ 일요일에서 0일 빼기 = 일요일 자신 ✅  
→ 토요일에서 6일 빼기 = 해당 주 일요일 ✅  
→ **`weekStartOf` 로직 자체는 정확함**

```dart
/// 주간 뷰에 표시할 7일 리스트 (일요일 시작)
static List<DateTime> weekDaysFrom(DateTime weekStart) {
  return List.generate(7, (i) => weekStart.add(Duration(days: i)));
}
```
→ weekStart가 올바르면 7일 리스트도 정상

---

#### `lib/features/calendar/presentation/viewmodels/calendar_view_model.dart`

**`build()` 메서드:**
```dart
@override
CalendarState build() {
  // invalidate 재호출 시 stale 캐시가 남지 않도록 항상 초기화
  _expenseCache.clear();
  _baseAmountCache.clear();
  _effectiveBudgetCache.clear();
  _selectedDateCache.clear();
  _cachedStreak = null;
  _cachedSuccessCount = null;
  _inFlightLoads.clear();
  ...
}
```

> ⚠️ **주목:** `build()`가 호출될 때마다 **모든 캐시가 clear됨**.  
> `build()`가 새 주가 시작될 때 재호출된다면 → 이슈 2의 원인일 수 있음.

**`changeWeek()` 메서드:**
```dart
Future<void> changeWeek(int delta) async {
  final newWeekStart = state.selectedWeekStart.add(Duration(days: delta * 7));
  final weekEnd = newWeekStart.add(const Duration(days: 6));
  ...
  state = state.copyWith(
    selectedWeekStart: newWeekStart,
    selectedDate: newWeekStart,  // ← 주 시작일을 선택일로 설정
  );
}
```

> ⚠️ **주목:** 주 이동 시 `selectedDate`가 `newWeekStart`(일요일)로 설정됨.  
> `selectedDate`가 월 경계를 넘는 경우, `selectedMonth`는 갱신되지 않음.  
> `state.selectedMonth`와 `selectedDate`의 월이 불일치할 수 있음 → 데이터 로드 기준 혼선 가능성.

---

## 미조사 항목 (다음 세션에서 계속)

아래 파일들을 아직 읽지 못했음:

- [ ] `lib/features/calendar/presentation/screens/calendar_screen.dart`  
  → `calendarViewModelProvider`가 언제 invalidate되는지 확인 필요  
  → 앱 생명주기(foreground 복귀)와 연결된 invalidate 트리거 확인 필요

- [ ] `lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart`  
  → `_buildWeekRow` 내 데이터 조회 로직 재검토 (월 경계 주 처리)

- [ ] `lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart`  
  → 월간 뷰와 비교 분석

---

## 현재 가설 (미확인)

### 가설 A — `build()` 재호출이 이슈 2의 원인
`CalendarViewModel.build()`가 특정 조건(앱 재시작, 탭 이동 등)에서  
재호출되어 캐시 전체가 초기화되고, 로딩 완료 전에 UI가 빈 상태로 표시됨.  
→ **확인 필요:** `calendar_screen.dart`에서 `ref.watch` 또는 `ref.invalidate` 호출 위치.

### 가설 B — `changeWeek()` 후 `selectedMonth` 불일치
주 이동 시 `selectedDate`만 갱신되고 `selectedMonth`는 그대로여서  
월 경계 주(예: 3월 말 ~ 4월 초)에서 데이터가 올바른 캐시 키로 조회되지 않음.

### 가설 C — 이슈 1이 사실은 없는 문제 (코드는 정확)
`weekStartOf`는 이미 일요일 시작으로 계산함.  
실제로는 UI 표시 순서 또는 레이블 문제일 수 있음.  
→ **확인 필요:** 주간 헤더/요일 순서 렌더링 코드.

---

## 다음 단계

1. `calendar_screen.dart` 읽어서 `build()` 재호출 트리거 파악
2. `changeWeek()` 후 `selectedMonth` 처리 흐름 추적
3. 가설 A 또는 B 중 하나를 특정한 뒤 Phase 3(가설 검증)으로 진행
