# Favorite Delete (X Icon) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 즐겨찾기 칩에 X 아이콘을 추가해 인라인 삭제가 가능하게 하고, 삭제 즉시 iOS HomeWidget의 favoritesKey도 동기화한다.

**Architecture:** `FavoriteTemplatesSection`의 `ActionChip`을 `InputChip`(onPressed + onDeleted 동시 지원)으로 교체한다. 삭제 후 `WidgetService.updateFavorites()`(신규 메서드)를 호출해 iOS 위젯의 `favoritesKey`만 갱신한다. `DeleteFavoriteUseCase`는 이미 존재하므로 새 파일은 불필요하다.

**Tech Stack:** Flutter / Riverpod FutureProvider / get_it / home_widget (App Group UserDefaults)

---

## File Map

| 상태 | 파일 | 변경 내용 |
|------|------|-----------|
| Modify | `lib/core/services/widget_service.dart` | `updateFavorites()` 메서드 추가 |
| Modify | `lib/features/expense/presentation/widgets/favorite_templates_section.dart` | `ActionChip` → `InputChip`, onDeleted 로직 추가 |

---

## Task 1: WidgetService에 `updateFavorites()` 추가

**Files:**
- Modify: `lib/core/services/widget_service.dart`

즐겨찾기 삭제 시 나머지 위젯 데이터(잔액, 지출 등)는 그대로 두고 `favoritesKey`만 덮어쓴 뒤 위젯을 갱신하는 경량 메서드다.

- [ ] **Step 1: `updateFavorites()` 메서드를 `updateWidget()` 아래에 추가**

`lib/core/services/widget_service.dart` 파일의 `updateWidget` 메서드 닫는 `}` 바로 뒤(136번 라인 이후)에 추가:

```dart
  /// 즐겨찾기 목록만 위젯에 갱신한다.
  ///
  /// 지출·잔액 등 나머지 키는 기존 값을 유지하고 favoritesKey만 덮어쓴다.
  /// 즐겨찾기 추가/삭제 시 호출한다.
  Future<void> updateFavorites(List<Map<String, dynamic>> favorites) async {
    if (!_appGroupAvailable) return;
    try {
      await HomeWidget.saveWidgetData<String>(
        'favoritesKey',
        jsonEncode(favorites),
      );
      await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
      debugPrint('WidgetService: 즐겨찾기 위젯 갱신 완료 (${favorites.length}건)');
    } catch (e) {
      debugPrint('WidgetService: 즐겨찾기 위젯 갱신 실패 — $e');
    }
  }
```

- [ ] **Step 2: 앱 빌드 확인**

```bash
flutter analyze lib/core/services/widget_service.dart
```
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/widget_service.dart
git commit -m "feat(widget): add updateFavorites() for lightweight favorites sync"
```

---

## Task 2: FavoriteTemplatesSection — ActionChip → InputChip + 삭제 로직

**Files:**
- Modify: `lib/features/expense/presentation/widgets/favorite_templates_section.dart`

`InputChip`은 `onPressed`(탭으로 템플릿 적용)와 `onDeleted`(X 아이콘 탭으로 삭제)를 동시에 지원하는 Flutter 기본 칩이다. 자동학습 추천 칩(deduped)은 삭제 불가이므로 기존 `ActionChip` 그대로 유지한다.

- [ ] **Step 1: import에 `delete_favorite_use_case.dart` 추가**

파일 상단 import 블록에서 `increment_favorite_usage_use_case.dart` import 바로 아래에 추가:

```dart
import '../../domain/usecases/delete_favorite_use_case.dart';
```

그리고 `WidgetService` import 추가:

```dart
import '../../../../core/services/widget_service.dart';
```

- [ ] **Step 2: 즐겨찾기 ActionChip을 InputChip으로 교체**

현재 코드 (`favorites.map` 블록 전체):

```dart
...favorites.map((fav) {
  final cat = ExpenseCategory.values[fav.category];
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ActionChip(
      avatar: Image.asset(
        cat.assetPath,
        width: 18,
        height: 18,
      ),
      label: Text(
        '${_formatAmount(fav.amount)}',
        style: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.darkTextMain
              : AppColors.textMain,
        ),
      ),
      backgroundColor: isDark
          ? AppColors.darkCard
          : cat.chipColor,
      onPressed: () async {
        try {
          await getIt<IncrementFavoriteUsageUseCase>()
              .execute(fav.id);
        } catch (_) {
          // usageCount 증가 실패는 UI에 영향 없음
        }
        onTemplateTap((
          amount: fav.amount,
          category: fav.category,
          memo: fav.memo,
        ));
        ref.invalidate(favoritesProvider);
      },
    ),
  );
}),
```

위 블록을 아래로 교체:

```dart
...favorites.map((fav) {
  final cat = ExpenseCategory.values[fav.category];
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InputChip(
      avatar: Image.asset(
        cat.assetPath,
        width: 18,
        height: 18,
      ),
      label: Text(
        _formatAmount(fav.amount),
        style: TextStyle(
          fontSize: 13,
          color: isDark
              ? AppColors.darkTextMain
              : AppColors.textMain,
        ),
      ),
      backgroundColor: isDark
          ? AppColors.darkCard
          : cat.chipColor,
      deleteIconColor: isDark
          ? AppColors.darkTextSub
          : AppColors.textSub,
      onPressed: () async {
        try {
          await getIt<IncrementFavoriteUsageUseCase>()
              .execute(fav.id);
        } catch (_) {
          // usageCount 증가 실패는 UI에 영향 없음
        }
        onTemplateTap((
          amount: fav.amount,
          category: fav.category,
          memo: fav.memo,
        ));
        ref.invalidate(favoritesProvider);
      },
      onDeleted: () async {
        try {
          await getIt<DeleteFavoriteUseCase>().execute(fav.id);
        } catch (_) {
          // 삭제 실패 시 UI는 provider 갱신 없이 그대로 유지
          return;
        }

        // iOS HomeWidget favoritesKey 동기화 먼저 — provider 갱신 전에 실행해
        // GetFavoritesUseCase 이중 쿼리를 방지한다
        try {
          final updated = await getIt<GetFavoritesUseCase>().execute();
          await getIt<WidgetService>().updateFavorites(
            updated
                .map((f) => {
                      'id': f.id,
                      'amount': f.amount,
                      'category': f.category,
                      'memo': f.memo,
                    })
                .toList(),
          );
        } catch (_) {
          // 위젯 동기화 실패는 앱 동작에 영향 없음
        }

        // 위젯 sync 완료 후 provider 갱신 — DB 재조회가 한 번만 발생
        ref.invalidate(favoritesProvider);
      },
    ),
  );
}),
```

- [ ] **Step 3: 분석 실행**

```bash
flutter analyze lib/features/expense/presentation/widgets/favorite_templates_section.dart
```
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/expense/presentation/widgets/favorite_templates_section.dart
git commit -m "feat(expense): add X icon delete to favorite chips with iOS widget sync"
```

---

## Task 3: 수동 검증

- [ ] **Step 1: 앱 실행**

```bash
flutter run
```

- [ ] **Step 2: 즐겨찾기 추가 후 X 아이콘 확인**

1. 지출 기록 화면 열기
2. 금액 입력 후 "즐겨찾기에 추가" 체크 → 저장
3. 다시 지출 기록 화면 열기 → 상단 칩에 X 아이콘 표시 확인
4. X 탭 → 칩이 목록에서 즉시 사라짐 확인

- [ ] **Step 3: 자동학습 칩은 X 없음 확인**

자동학습 추천 칩(회색 계열)에는 X 아이콘이 없어야 한다.

- [ ] **Step 4: iOS 시뮬레이터에서 HomeWidget 확인 (선택)**

1. 시뮬레이터 홈 화면에 DailyHomeWidget (Large) 추가
2. 앱에서 즐겨찾기 X 탭
3. 위젯 장기 프레스 → "위젯 편집" 또는 타임라인 갱신 후 즐겨찾기 항목이 사라짐 확인

---

## Self-Review Checklist

- [x] **Spec coverage:** X 아이콘 삭제 (Task 2), iOS 위젯 동기화 (Task 2 onDeleted + Task 1), 자동학습 칩 비삭제 유지
- [x] **Placeholder scan:** 없음 — 모든 코드 블록 완전 작성
- [x] **Type consistency:** `DeleteFavoriteUseCase.execute(int id)`, `GetFavoritesUseCase.execute()`, `WidgetService.updateFavorites(List<Map<String,dynamic>>)` — 기존 시그니처와 일치
- [x] **No new files:** `DeleteFavoriteUseCase` 기존 존재 확인됨
