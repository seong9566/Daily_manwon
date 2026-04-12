# 캘린더 셀 지출 금액 뱃지 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 캘린더 월간/주간 셀에서 `LinearProgressIndicator`(잔액 비율 바)를 제거하고, 당일 지출 합계를 mood 색상 기반의 컬러 뱃지(칩)로 대체한다.

**Architecture:** `CalendarAmountBadge` 공용 위젯을 새로 추출하여 `CalendarDayCell`(월간)과 `WeeklyCalendarDayCell`(주간)이 공유한다. 각 셀 위젯의 `remainingRatio` 파라미터를 `totalSpent`로 교체하고, 호출부(`_CalendarGrid`, `_buildWeekRow`)에서 `remainingRatio` 계산을 제거한다. ViewModel·Repository·도메인 레이어는 변경 없음.

**Tech Stack:** Flutter StatelessWidget, `moodBarColor()` (budget_mood_calculator.dart), `CurrencyFormatter.formatNumberOnly()`, `AppTypography`, `AppColors`

---

## 파일 구조

| 역할 | 경로 | 변경 |
|---|---|---|
| 새 뱃지 위젯 | `lib/features/calendar/presentation/widgets/calendar_amount_badge.dart` | Create |
| 월간 셀 | `lib/features/calendar/presentation/widgets/calendar_day_cell.dart` | Modify |
| 월간 그리드 호출부 | `lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart` | Modify |
| 주간 셀 | `lib/features/calendar/presentation/widgets/weekly_calendar_day_cell.dart` | Modify |
| 주간 그리드 호출부 | `lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart` | Modify |
| 뱃지 위젯 테스트 | `test/features/calendar/presentation/widgets/calendar_amount_badge_test.dart` | Create |

---

### Task 1: CalendarAmountBadge 위젯 생성 + 테스트

**Files:**
- Create: `lib/features/calendar/presentation/widgets/calendar_amount_badge.dart`
- Create: `test/features/calendar/presentation/widgets/calendar_amount_badge_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/calendar/presentation/widgets/calendar_amount_badge_test.dart`:

```dart
import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/calendar/presentation/widgets/calendar_amount_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  group('CalendarAmountBadge', () {
    testWidgets('지출 금액이 천단위 쉼표 포맷으로 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalendarAmountBadge(
          totalSpent: 5500,
          mood: CharacterMood.normal,
          isDark: false,
        ),
      ));
      expect(find.text('5,500'), findsOneWidget);
    });

    testWidgets('12,000원 초과 지출도 올바르게 포맷된다', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalendarAmountBadge(
          totalSpent: 12000,
          mood: CharacterMood.over,
          isDark: false,
        ),
      ));
      expect(find.text('12,000'), findsOneWidget);
    });

    testWidgets('comfortable mood에서도 숫자가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalendarAmountBadge(
          totalSpent: 1500,
          mood: CharacterMood.comfortable,
          isDark: false,
        ),
      ));
      expect(find.text('1,500'), findsOneWidget);
    });

    testWidgets('다크모드에서도 렌더링 오류 없이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalendarAmountBadge(
          totalSpent: 3000,
          mood: CharacterMood.comfortable,
          isDark: true,
        ),
      ));
      expect(find.text('3,000'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
fvm flutter test test/features/calendar/presentation/widgets/calendar_amount_badge_test.dart --no-pub
```

Expected: FAIL — `CalendarAmountBadge` 클래스를 찾을 수 없음

- [ ] **Step 3: CalendarAmountBadge 위젯 구현**

`lib/features/calendar/presentation/widgets/calendar_amount_badge.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/budget_mood_calculator.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 캘린더 셀 지출 금액 뱃지
///
/// 당일 지출 합계를 mood 색상 기반의 컬러 칩으로 표시한다.
/// - comfortable / newWeek → 초록 배경
/// - normal               → 앰버 배경
/// - danger               → 빨강 배경
/// - over                 → 짙은 빨강 배경
///
/// 월간([CalendarDayCell])과 주간([WeeklyCalendarDayCell]) 셀 공용으로 사용한다.
class CalendarAmountBadge extends StatelessWidget {
  /// 당일 지출 합계 (원)
  final int totalSpent;

  /// 예산 감정 상태 — 뱃지 색상 결정
  final CharacterMood mood;

  /// 다크모드 여부
  final bool isDark;

  const CalendarAmountBadge({
    super.key,
    required this.totalSpent,
    required this.mood,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = moodBarColor(mood, isDark: isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        CurrencyFormatter.formatNumberOnly(totalSpent),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
fvm flutter test test/features/calendar/presentation/widgets/calendar_amount_badge_test.dart --no-pub
```

Expected: PASS — 4/4

- [ ] **Step 5: 커밋**

```bash
git add lib/features/calendar/presentation/widgets/calendar_amount_badge.dart \
        test/features/calendar/presentation/widgets/calendar_amount_badge_test.dart
git commit -m "feat(calendar): CalendarAmountBadge 위젯 추출 — 지출 금액 컬러 뱃지"
```

---

### Task 2: CalendarDayCell + SlidingCalendarGrid 교체 (월간)

**Files:**
- Modify: `lib/features/calendar/presentation/widgets/calendar_day_cell.dart`
- Modify: `lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart`

월간 셀에서 `remainingRatio` 파라미터를 `totalSpent`로 교체하고, `LinearProgressIndicator`를 `CalendarAmountBadge`로 바꾼다. 호출부(`_CalendarGrid`)도 함께 수정해 컴파일 오류를 방지한다.

- [ ] **Step 1: CalendarDayCell 파라미터 및 렌더링 교체**

`lib/features/calendar/presentation/widgets/calendar_day_cell.dart`를 아래와 같이 수정한다.

변경 전 (34~36번째 줄 영역):
```dart
  /// 예산 잔여 비율 (0.0 ~ 1.0) — LinearProgressIndicator fill 값
  /// null이면 색상 바 자체를 숨김 (미래 날짜, 데이터 없음)
  final double? remainingRatio;
```

변경 후:
```dart
  /// 당일 지출 합계 (원) — null이면 뱃지 숨김 (미래 날짜, 데이터 없음)
  final int? totalSpent;
```

생성자 파라미터도 교체:
```dart
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.isFuture,
    this.isSuccess,
    this.mood,
    this.totalSpent,   // ← remainingRatio 대신
    this.onTap,
  });
```

build() 안의 `LinearProgressIndicator` 블록(143~161번째 줄)을 교체:

변경 전:
```dart
              if (isCurrentMonth && !isFuture && mood != null && remainingRatio != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1.5),
                    child: LinearProgressIndicator(
                      value: remainingRatio!.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: isDark
                          ? AppColors.darkDivider
                          : AppColors.border,
                      valueColor: AlwaysStoppedAnimation(
                        moodBarColor(mood!, isDark: isDark),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 3),
```

변경 후:
```dart
              if (isCurrentMonth && !isFuture && mood != null && totalSpent != null)
                CalendarAmountBadge(
                  totalSpent: totalSpent!,
                  mood: mood!,
                  isDark: isDark,
                )
              else
                const SizedBox(height: 3),
```

import 추가 (파일 상단):
```dart
import 'calendar_amount_badge.dart';
```

`AppColors` import가 더 이상 필요 없으면 제거한다 (색상 바 색상 로직이 badge로 이동). 단, `AppColors`가 textColor/bgColor에서 여전히 쓰이므로 유지한다.

- [ ] **Step 2: SlidingCalendarGrid 호출부 업데이트**

`lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart`의 `_CalendarGrid.build()` 안 `itemBuilder`에서:

`remainingRatio` 변수 및 계산 제거, `CalendarDayCell` 호출의 `remainingRatio:` → `totalSpent:` 교체.

변경 전 (294~315번째 줄 영역):
```dart
          // 과거 날짜이고 지출 데이터가 있을 때 mood + 잔여 비율 계산
          CharacterMood? mood;
          double? remainingRatio;
          if (!isFuture && totalSpent != null) {
            mood = calculateMood(baseAmount, totalSpent);
            remainingRatio = baseAmount > 0
                ? ((baseAmount - totalSpent) / baseAmount)
                : 0.0;
          }

          return CalendarDayCell(
            date: cellDate,
            isToday: isToday,
            isSelected: isSelected,
            isCurrentMonth: isCurrentMonth,
            isFuture: isFuture,
            isSuccess: isSuccess,
            mood: mood,
            remainingRatio: remainingRatio,
            onTap: () => onDateSelected(cellDate),
          );
```

변경 후:
```dart
          // 지출이 있을 때만 mood 계산 (뱃지 색상용)
          CharacterMood? mood;
          if (!isFuture && totalSpent != null) {
            mood = calculateMood(baseAmount, totalSpent);
          }

          return CalendarDayCell(
            date: cellDate,
            isToday: isToday,
            isSelected: isSelected,
            isCurrentMonth: isCurrentMonth,
            isFuture: isFuture,
            isSuccess: isSuccess,
            mood: mood,
            totalSpent: totalSpent,
            onTap: () => onDateSelected(cellDate),
          );
```

또한 `totalSpent = 0` 분기(지출 없는 과거 날)를 아래와 같이 수정 — 뱃지는 지출이 있을 때만 표시하므로, 0원 지출은 null로 처리:

변경 전:
```dart
          if (expenses != null && expenses.isNotEmpty) {
            totalSpent = expenses.fold<int>(0, (sum, e) => sum + e.amount);
            isSuccess = totalSpent <= baseAmount;
          } else if (!isFuture && !isToday) {
            // 지출 없는 과거 날 → 0원 지출 = 성공(comfortable)
            totalSpent = 0;
            isSuccess = true;
          }
```

변경 후:
```dart
          if (expenses != null && expenses.isNotEmpty) {
            totalSpent = expenses.fold<int>(0, (sum, e) => sum + e.amount);
            isSuccess = totalSpent <= baseAmount;
          } else if (!isFuture && !isToday) {
            // 지출 없는 과거 날 → 뱃지 없음, semantics는 성공
            isSuccess = true;
            // totalSpent는 null 유지 — 뱃지 미표시
          }
```

- [ ] **Step 3: 분석 오류 없는지 확인**

```bash
fvm flutter analyze --no-pub 2>&1 | grep -E "error|warning" | grep -v "^Analyzing"
```

Expected: 기존 info 1건 외 새로운 error/warning 없음

- [ ] **Step 4: 기존 테스트 통과 확인**

```bash
fvm flutter test test/features/calendar/ --no-pub
```

Expected: PASS

- [ ] **Step 5: 커밋**

```bash
git add lib/features/calendar/presentation/widgets/calendar_day_cell.dart \
        lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart
git commit -m "feat(calendar): 월간 셀 ProgressBar → AmountBadge 교체"
```

---

### Task 3: WeeklyCalendarDayCell + SlidingWeeklyGrid 교체 (주간)

**Files:**
- Modify: `lib/features/calendar/presentation/widgets/weekly_calendar_day_cell.dart`
- Modify: `lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart`

월간과 동일한 패턴으로 주간 셀에도 적용한다.

- [ ] **Step 1: WeeklyCalendarDayCell 파라미터 및 렌더링 교체**

`lib/features/calendar/presentation/widgets/weekly_calendar_day_cell.dart`에서:

파라미터 교체 (22~24번째 줄):

변경 전:
```dart
  /// 예산 잔여 비율 (0.0 ~ 1.0) — LinearProgressIndicator fill 값
  final double? remainingRatio;
```

변경 후:
```dart
  /// 당일 지출 합계 (원) — null이면 뱃지 숨김
  final int? totalSpent;
```

생성자 교체:
```dart
  const WeeklyCalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    this.onTap,
    this.mood,
    this.totalSpent,   // ← remainingRatio 대신
  });
```

build()의 `LinearProgressIndicator` 블록(67~85번째 줄) 교체:

변경 전:
```dart
            if (!isFuture && mood != null && remainingRatio != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1.5),
                  child: LinearProgressIndicator(
                    value: remainingRatio!.clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: isDark
                        ? AppColors.darkDivider
                        : AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                      moodBarColor(mood!, isDark: isDark),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 3),
```

변경 후:
```dart
            if (!isFuture && mood != null && totalSpent != null)
              CalendarAmountBadge(
                totalSpent: totalSpent!,
                mood: mood!,
                isDark: isDark,
              )
            else
              const SizedBox(height: 3),
```

import 추가:
```dart
import 'calendar_amount_badge.dart';
```

`AppColors` import 확인 — `_DateCircle`에서 `AppColors.darkCard` 등을 여전히 사용하므로 유지한다.

- [ ] **Step 2: SlidingWeeklyGrid 호출부 업데이트**

`lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart`의 `_buildWeekRow()` 안에서:

`remainingRatio` 변수 및 계산 제거, `totalSpent = 0` 분기 수정, `WeeklyCalendarDayCell` 호출 교체.

변경 전 (158~189번째 줄 영역):
```dart
          int? totalSpent;
          if (!isFuture) {
            if (dayExpenses != null && dayExpenses.isNotEmpty) {
              totalSpent = dayExpenses.fold<int>(0, (s, e) => s + e.amount);
            } else if (!isToday) {
              totalSpent = 0;
            }
          }

          final CharacterMood? mood =
              (!isFuture && totalSpent != null)
                  ? calculateMood(dayBudget, totalSpent)
                  : null;

          final double? remainingRatio =
              (!isFuture && totalSpent != null && dayBudget > 0)
                  ? (dayBudget - totalSpent) / dayBudget
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
                remainingRatio: remainingRatio,
              ),
            ),
          );
```

변경 후:
```dart
          int? totalSpent;
          if (!isFuture && dayExpenses != null && dayExpenses.isNotEmpty) {
            totalSpent = dayExpenses.fold<int>(0, (s, e) => s + e.amount);
          }
          // 지출 없는 과거 날은 totalSpent = null → 뱃지 미표시

          final CharacterMood? mood =
              (!isFuture && totalSpent != null)
                  ? calculateMood(dayBudget, totalSpent)
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
```

- [ ] **Step 3: 분석 오류 없는지 확인**

```bash
fvm flutter analyze --no-pub 2>&1 | grep -E "error|warning" | grep -v "^Analyzing"
```

Expected: 기존 info 1건 외 새로운 error/warning 없음

- [ ] **Step 4: 전체 테스트 통과 확인**

```bash
fvm flutter test --no-pub
```

Expected: 모든 테스트 PASS

- [ ] **Step 5: 커밋**

```bash
git add lib/features/calendar/presentation/widgets/weekly_calendar_day_cell.dart \
        lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart
git commit -m "feat(calendar): 주간 셀 ProgressBar → AmountBadge 교체"
```
