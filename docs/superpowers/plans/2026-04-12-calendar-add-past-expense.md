# 캘린더 이전 날짜 지출 기록 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 캘린더 화면에서 선택된 날짜(또는 오늘)의 지출을 FAB으로 추가할 수 있게 한다.

**Architecture:** `showExpenseAddBottomSheet`에 `date` 파라미터를 추가하고 바텀시트 내부에서 `createdAt`으로 사용한다. 헤더는 항상 날짜를 표시하되 편집 모드에서는 기존 지출의 `createdAt`을 표시한다. `CalendarScreen`의 `Scaffold`에 FAB을 추가하여 선택된 날짜를 전달한다. 캘린더 갱신은 `HomeViewModel.addExpense` 내부의 `ref.invalidate`가 처리하므로 FAB에서 별도 갱신 호출은 하지 않는다.

**Tech Stack:** Flutter, Riverpod (Notifier), Drift (SQLite), flutter_riverpod 3.x, mocktail

---

## 변경 파일 목록

| 파일 | 종류 | 내용 |
|------|------|------|
| `lib/features/expense/presentation/screens/expense_add_screen.dart` | 수정 | date 파라미터, 날짜 헤더, createdAt 적용 |
| `lib/features/home/presentation/screens/home_screen.dart` | 수정 | 홈 FAB에 heroTag 추가 |
| `lib/features/calendar/presentation/screens/calendar_screen.dart` | 수정 | 캘린더 FAB 추가 |
| `test/features/expense/presentation/screens/expense_add_bottom_sheet_test.dart` | 신규 | 날짜 헤더 위젯 테스트 |
| `test/features/calendar/presentation/screens/calendar_screen_fab_test.dart` | 신규 | FAB 렌더링 위젯 테스트 |

---

## Task 1: `showExpenseAddBottomSheet`에 `date` 파라미터 추가

**Files:**
- Modify: `lib/features/expense/presentation/screens/expense_add_screen.dart`

### 변경 내용

`showExpenseAddBottomSheet` 함수에 `DateTime? date` 파라미터를 추가하고, 바텀시트 내부에서 사용한다.

- 새 지출 생성 시: `date ?? DateTime.now()` → `createdAt`
- 기존 지출 편집 시: `widget.expense!.createdAt` → 헤더 날짜 표시 (date 파라미터 무시)
- 헤더: 항상 "M월 D일 지출 기록" 형태로 표시

- [ ] **Step 1: `showExpenseAddBottomSheet` 시그니처 수정**

`lib/features/expense/presentation/screens/expense_add_screen.dart`의 `showExpenseAddBottomSheet` 함수를 아래로 교체한다.

```dart
/// 지출 입력 바텀시트를 표시하는 헬퍼 함수
/// [date]를 지정하면 해당 날짜로 지출을 기록한다. 미지정 시 오늘 날짜로 기록한다.
/// 편집 모드([expense] 전달 시)에서는 [date]가 무시되며 기존 지출의 날짜가 표시된다.
/// 저장 성공 시 true를 반환하며, 취소/닫기 시 false 또는 null 반환
Future<bool?> showExpenseAddBottomSheet(
  BuildContext context, {
  ExpenseEntity? expense,
  DateTime? date,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isDismissible: true,
    useRootNavigator: true,
    builder: (context) => _ExpenseAddBottomSheet(expense: expense, date: date),
  );
}
```

- [ ] **Step 2: `_ExpenseAddBottomSheet`에 `date` 필드 추가**

```dart
class _ExpenseAddBottomSheet extends ConsumerStatefulWidget {
  final ExpenseEntity? expense;
  /// 새 지출을 기록할 날짜. null이면 오늘. 편집 모드에서는 무시된다.
  final DateTime? date;

  const _ExpenseAddBottomSheet({this.expense, this.date});

  @override
  ConsumerState<_ExpenseAddBottomSheet> createState() =>
      _ExpenseAddBottomSheetState();
}
```

- [ ] **Step 3: `_recordDate` getter 추가**

`_ExpenseAddBottomSheetState` 내부 필드 선언부 직후에 추가한다.

```dart
/// 헤더 및 createdAt에 사용할 실제 날짜.
/// 편집 모드: 기존 지출의 날짜 / 신규 모드: date 파라미터 또는 오늘
DateTime get _recordDate {
  if (widget.expense != null) {
    final d = widget.expense!.createdAt;
    return DateTime(d.year, d.month, d.day);
  }
  final d = widget.date ?? DateTime.now();
  return DateTime(d.year, d.month, d.day);
}
```

- [ ] **Step 4: 헤더 타이틀에 날짜 표시**

`build()` 메서드의 헤더 Row에서 `'지출 기록'` 텍스트를 아래로 교체한다.

```dart
Text(
  '${_recordDate.month}월 ${_recordDate.day}일 지출 기록',
  style: AppTypography.titleMedium.copyWith(
    color: textMainColor,
  ),
),
```

- [ ] **Step 5: 신규 지출 생성 시 `createdAt`을 `_recordDate`로 교체**

`_onSave()` 메서드의 신규 지출 생성 블록(`createdAt: DateTime.now()`)을 아래로 수정한다.

```dart
await ref
    .read(homeViewModelProvider.notifier)
    .addExpense(
      ExpenseEntity(
        id: 0,
        amount: _amount,
        category: _selectedCategory.index,
        createdAt: _recordDate,
      ),
    );
```

- [ ] **Step 6: `flutter analyze` 실행**

```bash
flutter analyze lib/features/expense/presentation/screens/expense_add_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/expense/presentation/screens/expense_add_screen.dart
git commit -m "feat(expense): 지출 바텀시트 날짜 지정 파라미터 추가 및 헤더 날짜 표시"
```

---

## Task 2: 바텀시트 날짜 동작 위젯 테스트 작성

**Files:**
- Create: `test/features/expense/presentation/screens/expense_add_bottom_sheet_test.dart`

- [ ] **Step 1: 테스트 파일 생성**

```dart
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/presentation/screens/expense_add_screen.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// HomeViewModel 스텁 — DI/DB 없이 바텀시트만 렌더링하기 위한 최소 구현
class _StubHomeViewModel extends HomeViewModel {
  @override
  HomeState build() => const HomeState(isLoading: false);

  @override
  Future<void> addExpense(ExpenseEntity expense) async {}

  @override
  void refresh() {}
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        homeViewModelProvider.overrideWith(_StubHomeViewModel.new),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('showExpenseAddBottomSheet — date 파라미터 헤더 표시', () {
    testWidgets('date 없이 열면 오늘 날짜가 헤더에 표시된다', (tester) async {
      final today = DateTime.now();
      final expectedTitle = '${today.month}월 ${today.day}일 지출 기록';

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () => showExpenseAddBottomSheet(ctx),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(expectedTitle), findsOneWidget);
    });

    testWidgets('과거 date를 지정하면 해당 날짜가 헤더에 표시된다', (tester) async {
      final pastDate = DateTime(2026, 4, 9);
      const expectedTitle = '4월 9일 지출 기록';

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () =>
                  showExpenseAddBottomSheet(ctx, date: pastDate),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(expectedTitle), findsOneWidget);
    });

    testWidgets('편집 모드에서는 기존 지출의 날짜가 헤더에 표시된다', (tester) async {
      final existingExpense = ExpenseEntity(
        id: 1,
        amount: 3000,
        category: 0,
        createdAt: DateTime(2026, 3, 15),
      );
      const expectedTitle = '3월 15일 지출 기록';

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () =>
                  showExpenseAddBottomSheet(ctx, expense: existingExpense),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(expectedTitle), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행**

```bash
flutter test test/features/expense/presentation/screens/expense_add_bottom_sheet_test.dart -v
```

Expected: 3개 테스트 모두 PASS

- [ ] **Step 3: Commit**

```bash
git add test/features/expense/presentation/screens/expense_add_bottom_sheet_test.dart
git commit -m "test(expense): 바텀시트 date 파라미터 위젯 테스트 추가"
```

---

## Task 3: 홈 FAB에 `heroTag` 추가

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

### 배경

캘린더 화면에 새 FAB을 추가하면 두 FAB이 `StatefulShellRoute.indexedStack` 내에서 동시에 존재하게 되어 Hero 태그 충돌이 발생한다. 홈 FAB에 `heroTag`를 명시하여 충돌을 사전에 방지한다.

- [ ] **Step 1: 홈 FAB에 `heroTag` 추가**

`lib/features/home/presentation/screens/home_screen.dart` 212번째 줄의 `FloatingActionButton(` 다음 줄에 아래를 삽입한다.

```dart
heroTag: 'home_add_expense',
```

결과:
```dart
floatingActionButton: FloatingActionButton(
  heroTag: 'home_add_expense',
  tooltip: '지출 추가',
  backgroundColor: isDark ? AppColors.white : AppColors.primary,
  foregroundColor: isDark ? AppColors.black : AppColors.white,
  shape: const CircleBorder(),
  onPressed: () => showExpenseAddBottomSheet(context),
  child: const Icon(Icons.add, size: 28),
),
```

- [ ] **Step 2: `flutter analyze` 실행**

```bash
flutter analyze lib/features/home/presentation/screens/home_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "fix(home): 홈 FAB에 heroTag 추가 — 캘린더 FAB 충돌 방지"
```

---

## Task 4: `CalendarScreen`에 FAB 추가

**Files:**
- Modify: `lib/features/calendar/presentation/screens/calendar_screen.dart`

### 변경 내용

`CalendarScreen`의 `Scaffold`에 `floatingActionButton`을 추가한다.

- 항상 표시
- 탭 시: `state.selectedDate ?? DateTime.now()`를 `date`로 전달하여 `showExpenseAddBottomSheet` 호출
- 저장 후 캘린더 갱신: `HomeViewModel.addExpense` 내부의 `ref.invalidate(calendarViewModelProvider)`가 자동 처리하므로 **FAB에서 별도 갱신 호출 없음**

- [ ] **Step 1: `Scaffold`에 `floatingActionButton` 추가**

`calendar_screen.dart`의 `Scaffold(` 블록에서 `backgroundColor: bgColor,` 바로 아래에 아래를 삽입한다.

```dart
floatingActionButton: FloatingActionButton(
  heroTag: 'calendar_add_expense',
  backgroundColor: isDark ? AppColors.darkTextMain : AppColors.textMain,
  foregroundColor: isDark ? AppColors.darkBackground : AppColors.white,
  onPressed: () async {
    final date = state.selectedDate ?? DateTime.now();
    await showExpenseAddBottomSheet(context, date: date);
    // 캘린더 갱신은 HomeViewModel.addExpense 내부의
    // ref.invalidate(calendarViewModelProvider)가 처리한다.
  },
  child: const Icon(Icons.add_rounded, size: 28),
),
```

- [ ] **Step 2: `flutter analyze` 실행**

```bash
flutter analyze lib/features/calendar/presentation/screens/calendar_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 3: 앱 실행 후 직접 검증**

```bash
flutter run
```

검증 시나리오:
1. 캘린더 탭 이동 → 우측 하단에 `+` FAB이 보인다
2. 날짜 미선택 상태에서 FAB 탭 → 오늘 날짜("4월 12일 지출 기록") 바텀시트 열림
3. 과거 날짜(예: 4월 9일) 탭 선택 후 FAB 탭 → "4월 9일 지출 기록" 바텀시트 열림
4. 금액 입력 후 기록하기 → 바텀시트 닫힘, 캘린더 자동 갱신되어 해당 날짜 셀에 지출 반영
5. 해당 날짜 탭 → `DailyExpenseDetail`에 방금 추가한 지출이 표시됨
6. 홈 탭 ↔ 캘린더 탭 전환 시 Hero 충돌 없이 FAB 애니메이션 정상 동작

- [ ] **Step 4: Commit**

```bash
git add lib/features/calendar/presentation/screens/calendar_screen.dart
git commit -m "feat(calendar): 이전 날짜 지출 추가 FAB 구현"
```

---

## Task 5: CalendarScreen FAB 위젯 테스트 작성

**Files:**
- Create: `test/features/calendar/presentation/screens/calendar_screen_fab_test.dart`

- [ ] **Step 1: 테스트 파일 생성**

```dart
import 'package:daily_manwon/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:daily_manwon/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CalendarViewModel 스텁 — DB/DI 없이 FAB 렌더링만 테스트하기 위한 최소 구현
class _StubCalendarViewModel extends CalendarViewModel {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      selectedMonth: DateTime(now.year, now.month, 1),
      selectedWeekStart: now,
      isLoading: false,
    );
  }
}

Widget _buildApp() => ProviderScope(
      overrides: [
        calendarViewModelProvider.overrideWith(_StubCalendarViewModel.new),
      ],
      child: const MaterialApp(home: CalendarScreen()),
    );

void main() {
  group('CalendarScreen FAB', () {
    testWidgets('FAB이 항상 렌더링된다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB 아이콘이 add_rounded이다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행**

```bash
flutter test test/features/calendar/presentation/screens/calendar_screen_fab_test.dart -v
```

Expected: 2개 테스트 모두 PASS

- [ ] **Step 3: 전체 테스트 회귀 확인**

```bash
flutter test
```

Expected: 기존 테스트 포함 전체 PASS

- [ ] **Step 4: Commit**

```bash
git add test/features/calendar/presentation/screens/calendar_screen_fab_test.dart
git commit -m "test(calendar): FAB 렌더링 위젯 테스트 추가"
```

---

## 완료 체크리스트

- [ ] `showExpenseAddBottomSheet`에 `date` 파라미터 추가됨
- [ ] 바텀시트 헤더가 "M월 D일 지출 기록" 형식으로 표시됨 (신규/편집 모두)
- [ ] 편집 모드에서는 `widget.expense!.createdAt` 날짜가 헤더에 표시됨
- [ ] 신규 지출 생성 시 `createdAt`이 `_recordDate`로 저장됨
- [ ] 홈 FAB에 `heroTag: 'home_add_expense'` 추가됨
- [ ] 캘린더 FAB에 `heroTag: 'calendar_add_expense'` 추가됨
- [ ] 캘린더 FAB이 항상 표시됨
- [ ] FAB 탭 시 선택 날짜 또는 오늘 날짜로 바텀시트 열림
- [ ] 저장 후 캘린더 데이터 자동 갱신됨 (FAB에 별도 refresh 호출 없음)
- [ ] `flutter analyze` 경고 없음
- [ ] 신규 위젯 테스트 3 + 2 = 5개 모두 PASS
- [ ] 기존 테스트 전체 PASS
