# 주간 캘린더 뷰 구현 계획서

> 작성일: 2026-04-07
> 상태: DRAFT

---

## 1. 기능 개요

### 목표

현재 월간(Monthly) 전용인 캘린더 화면에 **주간(Weekly) 뷰**를 추가하여, 사용자가 이번 주 지출 현황을 한눈에 파악하고 절약 동기를 강화할 수 있도록 한다.

### 사용자 가치

| 가치 | 설명 |
|------|------|
| **빠른 현황 파악** | 7일 단위로 지출 흐름을 즉시 확인 — 월간 뷰보다 집중도 높음 |
| **절약 강화** | 빈 날짜에 도토리 아이콘을 표시하여 "안 쓴 날"을 보상처럼 인식 |
| **주간 예산 인사이트** | 총지출, 일평균, 절약일 수를 헤더에 요약 — 숫자가 감정을 표현하는 앱 철학과 부합 |

### 성공 기준

- 월간/주간 탭 토글이 자연스럽게 전환된다 (300ms 이내 애니메이션)
- 주간 뷰에서 좌우 스와이프로 이전/다음 주 이동이 가능하다
- 주간 요약 헤더에 총지출, 일평균, 절약일 수가 정확히 표시된다
- 지출 없는 날에 도토리 아이콘이 렌더링된다
- Light + Dark 모드 모두 정상 동작한다
- 기존 월간 뷰 기능이 퇴행(regression) 없이 유지된다

---

## 2. 기술 분석

### 2.1 현재 구조 재활용 방안

| 기존 컴포넌트 | 재활용 방식 |
|--------------|------------|
| `CalendarViewModel` + `CalendarState` | 상태에 `viewMode`(monthly/weekly), `selectedWeekStart` 필드 추가. 기존 `monthlyExpenses` 캐시를 그대로 활용하여 주간 데이터 추출 |
| `_WeekdayHeader` | 주간/월간 공용 — 변경 불필요 |
| `CalendarDayCell` | 주간 뷰에서도 동일하게 사용. 도토리 아이콘 표시를 위해 `isSuccess == null && !isFuture` 조건 분기만 추가 |
| `DailyExpenseDetail` | 날짜 선택 시 하단 지출 패널 — 변경 불필요 |
| `CalendarRepository` / `CalendarLocalDatasource` | 기존 `getMonthlyExpenses`로 월 데이터를 가져온 뒤 주간 범위 필터링. **새 쿼리 불필요** |
| `GetMonthlyCalendarDataUseCase` | 주간 요약 계산 로직을 UseCase에 추가하거나, ViewModel에서 캐시 데이터로 직접 계산 |

### 2.2 새로 추가할 컴포넌트

| 컴포넌트 | 위치 | 역할 |
|---------|------|------|
| `CalendarViewMode` enum | `presentation/viewmodels/calendar_view_model.dart` | `monthly` / `weekly` 뷰 모드 구분 |
| `_ViewModeToggle` 위젯 | `presentation/widgets/view_mode_toggle.dart` | 월간/주간 탭 토글 UI (SegmentedButton 또는 커스텀 탭) |
| `_WeeklySummaryHeader` 위젯 | `presentation/widgets/weekly_summary_header.dart` | 이번 주 총지출, 일평균, 절약일 수 표시 |
| `_SlidingWeeklyGrid` 위젯 | `presentation/screens/calendar_screen.dart` 내부 또는 별도 파일 | 7일 가로 레이아웃 + 좌우 스와이프 (기존 `_SlidingCalendarGrid` 패턴 재사용) |
| `WeeklyCalendarDayCell` 위젯 | `presentation/widgets/weekly_calendar_day_cell.dart` | 주간 뷰 전용 셀 (더 큰 크기, 도토리 아이콘, 지출 금액 텍스트 포함) |

### 2.3 주간 날짜 계산 전략

```dart
/// 주어진 날짜가 속한 주의 시작일(일요일)을 반환한다
DateTime weekStartOf(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday % 7));
}

/// 주간 뷰에 표시할 7일 리스트
List<DateTime> weekDaysFrom(DateTime weekStart) {
  return List.generate(7, (i) => weekStart.add(Duration(days: i)));
}
```

> 일요일 시작 기준 (기존 `_WeekdayHeader`의 `['일', '월', '화', '수', '목', '금', '토']`와 일치)

### 2.4 주간 요약 데이터 계산

```dart
/// 주간 요약 — ViewModel 내 계산 (별도 쿼리 불필요)
({int totalSpent, int dailyAverage, int savingDays}) getWeeklySummary(
  List<DateTime> weekDays,
  Map<DateTime, List<ExpenseEntity>> monthlyExpenses,
) {
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int totalSpent = 0;
  int savingDays = 0;
  int countedDays = 0;

  for (final day in weekDays) {
    if (day.isAfter(today)) continue; // 미래 날짜 제외
    countedDays++;
    final expenses = monthlyExpenses[day] ?? [];
    final dayTotal = expenses.fold<int>(0, (sum, e) => sum + e.amount);
    totalSpent += dayTotal;
    if (dayTotal <= AppConstants.dailyBudget) savingDays++;
  }

  return (
    totalSpent: totalSpent,
    dailyAverage: countedDays > 0 ? totalSpent ~/ countedDays : 0,
    savingDays: savingDays,
  );
}
```

---

## 3. 구현 범위

### Domain 레이어 — 변경 없음

기존 `CalendarRepository`, `CalendarLocalDatasource`, `GetMonthlyCalendarDataUseCase`는 월 단위 데이터를 이미 제공하므로 주간 필터링은 Presentation 레이어에서 처리한다. Domain/Data 변경 불필요.

### Presentation 레이어 — 변경/추가 파일 목록

| 파일 | 작업 | 상세 |
|------|------|------|
| `viewmodels/calendar_view_model.dart` | **수정** | `CalendarState`에 `viewMode`, `selectedWeekStart` 추가. `changeWeek(delta)`, `toggleViewMode()`, `getWeeklySummary()` 메서드 추가 |
| `screens/calendar_screen.dart` | **수정** | 뷰 모드에 따라 월간/주간 그리드 분기. `_SlidingWeeklyGrid` 추가. `_ViewModeToggle` 배치 |
| `widgets/view_mode_toggle.dart` | **신규** | 월간/주간 세그먼트 토글 위젯 |
| `widgets/weekly_summary_header.dart` | **신규** | 주간 요약 헤더 (총지출, 일평균, 절약일) |
| `widgets/weekly_calendar_day_cell.dart` | **신규** | 주간 셀 — 도토리 아이콘, 지출 금액, 성공/실패 색상 |

### Core 레이어 — 선택적 변경

| 파일 | 작업 | 상세 |
|------|------|------|
| `core/utils/app_date_utils.dart` | **수정 (선택)** | `weekStartOf()`, `weekDaysFrom()` 유틸리티 함수 추가 (여러 곳에서 재사용 가능) |

---

## 4. 구현 단계

### Phase 1: 상태 모델 확장 + 뷰 모드 토글 (의존성: 없음)

**목표:** 월간/주간 전환 인프라 구축

1. **`CalendarState` 확장**
   - `CalendarViewMode` enum 추가: `monthly`, `weekly`
   - `CalendarState`에 `viewMode` 필드 추가 (기본값: `monthly`)
   - `selectedWeekStart` 필드 추가 (현재 주의 일요일 날짜)
   - `copyWith`에 해당 필드 반영

   ```dart
   enum CalendarViewMode { monthly, weekly }

   class CalendarState {
     final CalendarViewMode viewMode;
     final DateTime selectedWeekStart;
     // ... 기존 필드 유지
   }
   ```

2. **`CalendarViewModel` 메서드 추가**
   - `toggleViewMode()`: monthly <-> weekly 전환. weekly로 전환 시 `selectedDate` 기준으로 `selectedWeekStart` 자동 계산
   - `changeWeek(int delta)`: 주 단위 이동 (delta * 7일). 월 경계를 넘으면 해당 월 데이터 로드
   - `getWeeklySummary()`: 현재 주의 지출 요약 계산 (캐시 데이터 활용)

3. **`ViewModeToggle` 위젯 생성**
   - `AppColors` 토큰 사용, Light/Dark 대응
   - 선택된 모드에 `AppColors.primary` 배경 + 전환 애니메이션
   - 터치 영역 48x48dp 이상 확보

   ```dart
   class ViewModeToggle extends StatelessWidget {
     final CalendarViewMode mode;
     final ValueChanged<CalendarViewMode> onChanged;
     // ...
   }
   ```

**수용 기준:**
- [ ] 토글 탭 클릭 시 `viewMode` 상태가 정확히 전환된다
- [ ] 월간 -> 주간 전환 시 `selectedWeekStart`가 현재 선택 날짜 기준으로 올바르게 계산된다
- [ ] 주간 -> 월간 전환 시 기존 월간 뷰 상태가 정확히 복원된다

---

### Phase 2: 주간 캘린더 그리드 + 스와이프 (의존성: Phase 1)

**목표:** 7일 가로 레이아웃 + 좌우 스와이프 이동

1. **`WeeklyCalendarDayCell` 위젯 생성**
   - 기존 `CalendarDayCell`보다 큰 셀 (가로 전체를 7등분)
   - 상단: 날짜 숫자 (원형 배경, 오늘/선택 강조)
   - 중단: 지출 금액 텍스트 (있을 경우) 또는 도토리 아이콘 (지출 없는 과거 날짜)
   - 하단: 성공/실패 색상 바 또는 dot
   - 도토리 아이콘: `🌰` 이모지 또는 커스텀 아이콘 (앱의 도토리 보상 시스템과 일관)

   ```dart
   class WeeklyCalendarDayCell extends StatelessWidget {
     final DateTime date;
     final bool isToday;
     final bool isSelected;
     final bool isFuture;
     final bool? isSuccess;
     final int? totalAmount;       // 해당일 총 지출액
     final bool showAcornIcon;     // 지출 없는 과거 날짜 = true
     final VoidCallback? onTap;
   }
   ```

2. **`_SlidingWeeklyGrid` 위젯 생성**
   - 기존 `_SlidingCalendarGrid`의 드래그/스냅 패턴 재사용
   - +-1주 프리렌더링 (3주분 가로 배치)
   - `GestureDetector` + `AnimationController` 동일 구조
   - 높이: 셀 1행 + 요약 헤더 높이

   ```dart
   class _SlidingWeeklyGrid extends ConsumerStatefulWidget {
     final CalendarState state;
     final void Function(int delta) onWeekChange;
     final bool isDark;
     final void Function(DateTime) onDateSelected;
     // ... 기존 _SlidingCalendarGrid와 동일한 드래그/스냅 로직
   }
   ```

3. **`CalendarScreen` 분기 처리**
   - `state.viewMode`에 따라 `_SlidingCalendarGrid` 또는 `_SlidingWeeklyGrid` 렌더링
   - `_MonthNavigator` 위에 `ViewModeToggle` 배치
   - 주간 모드일 때 네비게이터 레이블: "2026. 04. 01 ~ 04. 07" 형식

**수용 기준:**
- [ ] 주간 뷰에서 7일이 가로로 균등 배치된다
- [ ] 좌우 스와이프로 이전/다음 주 이동이 부드럽게 동작한다
- [ ] 월 경계를 넘는 주 이동 시 해당 월 데이터가 자동 로드된다
- [ ] 날짜 셀 탭 시 `DailyExpenseDetail` 패널이 정상 표시된다
- [ ] 지출 없는 과거 날짜에 도토리 아이콘이 표시된다

---

### Phase 3: 주간 요약 헤더 + 마감 처리 (의존성: Phase 2)

**목표:** 주간 예산 인사이트 표시 + 엣지케이스 처리

1. **`WeeklySummaryHeader` 위젯 생성**
   - 3개 지표: 이번 주 총지출, 일평균 지출, 절약일 수
   - 숫자 감정 색상 적용 (주간 총지출 기준):
     - 총지출 <= 50,000원: `AppColors.statusComfortable` (comfortable)
     - 총지출 <= 70,000원: `AppColors.statusWarning` (warning)
     - 총지출 > 70,000원: `AppColors.statusDanger` (danger)
   - Light/Dark 모드 대응, `AppTypography` 토큰 사용

   ```dart
   class WeeklySummaryHeader extends StatelessWidget {
     final int totalSpent;
     final int dailyAverage;
     final int savingDays;
     final int totalDays; // 집계 대상 날짜 수 (미래 제외)
   }
   ```

2. **월-주 경계 데이터 처리**
   - 주간이 두 달에 걸치는 경우 (예: 3/29 ~ 4/4), 양쪽 월 데이터를 모두 참조
   - `CalendarViewModel.changeWeek()`에서 필요한 월의 캐시 존재 여부 확인 후 누락 시 로드
   - 캐시 키 충돌 없이 양쪽 월 데이터 병합

   ```dart
   /// 주간이 걸치는 월들의 데이터를 병합하여 반환
   Map<DateTime, List<ExpenseEntity>> getWeekExpenses(DateTime weekStart) {
     final weekEnd = weekStart.add(const Duration(days: 6));
     final months = <String>{};
     months.add(_cacheKey(weekStart.year, weekStart.month));
     months.add(_cacheKey(weekEnd.year, weekEnd.month));

     final merged = <DateTime, List<ExpenseEntity>>{};
     for (final key in months) {
       final cached = _expenseCache[key];
       if (cached != null) merged.addAll(cached);
     }
     return merged;
   }
   ```

3. **애니메이션 + 전환 효과**
   - 월간 <-> 주간 전환 시 `AnimatedSwitcher` 또는 `AnimatedCrossFade` 적용
   - 주간 요약 헤더 숫자 변경 시 카운트업 애니메이션 (선택)
   - 전환 시간: 300ms, `Curves.easeInOut`

4. **접근성 + 엣지케이스**
   - Semantics 라벨: "주간 뷰, 4월 1일부터 4월 7일, 총지출 32,000원"
   - 빈 주 (지출 0건): "이번 주는 지출이 없어요" 메시지
   - 연초/연말 주 경계: 12/29 ~ 1/4 같은 연도 경계 케이스 처리
   - 데이터 로딩 중: 주간 요약 헤더에 shimmer/skeleton 표시

**수용 기준:**
- [ ] 주간 요약 헤더에 총지출, 일평균, 절약일 수가 정확히 표시된다
- [ ] 총지출 기준 숫자 감정 색상이 올바르게 적용된다
- [ ] 두 달에 걸치는 주에서 양쪽 월 데이터가 정확히 병합된다
- [ ] Light/Dark 모드에서 모든 위젯이 정상 렌더링된다
- [ ] 빈 주, 연도 경계 등 엣지케이스에서 크래시 없이 동작한다
- [ ] 접근성 라벨이 스크린 리더에서 정확히 읽힌다

---

## 5. 수용 기준 (Acceptance Criteria) — 전체 체크리스트

### 기능 요구사항

- [ ] 월간/주간 토글 탭이 캘린더 상단에 표시된다
- [ ] 주간 뷰: 7일이 가로 레이아웃으로 표시된다
- [ ] 각 날짜 셀에 지출 색상(성공/실패/미래)이 올바르게 표시된다
- [ ] 지출 없는 과거 날짜에 도토리 아이콘이 표시된다
- [ ] 주간 요약 헤더에 총지출, 일평균, 절약일 수가 표시된다
- [ ] 좌우 스와이프로 이전/다음 주 이동이 가능하다
- [ ] 날짜 셀 탭 시 하단에 `DailyExpenseDetail`이 표시된다
- [ ] 월간 뷰의 기존 기능이 모두 정상 동작한다 (regression 없음)

### 디자인/UX 요구사항

- [ ] `AppColors` 토큰만 사용 (하드코딩 금지)
- [ ] `AppTypography` 폰트 토큰 사용
- [ ] Light + Dark 모드 모두 정상 동작
- [ ] 터치 영역 최소 48x48dp 확보
- [ ] 전환 애니메이션 300ms 이내
- [ ] 한국어 UI 텍스트

### 코드 품질 요구사항

- [ ] 각 위젯 파일 300줄 이내
- [ ] Public 클래스/메서드에 `///` 문서 주석 작성
- [ ] 새로 추가한 위젯은 별도 파일로 분리 (100줄 이상 또는 재사용 시)
- [ ] `build_runner` 실행 후 생성 파일 정상 (CalendarState 변경 시 해당 없음 — freezed 미사용)

---

## 6. 리스크 및 주의사항

### 높은 리스크

| 리스크 | 영향 | 완화 방안 |
|--------|------|----------|
| **`calendar_screen.dart` 1212 LOC 초과** | 주간 위젯 추가 시 300줄 제한 위반 가능 | `_SlidingWeeklyGrid`를 별도 파일 `widgets/sliding_weekly_grid.dart`로 분리. 기존 `_SlidingCalendarGrid`도 분리 검토 |
| **월 경계 주간 데이터 누락** | 3/29~4/4 주에서 3월 데이터 미로드 시 빈 셀 표시 | `changeWeek()` 시 주의 시작/끝 월을 모두 확인하고 캐시 미스 시 로드 트리거 |

### 중간 리스크

| 리스크 | 영향 | 완화 방안 |
|--------|------|----------|
| **기존 드래그 로직과 충돌** | 월간 스와이프와 주간 스와이프의 방향이 같아 전환 시 상태 꼬임 가능 | `viewMode`에 따라 `GestureDetector`를 완전 분리. `AnimatedSwitcher`로 위젯 트리 교체 |
| **캐시 일관성** | 월간 뷰에서 캐시된 데이터와 주간 뷰 계산 결과 불일치 | 동일한 `_expenseCache`를 단일 소스로 사용. 주간 요약은 캐시 데이터에서 즉시 계산 |

### 낮은 리스크

| 리스크 | 영향 | 완화 방안 |
|--------|------|----------|
| **도토리 아이콘 디자인 미결정** | 이모지 vs 커스텀 아이콘 선택에 따라 UI 일관성 차이 | 1차: `🌰` 이모지 사용. 디자인 확정 후 커스텀 아이콘 교체 가능하도록 `Widget` 파라미터로 추상화 |
| **주간 예산 임계값 미확정** | 주간 총지출 기준 색상 경계값이 확정되지 않음 | `AppConstants`에 `weeklyBudget = dailyBudget * 7` 상수 추가, 추후 조정 가능 |

### 주의사항

1. **`calendar_screen.dart` 리팩토링 선행 권장** — 현재 1212줄로 이미 300줄 제한을 초과하고 있다. 주간 뷰 추가 전에 `_SlidingCalendarGrid`, `_MonthNavigator`, `_CalendarGrid`를 별도 위젯 파일로 추출하는 것이 안전하다.

2. **`build_runner` 실행 불필요** — `CalendarState`는 freezed가 아닌 수동 `copyWith`를 사용하므로 코드 생성 단계가 없다. 다만 DI 관련 변경이 있을 경우 실행 필요.

3. **기존 테스트 확인** — 캘린더 관련 기존 테스트가 있다면 주간 모드 추가 후 regression 테스트 필수.

4. **주간 시작 요일 통일** — 앱 전체에서 일요일 시작 기준을 사용 중이므로 (`_WeekdayHeader: ['일', '월', '화', '수', '목', '금', '토']`), 주간 뷰도 반드시 일요일 시작으로 구현해야 한다.
