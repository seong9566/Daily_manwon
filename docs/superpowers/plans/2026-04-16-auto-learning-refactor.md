# Auto-Learning Chip Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** GET 시마다 30일 빈도 집계 + 영구 dismiss 방식을 제거하고, 지출 저장/삭제 시 "최근 사용 상위 3개" 조합을 `favorite_expenses` 테이블에 자동 동기화하는 방식으로 교체한다.

**Architecture:**
- `syncAutoFavorites()` — 지출 추가·삭제·수정 후 및 앱 초기 로드 시 호출. 최근 사용 순 상위 3개 고유 (amount, category)를 쿼리하여 DB의 자동 즐겨찾기(`isAuto=true`) row를 diff 동기화한다.
- `FavoriteExpenses` 테이블에 `isAuto` 컬럼(bool, default false) 추가. 수동·자동 row는 독립적으로 공존 가능하며 삭제는 항상 ID 기준.
- `frequentTemplates` 상태, `dismissedFreqKeys`, SharedPreferences dismiss 저장소를 완전 제거. 기존 사용자 데이터는 마이그레이션 시 일회성 삭제.
- **`_addToFavorite` 체크박스 + 자동 sync 중복 동작**: `ExpenseAddScreen._onSave`에서 `addExpense`(→ `syncAutoFavorites` 포함) 완료 후 `addFavorite`(수동) 호출 순서로 실행된다. 동일 조합이 top3에 해당하면 auto row(isAuto=true)와 manual row(isAuto=false)가 각각 생성되어 칩이 2개 표시된다. "중복 가능" 정책에 의한 의도된 동작이며, 각 칩은 자체 ID로 독립 삭제된다.
- `syncAutoFavorites`는 수동 즐겨찾기(`isAuto=false`)의 존재 여부를 체크하지 않는다 — 중복 허용 정책에 의한 의도된 설계.

**Tech Stack:** Flutter, Drift (SQLite ORM, schema v9), Riverpod (Notifier), Injectable (GetIt), shared_preferences

---

## File Map

| 액션 | 파일 |
|---|---|
| **수정** | `lib/core/database/app_database.dart` |
| **수정** | `lib/features/expense/domain/entities/favorite_expense.dart` |
| **수정** | `lib/features/expense/data/models/favorite_expense_mapper.dart` |
| **수정** | `lib/features/expense/data/datasources/favorite_expense_datasource.dart` |
| **수정** | `lib/features/expense/domain/repositories/favorite_expense_repository.dart` |
| **수정** | `lib/features/expense/data/repositories/favorite_expense_repository_impl.dart` |
| **수정** | `lib/features/home/presentation/viewmodels/home_view_model.dart` |
| **수정** | `lib/features/settings/domain/repositories/settings_repository.dart` |
| **수정** | `lib/features/settings/data/datasources/settings_local_datasource.dart` |
| **수정** | `lib/features/settings/data/repositories/settings_repository_impl.dart` |
| **수정** | `lib/features/expense/presentation/widgets/favorite_templates_section.dart` |
| **수정** | `lib/core/di/injection.config.dart` |
| **수정** | `test/features/expense/data/datasources/favorite_expense_datasource_test.dart` |
| **수정** | `test/features/expense/presentation/widgets/favorite_templates_section_test.dart` |
| **삭제** | `lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart` |
| **자동생성** | `lib/features/expense/domain/entities/favorite_expense.freezed.dart` (build_runner) |
| **자동생성** | `lib/core/database/app_database.g.dart` (build_runner) |
| **참고 (수정 없음)** | `lib/features/expense/presentation/screens/expense_add_screen.dart` |

---

## Task 1: DB 스키마 v9 — `FavoriteExpenses.isAuto` 컬럼 추가

**Files:**
- Modify: `lib/core/database/app_database.dart`

- [ ] **Step 1: `FavoriteExpenses` 테이블에 `isAuto` 컬럼 추가**

`lib/core/database/app_database.dart` 의 `FavoriteExpenses` 클래스를 아래로 교체:

```dart
/// 수동 + 자동 즐겨찾기 지출 템플릿 테이블
/// - usageCount: 탭 횟수 (자동 정렬 기준)
/// - isAuto: true면 자동학습으로 추가된 row — 수동 row와 동일 (amount,category) 공존 가능
class FavoriteExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();
  IntColumn get category => integer()(); // ExpenseCategory enum index
  TextColumn get memo => text().withDefault(const Constant(''))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  BoolColumn get isAuto => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
```

- [ ] **Step 2: `schemaVersion` 9로 변경 + 마이그레이션 추가**

```dart
@override
int get schemaVersion => 9;

@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) => m.createAll(),
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) await m.createTable(userPreferences);
        if (from < 3) await m.createTable(notificationSettings);
        if (from < 4) await m.addColumn(userPreferences, userPreferences.isOnboardingCompleted);
        if (from < 5) await m.addColumn(dailyBudgets, dailyBudgets.mood);
        if (from < 6) await m.addColumn(userPreferences, userPreferences.dailyBudget);
        if (from < 7) await m.addColumn(userPreferences, userPreferences.carryoverEnabled);
        if (from < 8) await m.createTable(favoriteExpenses);
        // schema v9: FavoriteExpenses.isAuto 컬럼 추가 (기존 row는 default false → 수동 즐겨찾기)
        if (from < 9) await m.addColumn(favoriteExpenses, favoriteExpenses.isAuto);
      },
    );
```

- [ ] **Step 3: build_runner로 `app_database.g.dart` 재생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: `lib/core/database/app_database.g.dart` 재생성. `FavoriteExpense` 데이터 클래스에 `isAuto` 필드 포함.

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/core/database/
```
Expected: 오류 없음.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/database/app_database.dart lib/core/database/app_database.g.dart
git commit -m "feat(db): FavoriteExpenses.isAuto 컬럼 추가, schema v9 마이그레이션"
```

---

## Task 2: `FavoriteExpenseEntity` 및 Mapper에 `isAuto` 추가

**Files:**
- Modify: `lib/features/expense/domain/entities/favorite_expense.dart`
- Modify: `lib/features/expense/data/models/favorite_expense_mapper.dart`

- [ ] **Step 1: 도메인 엔티티에 `isAuto` 필드 추가**

`lib/features/expense/domain/entities/favorite_expense.dart` 전체를 아래로 교체:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_expense.freezed.dart';

/// 즐겨찾기 지출 템플릿 도메인 엔티티
/// - [category]: ExpenseCategory enum의 index 값
/// - [usageCount]: 탭 횟수 — 높을수록 목록 상단에 정렬
/// - [isAuto]: true면 자동학습으로 추가된 row (수동 row와 동일 조합 공존 가능)
@freezed
sealed class FavoriteExpenseEntity with _$FavoriteExpenseEntity {
  const factory FavoriteExpenseEntity({
    required int id,
    required int amount,
    required int category,
    @Default('') String memo,
    @Default(0) int usageCount,
    @Default(false) bool isAuto,
    required DateTime createdAt,
  }) = _FavoriteExpenseEntity;
}
```

- [ ] **Step 2: build_runner로 freezed 재생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: `lib/features/expense/domain/entities/favorite_expense.freezed.dart` 재생성. `isAuto` 필드 포함.

- [ ] **Step 3: Mapper에 `isAuto` 추가**

`lib/features/expense/data/models/favorite_expense_mapper.dart` 전체를 아래로 교체:

```dart
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/favorite_expense.dart';

extension FavoriteExpenseRowMapper on FavoriteExpense {
  FavoriteExpenseEntity toEntity() => FavoriteExpenseEntity(
        id: id,
        amount: amount,
        category: category,
        memo: memo,
        usageCount: usageCount,
        isAuto: isAuto,
        createdAt: createdAt,
      );
}

extension FavoriteExpenseEntityMapper on FavoriteExpenseEntity {
  FavoriteExpensesCompanion toCompanion() => FavoriteExpensesCompanion.insert(
        amount: amount,
        category: category,
        memo: Value(memo),
        isAuto: Value(isAuto),
        createdAt: createdAt,
      );
}
```

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/expense/domain/entities/ \
               lib/features/expense/data/models/
```
Expected: 오류 없음.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/expense/domain/entities/favorite_expense.dart \
        lib/features/expense/domain/entities/favorite_expense.freezed.dart \
        lib/features/expense/data/models/favorite_expense_mapper.dart
git commit -m "feat(entity): FavoriteExpenseEntity.isAuto 필드 추가, mapper 갱신"
```

---

## Task 3: `FavoriteExpenseDatasource` — `syncAutoFavorites` 추가, `getFrequentTemplates` 제거

**Files:**
- Modify: `lib/features/expense/data/datasources/favorite_expense_datasource.dart`
- Modify (test): `test/features/expense/data/datasources/favorite_expense_datasource_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/expense/data/datasources/favorite_expense_datasource_test.dart` 의 `getFrequentTemplates` group 전체를 아래로 교체:

```dart
group('syncAutoFavorites', () {
  test('지출 없으면 자동 즐겨찾기 없음', () async {
    await datasource.syncAutoFavorites();
    final favorites = await datasource.getFavorites();
    expect(favorites.where((f) => f.isAuto), isEmpty);
  });

  test('지출 1개 → 자동 즐겨찾기 1개 추가', () async {
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 1000, category: 2, createdAt: DateTime.now()));

    await datasource.syncAutoFavorites();

    final auto = (await datasource.getFavorites()).where((f) => f.isAuto).toList();
    expect(auto.length, 1);
    expect(auto.first.amount, 1000);
    expect(auto.first.category, 2);
    expect(auto.first.isAuto, true);
  });

  test('지출 4종 → 최근 3개만 자동 즐겨찾기 유지', () async {
    final base = DateTime.now();
    // 오래된 순으로 4종 삽입
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 500, category: 4,
        createdAt: base.subtract(const Duration(days: 3))));
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 1000, category: 2,
        createdAt: base.subtract(const Duration(days: 2))));
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 3000, category: 0,
        createdAt: base.subtract(const Duration(days: 1))));
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 8000, category: 1, createdAt: base));

    await datasource.syncAutoFavorites();

    final auto = (await datasource.getFavorites())
        .where((f) => f.isAuto)
        .toList();
    expect(auto.length, 3);
    // 최신순 3개: 8000, 3000, 1000
    final amounts = auto.map((f) => f.amount).toSet();
    expect(amounts, containsAll([8000, 3000, 1000]));
    expect(amounts.contains(500), false);
  });

  test('기존 자동 즐겨찾기가 top3에서 밀리면 삭제됨', () async {
    final base = DateTime.now();
    // 먼저 1000원이 top1이었다가 밀리는 시나리오
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 1000, category: 2,
        createdAt: base.subtract(const Duration(days: 4))));
    await datasource.syncAutoFavorites();

    // 새 지출 3개가 추가돼 1000원이 4위로 밀림
    for (var i = 0; i < 3; i++) {
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: (i + 2) * 1000,
          category: i,
          createdAt: base.subtract(Duration(days: 3 - i))));
    }
    await datasource.syncAutoFavorites();

    final auto = (await datasource.getFavorites())
        .where((f) => f.isAuto)
        .toList();
    expect(auto.length, 3);
    expect(auto.any((f) => f.amount == 1000 && f.category == 2), false);
  });

  test('수동 즐겨찾기와 동일 조합 공존 가능 — 각각 별도 ID', () async {
    // 수동 즐겨찾기 먼저 추가
    await datasource.addFavorite(FavoriteExpenseEntity(
        id: 0, amount: 1000, category: 2,
        usageCount: 0, createdAt: DateTime.now()));

    // 지출 추가 후 sync
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 1000, category: 2, createdAt: DateTime.now()));
    await datasource.syncAutoFavorites();

    final all = await datasource.getFavorites();
    expect(all.length, 2); // 수동 1 + 자동 1
    expect(all.where((f) => f.isAuto).length, 1);
    expect(all.where((f) => !f.isAuto).length, 1);
    // 두 row의 ID가 다름
    expect(all[0].id, isNot(equals(all[1].id)));
  });

  test('자동 즐겨찾기 삭제 후 재sync → 여전히 top3이면 재추가됨', () async {
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 1000, category: 2, createdAt: DateTime.now()));
    await datasource.syncAutoFavorites();

    final before = (await datasource.getFavorites()).where((f) => f.isAuto).toList();
    expect(before.length, 1);
    await datasource.deleteFavorite(before.first.id); // X버튼으로 삭제

    await datasource.syncAutoFavorites(); // 다음 지출 입력 시 재sync

    final after = (await datasource.getFavorites()).where((f) => f.isAuto).toList();
    expect(after.length, 1); // 여전히 top1이므로 재추가
  });
});
```

- [ ] **Step 2: 테스트 실행 → FAIL 확인**

```bash
flutter test test/features/expense/data/datasources/favorite_expense_datasource_test.dart
```
Expected: `syncAutoFavorites` 관련 6개 테스트 FAIL (`No method named 'syncAutoFavorites'`).

- [ ] **Step 3: `FavoriteExpenseDatasource` 구현 — `getFrequentTemplates` 제거, `syncAutoFavorites` 추가**

`lib/features/expense/data/datasources/favorite_expense_datasource.dart` 에서 `getFrequentTemplates` 메서드 전체를 삭제하고, 파일 끝에 아래를 추가:

```dart
/// 최근 사용 상위 3개 (amount, category) 조합으로 자동 즐겨찾기를 동기화한다.
///
/// - 지출 추가·삭제·수정 직후 및 앱 초기 로드 시 호출
/// - top3에서 밀린 자동 즐겨찾기는 삭제, 신규 진입 조합은 isAuto=true로 삽입
/// - 수동 즐겨찾기(isAuto=false)는 변경 없음
Future<void> syncAutoFavorites() async {
  // 1. 최근 사용 순 상위 3개 고유 조합 조회
  final recentRows = await _db.customSelect(
    'SELECT amount, category FROM expenses '
    'GROUP BY amount, category '
    'ORDER BY MAX(created_at) DESC '
    'LIMIT 3',
    readsFrom: {_db.expenses},
  ).get();
  final recentCombos = recentRows
      .map((r) => (
            amount: r.read<int>('amount'),
            category: r.read<int>('category'),
          ))
      .toList();

  // 2. 현재 자동 즐겨찾기 전체 조회
  final existingAuto = await (_db.select(_db.favoriteExpenses)
        ..where((f) => f.isAuto.equals(true)))
      .get();

  // 3. top3에서 밀린 자동 즐겨찾기 삭제
  for (final row in existingAuto) {
    final stillInRecent = recentCombos
        .any((c) => c.amount == row.amount && c.category == row.category);
    if (!stillInRecent) {
      await (_db.delete(_db.favoriteExpenses)
            ..where((f) => f.id.equals(row.id)))
          .go();
    }
  }

  // 4. 아직 자동 즐겨찾기에 없는 신규 조합 추가
  // 수동 즐겨찾기(isAuto=false) 존재 여부는 체크하지 않는다 —
  // "중복 가능" 정책: auto row와 manual row는 독립 공존, 각각 ID로 삭제
  for (final combo in recentCombos) {
    final alreadyAuto = existingAuto
        .any((f) => f.amount == combo.amount && f.category == combo.category);
    if (!alreadyAuto) {
      await _db.into(_db.favoriteExpenses).insert(
        FavoriteExpensesCompanion.insert(
          amount: combo.amount,
          category: combo.category,
          isAuto: const Value(true),
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}
```

- [ ] **Step 4: 테스트 실행 → PASS 확인**

```bash
flutter test test/features/expense/data/datasources/favorite_expense_datasource_test.dart
```
Expected: 전체 PASS.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/expense/data/datasources/favorite_expense_datasource.dart \
        test/features/expense/data/datasources/favorite_expense_datasource_test.dart
git commit -m "feat(datasource): syncAutoFavorites 추가, getFrequentTemplates 제거"
```

---

## Task 4: Repository 인터페이스 / Impl 갱신

**Files:**
- Modify: `lib/features/expense/domain/repositories/favorite_expense_repository.dart`
- Modify: `lib/features/expense/data/repositories/favorite_expense_repository_impl.dart`

- [ ] **Step 1: 인터페이스 갱신**

`lib/features/expense/domain/repositories/favorite_expense_repository.dart` 전체를 교체:

```dart
import '../entities/favorite_expense.dart';

/// 즐겨찾기 지출 템플릿 저장소 인터페이스
abstract interface class FavoriteExpenseRepository {
  /// 즐겨찾기 목록을 usageCount 내림차순으로 반환 (수동 + 자동 모두 포함)
  Future<List<FavoriteExpenseEntity>> getFavorites();

  /// 수동 즐겨찾기 추가
  Future<void> addFavorite(FavoriteExpenseEntity favorite);

  /// ID로 즐겨찾기 삭제 (수동·자동 공통)
  Future<void> deleteFavorite(int id);

  /// ID의 사용 횟수 1 증가 (수동 즐겨찾기 탭 시)
  Future<void> incrementUsageCount(int id);

  /// 최근 사용 상위 3개 조합으로 자동 즐겨찾기를 동기화한다
  Future<void> syncAutoFavorites();
}
```

- [ ] **Step 2: Impl 갱신**

`lib/features/expense/data/repositories/favorite_expense_repository_impl.dart` 전체를 교체:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/favorite_expense.dart';
import '../../domain/repositories/favorite_expense_repository.dart';
import '../datasources/favorite_expense_datasource.dart';

/// 즐겨찾기 지출 템플릿 저장소 구현체
@LazySingleton(as: FavoriteExpenseRepository)
class FavoriteExpenseRepositoryImpl implements FavoriteExpenseRepository {
  final FavoriteExpenseDatasource _datasource;

  FavoriteExpenseRepositoryImpl(this._datasource);

  @override
  Future<List<FavoriteExpenseEntity>> getFavorites() =>
      _datasource.getFavorites();

  @override
  Future<void> addFavorite(FavoriteExpenseEntity favorite) =>
      _datasource.addFavorite(favorite);

  @override
  Future<void> deleteFavorite(int id) => _datasource.deleteFavorite(id);

  @override
  Future<void> incrementUsageCount(int id) =>
      _datasource.incrementUsageCount(id);

  @override
  Future<void> syncAutoFavorites() => _datasource.syncAutoFavorites();
}
```

- [ ] **Step 3: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/expense/
```
Expected: 오류 없음.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/expense/domain/repositories/favorite_expense_repository.dart \
        lib/features/expense/data/repositories/favorite_expense_repository_impl.dart
git commit -m "refactor(repository): getFrequentTemplates 제거, syncAutoFavorites 추가"
```

---

## Task 5: `GetFrequentTemplatesUseCase` 삭제 + DI 정리

**Files:**
- Delete: `lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart`
- Modify: `lib/core/di/injection.config.dart`

- [ ] **Step 1: use case 파일 삭제**

```bash
rm lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart
```

- [ ] **Step 2: `injection.config.dart`에서 import alias 제거**

파일에서 아래 두 줄(49~50번째 줄 근방)을 삭제:

```dart
import '../../features/expense/domain/usecases/get_frequent_templates_use_case.dart'
    as _i988;
```

- [ ] **Step 3: `injection.config.dart`에서 DI 등록 블록 제거**

파일에서 아래 블록(235~239번째 줄 근방)을 삭제:

```dart
  gh.lazySingleton<_i988.GetFrequentTemplatesUseCase>(
    () => _i988.GetFrequentTemplatesUseCase(
      gh<_i758.FavoriteExpenseRepository>(),
    ),
  );
```

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/core/di/injection.config.dart
```
Expected: 오류 없음.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/di/injection.config.dart
git commit -m "chore(di): GetFrequentTemplatesUseCase DI 등록 제거"
```

---

## Task 6: `SettingsRepository` — dismiss 메서드 제거 + 마이그레이션 메서드 추가

**Files:**
- Modify: `lib/features/settings/domain/repositories/settings_repository.dart`
- Modify: `lib/features/settings/data/datasources/settings_local_datasource.dart`
- Modify: `lib/features/settings/data/repositories/settings_repository_impl.dart`

- [ ] **Step 1: 인터페이스 갱신**

`lib/features/settings/domain/repositories/settings_repository.dart` 에서 아래 두 메서드를 삭제하고, 마이그레이션 메서드를 추가:

**삭제:**
```dart
  /// 세션을 초월해 영구 저장된 자동학습 숨김 키 집합을 반환한다 ("amount_category")
  Future<Set<String>> getDismissedAutoSuggestions();

  /// 자동학습 칩 숨김 키를 영구 저장한다
  Future<void> addDismissedAutoSuggestion(String key);
```

**추가 (파일 끝에):**
```dart
  /// 구버전 자동학습 dismiss 데이터를 SharedPreferences에서 일회성 삭제한다.
  /// 앱 초기 로드 시 한 번만 호출하면 된다.
  Future<void> clearLegacyDismissedSuggestions();
```

- [ ] **Step 2: `SettingsLocalDatasource` 갱신**

`lib/features/settings/data/datasources/settings_local_datasource.dart` 에서 아래 세 항목을 삭제:

```dart
  static const _dismissedAutoKey = 'dismissed_auto_suggestions';

  Future<Set<String>> getDismissedAutoSuggestions() async { ... }

  Future<void> addDismissedAutoSuggestion(String key) async { ... }
```

그리고 아래를 추가:

```dart
  static const _dismissedAutoKey = 'dismissed_auto_suggestions';

  /// 구버전 자동학습 dismiss SharedPreferences 키를 일회성 삭제
  Future<void> clearLegacyDismissedSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedAutoKey);
  }
```

- [ ] **Step 3: `SettingsRepositoryImpl` 갱신**

`lib/features/settings/data/repositories/settings_repository_impl.dart` 에서 아래 두 메서드를 삭제:

```dart
  @override
  Future<Set<String>> getDismissedAutoSuggestions() =>
      _datasource.getDismissedAutoSuggestions();

  @override
  Future<void> addDismissedAutoSuggestion(String key) =>
      _datasource.addDismissedAutoSuggestion(key);
```

그리고 아래를 추가:

```dart
  @override
  Future<void> clearLegacyDismissedSuggestions() =>
      _datasource.clearLegacyDismissedSuggestions();
```

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/settings/
```
Expected: 오류 없음.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/settings/domain/repositories/settings_repository.dart \
        lib/features/settings/data/datasources/settings_local_datasource.dart \
        lib/features/settings/data/repositories/settings_repository_impl.dart
git commit -m "refactor(settings): dismiss 메서드 제거, clearLegacyDismissedSuggestions 마이그레이션 추가"
```

---

## Task 7: `HomeState` 및 `HomeViewModel` 전면 정리

**Files:**
- Modify: `lib/features/home/presentation/viewmodels/home_view_model.dart`

### 7-A: `HomeState` 정리

- [ ] **Step 1: `frequentTemplates` / `dismissedFreqKeys` 필드 제거**

`HomeState` 클래스를 아래로 교체:

```dart
/// 홈 화면 상태
class HomeState {
  final int remainingBudget;
  final int totalBudget;
  final List<ExpenseEntity> expenses;
  final int totalAcorns;
  final int streakDays;
  final bool isLoading;

  /// 이월 배지 표시용 금액 (0이면 이월 없음)
  final int carryOver;

  /// 일요일 첫 접근 인터스티셜 트리거 여부
  final bool isNewWeek;

  /// 수동 + 자동학습 즐겨찾기 목록 (usageCount 내림차순)
  final List<FavoriteExpenseEntity> favorites;

  const HomeState({
    this.remainingBudget = 10000,
    this.totalBudget = 10000,
    this.expenses = const [],
    this.totalAcorns = 0,
    this.streakDays = 0,
    this.isLoading = true,
    this.carryOver = 0,
    this.isNewWeek = false,
    this.favorites = const [],
  });

  HomeState copyWith({
    int? remainingBudget,
    int? totalBudget,
    List<ExpenseEntity>? expenses,
    int? totalAcorns,
    int? streakDays,
    bool? isLoading,
    int? carryOver,
    bool? isNewWeek,
    List<FavoriteExpenseEntity>? favorites,
    bool clearTitle = false,
  }) {
    return HomeState(
      remainingBudget: remainingBudget ?? this.remainingBudget,
      totalBudget: totalBudget ?? this.totalBudget,
      expenses: expenses ?? this.expenses,
      totalAcorns: totalAcorns ?? this.totalAcorns,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
      carryOver: carryOver ?? this.carryOver,
      isNewWeek: isNewWeek ?? this.isNewWeek,
      favorites: favorites ?? this.favorites,
    );
  }
}
```

### 7-B: import 정리

- [ ] **Step 2: 불필요한 import 제거**

파일 상단에서 아래를 삭제:
```dart
import '../../../expense/domain/usecases/get_frequent_templates_use_case.dart';
```

아래를 추가 (없는 경우):
```dart
import '../../../expense/domain/repositories/favorite_expense_repository.dart';
```

### 7-C: `_loadData` 정리

- [ ] **Step 3: `_loadData` 내 dismiss/frequent 관련 코드 제거 + sync/migration 추가**

`_loadData` 에서 아래를 삭제:
```dart
      // 자동학습 숨김 키 로드
      final dismissedKeys =
          await settingsRepository.getDismissedAutoSuggestions();
```
```dart
      final frequentList =
          await getIt<GetFrequentTemplatesUseCase>().execute(limit: 3);
```
그리고 `state = state.copyWith(...)` 블록에서 `dismissedFreqKeys`와 `frequentTemplates` 두 줄 제거.

위젯 업데이트 블록에서 `dedupedFrequent` 계산 및 `frequentTemplates` 관련 코드를 제거하고, `favorites:` 는 `favoritesList`만 매핑:

```dart
      favorites: favoritesList
          .map((f) => {
                'id': f.id,
                'amount': f.amount,
                'category': f.category,
                'memo': f.memo,
              })
          .toList(),
```

`_loadData` 진입부(try 블록 상단)에 아래 두 줄 추가:
```dart
      // 구버전 dismiss 데이터 일회성 삭제 (기존 사용자 마이그레이션)
      await settingsRepository.clearLegacyDismissedSuggestions();
      // 앱 시작 시 자동 즐겨찾기 동기화
      await getIt<FavoriteExpenseRepository>().syncAutoFavorites();
```

### 7-D: `_watchExpenses` 정리

- [ ] **Step 4: `_watchExpenses` 리스너 내 frequent 관련 코드 제거**

리스너 내 아래를 삭제:
```dart
            final frequentList =
                await getIt<GetFrequentTemplatesUseCase>().execute(limit: 3);
            state = state.copyWith(
              favorites: favoritesList,
              frequentTemplates: frequentList,
            );
            final favoriteKeys = ...
            final dedupedFrequent = ...
```

`state.copyWith` 및 위젯 업데이트 블록을 아래로 교체:

```dart
          if (!state.isLoading) {
            final favoritesList = await getIt<GetFavoritesUseCase>().execute();
            state = state.copyWith(favorites: favoritesList);
            unawaited(
              getIt<WidgetService>().updateWidget(
                total: state.totalBudget,
                used: state.totalBudget - remaining,
                remaining: remaining,
                streak: state.streakDays,
                expenses: expenses
                    .map((e) => {
                          'category': ExpenseCategory.values[e.category].label,
                          'time': DateFormat('HH:mm').format(e.createdAt),
                          'amount': e.amount,
                        })
                    .toList(),
                catMood: state.isNewWeek
                    ? 'new_week'
                    : CharacterMood.fromRemaining(remaining, state.totalBudget).name,
                favorites: favoritesList
                    .map((f) => {
                          'id': f.id,
                          'amount': f.amount,
                          'category': f.category,
                          'memo': f.memo,
                        })
                    .toList(),
              ),
            );
          }
```

### 7-E: `addExpense` / `deleteExpense` / `updateExpense` 에 `syncAutoFavorites` 연결

- [ ] **Step 5: 지출 CUD 메서드 수정**

```dart
  /// 지출 추가 — 저장 후 자동 즐겨찾기 동기화 (awaited)
  ///
  /// ExpenseAddScreen._onSave 호출 순서:
  ///   1. addExpense (→ syncAutoFavorites: auto row 삽입 가능)
  ///   2. addFavorite (체크박스 시 → manual row 삽입)
  /// 동일 조합이 top3이면 auto+manual 두 row 공존 — 중복 허용 정책에 의한 의도된 동작
  Future<void> addExpense(ExpenseEntity expense) async {
    await getIt<AddExpenseUseCase>().execute(expense);
    // awaited: _watchExpenses 스트림 콜백이 getFavorites() 호출 전에 sync 완료되도록
    await getIt<FavoriteExpenseRepository>().syncAutoFavorites();
    ref.invalidate(calendarViewModelProvider);
  }

  /// 지출 수정 — 자동 즐겨찾기 동기화 (top3 조합이 바뀔 수 있음)
  Future<void> updateExpense(ExpenseEntity expense) async {
    await getIt<UpdateExpenseUseCase>().execute(expense);
    await getIt<FavoriteExpenseRepository>().syncAutoFavorites();
    ref.invalidate(calendarViewModelProvider);
  }

  /// 지출 삭제 — 자동 즐겨찾기 동기화 (top3 조합이 바뀔 수 있음)
  Future<void> deleteExpense(int id) async {
    await getIt<DeleteExpenseUseCase>().execute(id);
    await getIt<FavoriteExpenseRepository>().syncAutoFavorites();
    ref.invalidate(calendarViewModelProvider);
  }
```

### 7-F: `dismissAutoSuggestion` 제거

- [ ] **Step 6: `dismissAutoSuggestion` 메서드 전체 삭제**

```dart
  // 삭제 대상:
  Future<void> dismissAutoSuggestion(String key) async { ... }
```

- [ ] **Step 7: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/home/presentation/viewmodels/home_view_model.dart
```
Expected: 오류 없음.

- [ ] **Step 8: 커밋**

```bash
git add lib/features/home/presentation/viewmodels/home_view_model.dart
git commit -m "refactor(home-vm): frequentTemplates·dismissedFreqKeys 제거, syncAutoFavorites 연결, legacy migration 추가"
```

---

## Task 8: `FavoriteTemplatesSection` 위젯 — 수동/자동 칩 구분 표시

**Files:**
- Modify: `lib/features/expense/presentation/widgets/favorite_templates_section.dart`
- Modify: `test/features/expense/presentation/widgets/favorite_templates_section_test.dart`

- [ ] **Step 1: 위젯 테스트 갱신**

`test/features/expense/presentation/widgets/favorite_templates_section_test.dart` 전체를 교체:

```dart
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/presentation/widgets/favorite_templates_section.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubHomeViewModel extends HomeViewModel {
  final HomeState _stubState;
  _StubHomeViewModel(this._stubState);

  @override
  HomeState build() => _stubState;
}

void main() {
  testWidgets('즐겨찾기 없으면 칩 미표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(isLoading: false, favorites: []),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('수동 즐겨찾기(isAuto=false) 칩 1개 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 1, amount: 3500, category: 2,
                    usageCount: 3, isAuto: false,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets('자동 즐겨찾기(isAuto=true) 칩 — 2줄 라벨(카테고리+금액) 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 2, amount: 1000, category: 2,
                    usageCount: 0, isAuto: true,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsOneWidget);
    // 카테고리 라벨('카페')과 금액('1,000원') 모두 렌더됨
    expect(find.text('카페'), findsOneWidget);
    expect(find.text('1,000원'), findsOneWidget);
  });

  testWidgets('수동+자동 동일 조합 공존 시 칩 2개 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 1, amount: 1000, category: 2,
                    usageCount: 2, isAuto: false,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                  FavoriteExpenseEntity(
                    id: 2, amount: 1000, category: 2,
                    usageCount: 0, isAuto: true,
                    createdAt: DateTime.utc(2026, 4, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: 테스트 실행 → FAIL 확인**

```bash
flutter test test/features/expense/presentation/widgets/favorite_templates_section_test.dart
```
Expected: `isAuto` 관련 컴파일 오류 또는 assertion FAIL.

- [ ] **Step 3: 위젯 구현 갱신**

`lib/features/expense/presentation/widgets/favorite_templates_section.dart` 전체를 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';

/// 즐겨찾기 칩 목록 — 수동(isAuto=false)·자동(isAuto=true) 통합 표시
/// 비어 있으면 아무것도 렌더하지 않는다
class FavoriteTemplatesSection extends ConsumerWidget {
  final void Function(({int amount, int category, String memo})) onTemplateTap;

  const FavoriteTemplatesSection({super.key, required this.onTemplateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    if (homeState.isLoading) return const SizedBox.shrink();

    final favorites = homeState.favorites;
    if (favorites.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: favorites.map((fav) {
                final cat = ExpenseCategory.values[fav.category];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: fav.isAuto
                      ? _AutoChip(
                          fav: fav,
                          cat: cat,
                          isDark: isDark,
                          onTap: () => onTemplateTap((
                                amount: fav.amount,
                                category: fav.category,
                                memo: fav.memo,
                              )),
                          onDelete: () => ref
                              .read(homeViewModelProvider.notifier)
                              .deleteFavorite(fav.id),
                        )
                      : _ManualChip(
                          fav: fav,
                          cat: cat,
                          isDark: isDark,
                          onTap: () async {
                            try {
                              await ref
                                  .read(homeViewModelProvider.notifier)
                                  .incrementFavoriteUsage(fav.id);
                            } catch (_) {}
                            onTemplateTap((
                              amount: fav.amount,
                              category: fav.category,
                              memo: fav.memo,
                            ));
                          },
                          onDelete: () => ref
                              .read(homeViewModelProvider.notifier)
                              .deleteFavorite(fav.id),
                        ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// 수동 즐겨찾기 칩 — 금액 단일 라벨, 카테고리 색상 배경
class _ManualChip extends StatelessWidget {
  final dynamic fav;
  final ExpenseCategory cat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ManualChip({
    required this.fav,
    required this.cat,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Image.asset(cat.assetPath, width: 18, height: 18),
      label: Text(
        _formatAmount(fav.amount),
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextMain : AppColors.textMain,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkCard : cat.chipColor,
      deleteIconColor: isDark ? AppColors.darkTextSub : AppColors.textSub,
      onPressed: onTap,
      onDeleted: onDelete,
    );
  }
}

/// 자동학습 칩 — 카테고리명 + 금액 2줄 라벨, primaryLight 배경
class _AutoChip extends StatelessWidget {
  final dynamic fav;
  final ExpenseCategory cat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AutoChip({
    required this.fav,
    required this.cat,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Image.asset(
        cat.assetPath,
        width: 32,
        height: 32,
        color: isDark ? AppColors.darkTextMain : AppColors.textMain,
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cat.label),
          Text(
            _formatAmount(fav.amount),
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
            ),
          ),
        ],
      ),
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.primaryLight,
      deleteIconColor: isDark ? AppColors.darkTextSub : AppColors.textSub,
      onPressed: onTap,
      onDeleted: onDelete,
    );
  }
}

String _formatAmount(int amount) {
  if (amount >= 10000) {
    return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
  }
  return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}원';
}
```

- [ ] **Step 4: 테스트 실행 → PASS 확인**

```bash
flutter test test/features/expense/presentation/widgets/favorite_templates_section_test.dart
```
Expected: 4개 PASS.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/expense/presentation/widgets/favorite_templates_section.dart \
        test/features/expense/presentation/widgets/favorite_templates_section_test.dart
git commit -m "refactor(ui): FavoriteTemplatesSection — 수동·자동 칩 분리, 2줄 라벨 유지"
```

---

## Task 9: 전체 정적 분석 + 테스트 + build_runner 검증

- [ ] **Step 1: 전체 정적 분석**

```bash
flutter analyze
```
Expected: 오류 0개. 경고가 있으면 내용 확인 후 제거.

- [ ] **Step 2: 전체 테스트 실행**

```bash
flutter test
```
Expected: 전체 PASS. 실패 시 해당 Task로 돌아가 수정.

- [ ] **Step 3: build_runner 최종 실행 — 생성 코드 일관성 검증**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: 생성 파일 변경 없음. 변경이 생기면 커밋 후 다시 `flutter analyze` 재실행.

- [ ] **Step 4: 최종 커밋**

```bash
git add -A
git commit -m "chore: auto-learning refactor 완료 — 분석·테스트·build_runner 전체 통과"
```

---

## 자가 검토 체크리스트

| 항목 | Task |
|---|---|
| `FavoriteExpenses.isAuto` 컬럼 + schema v9 마이그레이션 | Task 1 |
| `FavoriteExpenseEntity.isAuto` + freezed 재생성 + mapper 갱신 | Task 2 |
| `syncAutoFavorites` 구현 — recency 기반 top3 diff 동기화 | Task 3 |
| `getFrequentTemplates` datasource·repository·impl에서 완전 제거 | Task 3, 4 |
| `GetFrequentTemplatesUseCase` 파일 삭제 + DI 등록 제거 | Task 5 |
| `getDismissedAutoSuggestions` / `addDismissedAutoSuggestion` 인터페이스·datasource·**impl** 3곳 모두 제거 | Task 6 |
| 기존 사용자 SharedPreferences 마이그레이션 (`clearLegacyDismissedSuggestions`) | Task 6, 7 |
| `addExpense` / `updateExpense` / `deleteExpense` 모두 `syncAutoFavorites` awaited 호출 | Task 7 |
| `_loadData` 진입 시 `syncAutoFavorites` 호출 | Task 7 |
| `dismissAutoSuggestion` 메서드 제거 | Task 7 |
| `HomeState.frequentTemplates` / `dismissedFreqKeys` 완전 제거 | Task 7 |
| 수동(금액 1줄) / 자동(카테고리+금액 2줄) 칩 시각 구분 | Task 8 |
| 수동+자동 동일 조합 공존 → ID 기반 독립 삭제 테스트 커버 | Task 3, 8 |
| `build_runner build` 검증 포함 | Task 9 |
