# 주간 캘린더 뷰 구현 계획서 — Gemini 검토 결과

> 검토일: 2026-04-07  
> 검토자: Gemini CLI  
> 대상 문서: `docs/plan_weekly_calendar.md`

---

## 1. 기술적 타당성 (Technical Feasibility)

**아키텍처 정렬**  
Clean Architecture와 MVVM 패턴을 잘 유지하고 있습니다. 특히 Domain/Data 레이어의 변경 없이 Presentation 레이어의 필터링만으로 주간 데이터를 처리하는 전략은 불필요한 레이어 확장을 방지하는 효율적인 접근입니다.

**상태 관리 (Riverpod)**  
`CalendarState`에 `viewMode`와 `selectedWeekStart`를 추가하는 방식은 타당하나, **프로젝트 표준인 `@freezed` 필수 적용**과 현재 `calendar_view_model.dart`의 수동 `copyWith` 구현 사이에 괴리가 있습니다. 이번 구현을 계기로 `@freezed` 도입을 권장합니다.

**데이터 효율성**  
Drift(SQLite)를 직접 호출하는 대신 기존의 월간 데이터 캐시(`_expenseCache`)를 재사용하는 점은 성능 면에서 매우 유리합니다.

---

## 2. 누락된 구현 고려사항 (Missing Considerations)

### 뷰 모드 유지 (Persistence)
사용자가 마지막으로 선택한 뷰 모드(월간 또는 주간)를 `SharedPreferences`에 저장하여, 앱 재진입 시 해당 모드를 유지하는 기능이 누락되어 있습니다.

```dart
// SharedPreferences에 viewMode 저장
await prefs.setString('calendar_view_mode', viewMode.name);

// 앱 재진입 시 복원
final saved = prefs.getString('calendar_view_mode');
final viewMode = CalendarViewMode.values.byName(saved ?? 'monthly');
```

### '오늘' 버튼 동작 정의 미흡
현재 계획서에는 언급되지 않았으나, 주간 뷰에서 '오늘' 버튼을 눌렀을 때 현재 주(Current Week)로 포커스를 이동하는 로직이 명시되어야 합니다.

### 캐시 동기화 확인 필요
주간 뷰에서 지출을 수정/삭제했을 때, 동일한 캐시를 공유하는 월간 뷰에도 실시간으로 반영되는지 확인이 필요합니다. Riverpod의 동일 Provider를 사용하는 경우 자동 해결되지만, 명시적 검증이 필요합니다.

### 성능 최적화 전략 부재
월간 ↔ 주간 전환 시 전체 그리드가 리빌드되므로, `RepaintBoundary` 사용이나 위젯의 `const` 최적화 전략이 필요합니다.

---

## 3. 리스크 평가 적절성 (Risk Assessment)

**코드 비대화 리스크 (High) — 적절히 평가됨**  
`calendar_screen.dart`가 이미 1,200줄을 초과했다는 점을 정확히 짚어냈습니다. 이는 가독성뿐 아니라 협업 시 충돌 위험을 높이므로 **구현 전 리팩토링 필수**입니다.

**월 경계 데이터 로딩 (High) — 적절히 평가됨**  
주간 뷰가 두 달에 걸치는 경우(예: 3/29~4/4) 양쪽 월 데이터를 병합하는 로직은 복잡도가 높으며, 캐시 미스 시 비동기 로딩 순서에 따른 UI 깜빡임 리스크가 존재합니다.

**제스처 충돌 (Medium) — 해결책 보완 필요**  
계획서에 리스크는 언급되어 있으나, 구체적인 해결책(예: `AbsorbPointer`나 `IgnorePointer` 활용, `Listener`로 원시 터치 이벤트 처리)이 보완되면 좋겠습니다.

**추가 리스크: 연도 경계**  
12/29 ~ 1/4 같은 연도 경계 케이스는 리스크 항목에 포함되어 있으나, `_cacheKey(year, month)` 패턴이 연도를 올바르게 구분하는지 단위 테스트 추가가 필요합니다.

---

## 4. 수용 기준 완성도 (Acceptance Criteria)

**보완 필요 항목:**

| 항목 | 현황 | 개선 제안 |
|------|------|----------|
| 접근성(A11y) | Semantics 라벨 언급만 있음 | 보이스오버에서 날짜 셀 간 이동 순서, 요약 정보 읽기 순서 기준 추가 |
| 테스트 자동화 | "기존 기능 퇴행 없음"만 명시 | 신규 기능 위젯 테스트 + 주간 데이터 계산 단위 테스트 코드 작성을 수용 기준에 명시 |
| 성능 기준 | 없음 | "주간/월간 전환 16ms 이내 (60fps 유지)" 등 정량 기준 추가 권장 |
| 뷰 모드 유지 | 없음 | "앱 재진입 시 마지막 선택 뷰 모드 복원" 항목 추가 |

---

## 5. 개선 제안 (Improvement Suggestions)

### 제안 1: Phase 0 — 리팩토링 선행 (강력 권장)
주간 기능 개발 전, `calendar_screen.dart` 내의 `_SlidingCalendarGrid`, `_MonthNavigator`, `_CalendarGrid`를 별도 위젯 파일로 분리하는 작업을 **별도 Phase 0**으로 정의할 것을 강력히 권장합니다.

```
lib/features/calendar/presentation/
  widgets/
    sliding_calendar_grid.dart    ← _SlidingCalendarGrid 분리
    month_navigator.dart          ← _MonthNavigator 분리
    calendar_grid.dart            ← _CalendarGrid 분리
    view_mode_toggle.dart         ← 신규
    weekly_summary_header.dart    ← 신규
    weekly_calendar_day_cell.dart ← 신규
```

### 제안 2: CalendarState @freezed 현대화
프로젝트 표준인 `@freezed`와 `riverpod_generator`를 사용하여 `CalendarState`와 `CalendarViewModel`을 현대화하십시오.

```dart
@freezed
class CalendarState with _$CalendarState {
  const factory CalendarState({
    @Default(CalendarViewMode.monthly) CalendarViewMode viewMode,
    required DateTime selectedMonth,
    DateTime? selectedDate,
    DateTime? selectedWeekStart,
    @Default({}) Map<DateTime, List<ExpenseEntity>> monthlyExpenses,
    // ...
  }) = _CalendarState;
}
```

### 제안 3: 도토리 아이콘 애니메이션
도토리 아이콘(`🌰`) 표시 시 `flutter_animate`를 활용한 간단한 팝업 효과를 추가하여 "절약 성공"에 대한 시각적 보상을 강화할 것을 제안합니다.

```dart
Text('🌰').animate().scale(
  begin: const Offset(0.5, 0.5),
  duration: 300.ms,
  curve: Curves.elasticOut,
);
```

### 제안 4: 주간 데이터 계산 단위 테스트 추가
`weekStartOf()`, `getWeeklySummary()` 함수는 순수 함수이므로 단위 테스트 작성이 용이합니다. 월 경계, 연도 경계 케이스를 포함한 테스트를 구현 전 작성(TDD)할 것을 권장합니다.

```dart
// test/features/calendar/utils/week_utils_test.dart
test('12월 마지막 주 (12/29~1/4) 연도 경계 처리', () {
  final weekStart = weekStartOf(DateTime(2026, 12, 31));
  expect(weekStart, DateTime(2026, 12, 27)); // 일요일 기준
});
```

---

## 종합 평가

| 항목 | 점수 | 비고 |
|------|------|------|
| 기술적 타당성 | ★★★★☆ | 아키텍처 방향 적절, @freezed 도입 권장 |
| 구현 완성도 | ★★★☆☆ | 뷰 모드 유지, 성능 기준 등 보완 필요 |
| 리스크 관리 | ★★★★☆ | 주요 리스크 식별 양호, 제스처 해결책 보완 필요 |
| 수용 기준 | ★★★☆☆ | 테스트 자동화, 성능 기준 명시 필요 |
| **종합** | **★★★★☆** | **Phase 0 리팩토링 후 구현 진행 권장** |

**결론:** 계획서의 전반적인 방향성과 기술 분석은 우수합니다. `calendar_screen.dart` 리팩토링을 Phase 0으로 선행하고, `@freezed` 도입과 테스트 자동화 기준을 보강한 뒤 구현에 착수하면 품질 높은 결과물을 기대할 수 있습니다.
