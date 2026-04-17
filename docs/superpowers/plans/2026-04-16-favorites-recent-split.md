# Favorites / Recent Split Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** "자주 쓰는" 탭은 수동 즐겨찾기만 표시하고, "최근 내역" 탭은 최근 7일 내 지출 최대 10건을 보여주도록 변경한다. `isAuto` 컬럼 및 `syncAutoFavorites` 자동학습 로직을 전면 제거한다.

**Architecture:**
- `FavoriteExpenses` 테이블에서 `isAuto` 컬럼을 제거(schema v10). 마이그레이션 시 기존 `isAuto=true` row를 삭제하고 `alterTable`로 컬럼을 드롭한다.
- `ExpenseLocalDatasource`에 `getRecentExpenses({int limit, int days})` 메서드를 추가해 7일 내 최근 10건을 조회한다.
- `HomeState`에 `recentExpenses` 필드를 추가하고, `FavoriteTemplatesSection`의 "최근 내역" 탭이 이를 사용하도록 한다.

**Tech Stack:** Flutter, Drift (SQLite ORM, schema v10), Riverpod (Notifier), Injectable (GetIt)

---

## File Map

| 액션 | 파일 |
|---|---|
| **수정** | `lib/core/database/app_database.dart` |
| **수정** | `lib/features/expense/domain/entities/favorite_expense.dart` |
| **자동생성** | `lib/features/expense/domain/entities/favorite_expense.freezed.dart` |
| **수정** | `lib/features/expense/data/models/favorite_expense_mapper.dart` |
| **수정** | `lib/features/expense/data/datasources/favorite_expense_datasource.dart` |
| **수정** | `lib/features/expense/domain/repositories/favorite_expense_repository.dart` |
| **수정** | `lib/features/expense/data/repositories/favorite_expense_repository_impl.dart` |
| **수정** | `lib/features/expense/data/datasources/expense_local_datasource.dart` |
| **수정** | `lib/features/expense/domain/repositories/expense_repository.dart` |
| **수정** | `lib/features/expense/data/repositories/expense_repository_impl.dart` |
| **생성** | `lib/features/expense/domain/usecases/get_recent_expenses_use_case.dart` |
| **수정** | `lib/features/home/presentation/viewmodels/home_view_model.dart` |
| **수정** | `lib/features/expense/presentation/widgets/favorite_templates_section.dart` |
| **자동생성** | `lib/core/database/app_database.g.dart` |
| **자동생성** | `lib/core/di/injection.config.dart` |
| **수정** | `test/features/expense/data/datasources/favorite_expense_datasource_test.dart` |
| **수정** | `test/features/expense/presentation/widgets/favorite_templates_section_test.dart` |

---

## Task 1: DB schema v10 — FavoriteExpenses.isAuto 컬럼 제거

**Files:**
- Modify: `lib/core/database/app_database.dart`

- [ ] **Step 1: FavoriteExpenses 클래스에서 isAuto 컬럼 제거**

`lib/core/database/app_database.dart` 의 `FavoriteExpenses` 클래스를 아래로 교체:

```dart
/// 수동 즐겨찾기 지출 템플릿 테이블
/// - usageCount: 탭 횟수 (자동 정렬 기준)
class FavoriteExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();
  IntColumn get category => integer()(); // ExpenseCategory enum index
  TextColumn get memo => text().withDefault(const Constant(''))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
```

- [ ] **Step 2: schemaVersion 10으로 변경 + v10 마이그레이션 추가**

`schemaVersion`과 `migration` 전체를 아래로 교체:

```dart
@override
int get schemaVersion => 10;

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
        // v9 캐치업: is_auto 컬럼을 raw SQL로 추가한다.
        // 주의: isAuto Dart 필드는 이미 제거됐으므로 favoriteExpenses.isAuto 심볼을
        // 사용하면 컴파일 오류가 발생한다. raw SQL만 사용할 것.
        if (from < 9) {
          await m.database.customStatement(
            'ALTER TABLE favorite_expenses ADD COLUMN is_auto INTEGER NOT NULL DEFAULT 0',
          );
        }
        // schema v10: isAuto 자동학습 컬럼 제거 — auto row(isAuto=1) 먼저 삭제 후 컬럼 드롭
        // from < 9 에서 컬럼이 방금 추가됐더라도 곧바로 이 분기에서 제거된다 (v8→v10 경로).
        if (from < 10) {
          await m.database.customStatement(
            'DELETE FROM favorite_expenses WHERE is_auto = 1',
          );
          await m.alterTable(TableMigration(favoriteExpenses));
        }
      },
    );
```

- [ ] **Step 3: build_runner로 app_database.g.dart 재생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/core/database/app_database.g.dart` 재생성. `FavoriteExpense` 데이터 클래스에 `isAuto` 필드 없음.

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/core/database/
```

Expected: 오류 없음. (다른 파일에서 `isAuto` 참조로 인한 오류는 다음 Task에서 제거)

- [ ] **Step 5: 커밋**

```bash
git add lib/core/database/app_database.dart lib/core/database/app_database.g.dart
git commit -m "feat(db): FavoriteExpenses.isAuto 컬럼 제거, schema v10 마이그레이션"
```

---

## Task 2: FavoriteExpenseEntity / Mapper — isAuto 제거

**Files:**
- Modify: `lib/features/expense/domain/entities/favorite_expense.dart`
- Modify: `lib/features/expense/data/models/favorite_expense_mapper.dart`

- [ ] **Step 1: FavoriteExpenseEntity에서 isAuto 필드 제거**

`lib/features/expense/domain/entities/favorite_expense.dart` 전체를 교체:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_expense.freezed.dart';

/// 즐겨찾기 지출 템플릿 도메인 엔티티
/// - [category]: ExpenseCategory enum의 index 값
/// - [usageCount]: 탭 횟수 — 높을수록 목록 상단에 정렬
@freezed
sealed class FavoriteExpenseEntity with _$FavoriteExpenseEntity {
  const factory FavoriteExpenseEntity({
    required int id,
    required int amount,
    required int category,
    @Default('') String memo,
    @Default(0) int usageCount,
    required DateTime createdAt,
  }) = _FavoriteExpenseEntity;
}
```

- [ ] **Step 2: build_runner로 freezed 재생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/features/expense/domain/entities/favorite_expense.freezed.dart` 재생성. `isAuto` 필드 없음.

- [ ] **Step 3: Mapper에서 isAuto 제거**

`lib/features/expense/data/models/favorite_expense_mapper.dart` 전체를 교체:

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
        createdAt: createdAt,
      );
}

extension FavoriteExpenseEntityMapper on FavoriteExpenseEntity {
  FavoriteExpensesCompanion toCompanion() => FavoriteExpensesCompanion.insert(
        amount: amount,
        category: category,
        memo: Value(memo),
        createdAt: createdAt,
      );
}
```

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/expense/domain/entities/ lib/features/expense/data/models/
```

Expected: 오류 없음.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/expense/domain/entities/favorite_expense.dart \
        lib/features/expense/domain/entities/favorite_expense.freezed.dart \
        lib/features/expense/data/models/favorite_expense_mapper.dart
git commit -m "feat(entity): FavoriteExpenseEntity.isAuto 필드 제거, mapper 갱신"
```

---

## Task 3: FavoriteExpenseDatasource — syncAutoFavorites 제거 + 테스트 갱신

**Files:**
- Modify: `lib/features/expense/data/datasources/favorite_expense_datasource.dart`
- Modify: `test/features/expense/data/datasources/favorite_expense_datasource_test.dart`

- [ ] **Step 1: syncAutoFavorites group 테스트 삭제**

`test/features/expense/data/datasources/favorite_expense_datasource_test.dart` 의 `group('syncAutoFavorites', () { ... });` 블록 전체(line 90~202)를 삭제한다.

파일 최종 상태:

```dart
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/datasources/favorite_expense_datasource.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late FavoriteExpenseDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    datasource = FavoriteExpenseDatasource(db);
  });

  tearDown(() => db.close());

  group('getFavorites', () {
    test('빈 DB에서 빈 리스트 반환', () async {
      final result = await datasource.getFavorites();
      expect(result, isEmpty);
    });

    test('usageCount 내림차순으로 정렬하여 반환', () async {
      await datasource.addFavorite(
        FavoriteExpenseEntity(
          id: 0, amount: 3500, category: 2, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      await datasource.addFavorite(
        FavoriteExpenseEntity(
          id: 0, amount: 8000, category: 0, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      await datasource.incrementUsageCount(2);
      final result = await datasource.getFavorites();
      expect(result.first.amount, 8000);
    });
  });

  group('addFavorite', () {
    test('즐겨찾기 저장 후 조회 가능', () async {
      await datasource.addFavorite(
        FavoriteExpenseEntity(
          id: 0, amount: 4500, category: 2, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      final result = await datasource.getFavorites();
      expect(result.length, 1);
      expect(result.first.amount, 4500);
    });
  });

  group('deleteFavorite', () {
    test('id로 삭제 후 조회 불가', () async {
      await datasource.addFavorite(
        FavoriteExpenseEntity(
          id: 0, amount: 1500, category: 1, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      final before = await datasource.getFavorites();
      await datasource.deleteFavorite(before.first.id);
      final after = await datasource.getFavorites();
      expect(after, isEmpty);
    });
  });

  group('incrementUsageCount', () {
    test('탭 후 usageCount 1 증가', () async {
      await datasource.addFavorite(
        FavoriteExpenseEntity(
          id: 0, amount: 3500, category: 2, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      final before = await datasource.getFavorites();
      await datasource.incrementUsageCount(before.first.id);
      final after = await datasource.getFavorites();
      expect(after.first.usageCount, 1);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 → PASS 확인**

```bash
flutter test test/features/expense/data/datasources/favorite_expense_datasource_test.dart
```

Expected: 4개 PASS.

- [ ] **Step 3: FavoriteExpenseDatasource에서 syncAutoFavorites 메서드 제거**

`lib/features/expense/data/datasources/favorite_expense_datasource.dart` 에서 `syncAutoFavorites()` 메서드 전체(line 48~97)를 삭제한다.

최종 파일:

```dart
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/models/favorite_expense_mapper.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// 즐겨찾기 템플릿 로컬 접근 객체
@lazySingleton
class FavoriteExpenseDatasource {
  final AppDatabase _db;

  FavoriteExpenseDatasource(this._db);

  /// 즐겨찾기 목록 — usageCount 내림차순
  Future<List<FavoriteExpenseEntity>> getFavorites() async {
    final rows = await (_db.select(_db.favoriteExpenses)
          ..orderBy([(f) => OrderingTerm.desc(f.usageCount)]))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }

  /// 즐겨찾기 추가
  Future<void> addFavorite(FavoriteExpenseEntity favorite) async {
    await _db.into(_db.favoriteExpenses).insert(favorite.toCompanion());
  }

  /// id로 즐겨찾기 삭제
  Future<void> deleteFavorite(int id) async {
    await (_db.delete(_db.favoriteExpenses)
          ..where((f) => f.id.equals(id)))
        .go();
  }

  /// 탭 시 usageCount 1 증가
  Future<void> incrementUsageCount(int id) async {
    await _db.customUpdate(
      'UPDATE favorite_expenses SET usage_count = usage_count + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {_db.favoriteExpenses},
    );
  }
}
```

- [ ] **Step 4: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/expense/data/datasources/favorite_expense_datasource.dart
```

Expected: 오류 없음.

- [ ] **Step 5: 커밋**

```bash
git add lib/features/expense/data/datasources/favorite_expense_datasource.dart \
        test/features/expense/data/datasources/favorite_expense_datasource_test.dart
git commit -m "refactor(datasource): syncAutoFavorites 제거, isAuto 참조 제거"
```

---

## Task 4: FavoriteExpenseRepository interface/impl — syncAutoFavorites 제거

**Files:**
- Modify: `lib/features/expense/domain/repositories/favorite_expense_repository.dart`
- Modify: `lib/features/expense/data/repositories/favorite_expense_repository_impl.dart`

- [ ] **Step 1: 인터페이스에서 syncAutoFavorites 제거**

`lib/features/expense/domain/repositories/favorite_expense_repository.dart` 전체를 교체:

```dart
import '../entities/favorite_expense.dart';

/// 즐겨찾기 지출 템플릿 저장소 인터페이스
abstract interface class FavoriteExpenseRepository {
  /// 즐겨찾기 목록을 usageCount 내림차순으로 반환
  Future<List<FavoriteExpenseEntity>> getFavorites();

  /// 즐겨찾기 추가
  Future<void> addFavorite(FavoriteExpenseEntity favorite);

  /// ID로 즐겨찾기 삭제
  Future<void> deleteFavorite(int id);

  /// ID의 사용 횟수 1 증가 (탭 시)
  Future<void> incrementUsageCount(int id);
}
```

- [ ] **Step 2: Impl에서 syncAutoFavorites 제거**

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
}
```

- [ ] **Step 3: 범위 한정 분석 — 프로젝트 전체는 Task 6 완료 후 실행**

> ⚠️ **주의**: Task 3~4 완료 후 Task 6 전까지 `home_view_model.dart` 는 존재하지 않는
> `syncAutoFavorites()` 를 호출하므로 **프로젝트 전체 컴파일이 깨진다**.
> 이 시점에는 반드시 스코프를 한정하여 분석할 것. 전체 `flutter analyze` 는 Task 6 완료 후에만 실행한다.

```bash
flutter analyze lib/features/expense/domain/repositories/ \
               lib/features/expense/data/repositories/
```

Expected: 오류 없음.

- [ ] **Step 4: 커밋**

```bash
git add lib/features/expense/domain/repositories/favorite_expense_repository.dart \
        lib/features/expense/data/repositories/favorite_expense_repository_impl.dart
git commit -m "refactor(repository): syncAutoFavorites 제거"
```

---

## Task 5: ExpenseLocalDatasource — getRecentExpenses 추가 + UseCase 생성

**Files:**
- Modify: `lib/features/expense/data/datasources/expense_local_datasource.dart`
- Modify: `lib/features/expense/domain/repositories/expense_repository.dart`
- Modify: `lib/features/expense/data/repositories/expense_repository_impl.dart`
- Create: `lib/features/expense/domain/usecases/get_recent_expenses_use_case.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/features/expense/data/datasources/` 디렉토리에 `expense_local_datasource_recent_test.dart` 를 아래 내용으로 생성:

```dart
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/datasources/expense_local_datasource.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ExpenseLocalDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    datasource = ExpenseLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getRecentExpenses', () {
    test('지출 없으면 빈 리스트', () async {
      final result = await datasource.getRecentExpenses();
      expect(result, isEmpty);
    });

    test('7일 이내 지출만 반환', () async {
      final now = DateTime.now();
      // 6일 전 — 포함
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 1000, category: 0,
          createdAt: now.subtract(const Duration(days: 6))));
      // 8일 전 — 제외
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 2000, category: 1,
          createdAt: now.subtract(const Duration(days: 8))));

      final result = await datasource.getRecentExpenses();
      expect(result.length, 1);
      expect(result.first.amount, 1000);
    });

    test('최대 10건만 반환 (최신순)', () async {
      final now = DateTime.now();
      for (var i = 0; i < 12; i++) {
        await db.into(db.expenses).insert(ExpensesCompanion.insert(
            amount: (i + 1) * 100,
            category: 0,
            createdAt: now.subtract(Duration(hours: i))));
      }

      final result = await datasource.getRecentExpenses();
      expect(result.length, 10);
      // 가장 최신(100원)이 첫 번째
      expect(result.first.amount, 100);
    });

    test('최신순 정렬 확인', () async {
      final now = DateTime.now();
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 500, category: 0,
          createdAt: now.subtract(const Duration(hours: 2))));
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 1500, category: 1,
          createdAt: now.subtract(const Duration(hours: 1))));

      final result = await datasource.getRecentExpenses();
      expect(result.first.amount, 1500); // 더 최근
      expect(result.last.amount, 500);
    });

    test('정확히 7일 전 지출은 포함된다', () async {
      final now = DateTime.now();
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 3000, category: 0,
          createdAt: now.subtract(const Duration(days: 7))));

      final result = await datasource.getRecentExpenses();
      expect(result.length, 1);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 → FAIL 확인**

```bash
flutter test test/features/expense/data/datasources/expense_local_datasource_recent_test.dart
```

Expected: FAIL (`No method named 'getRecentExpenses'`).

- [ ] **Step 3: ExpenseLocalDatasource에 getRecentExpenses 추가**

`lib/features/expense/data/datasources/expense_local_datasource.dart` 의 `deleteExpense` 메서드 다음에 아래를 추가:

```dart
  /// 최근 [days]일 이내 지출을 최신순으로 최대 [limit]건 조회
  Future<List<ExpenseEntity>> getRecentExpenses({
    int limit = 10,
    int days = 7,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await (_db.select(_db.expenses)
          ..where((e) => e.createdAt.isBiggerOrEqualValue(since))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
          ..limit(limit))
        .get();
    return rows.map((r) => r.toEntity()).toList();
  }
```

- [ ] **Step 4: 테스트 실행 → PASS 확인**

```bash
flutter test test/features/expense/data/datasources/expense_local_datasource_recent_test.dart
```

Expected: 4개 PASS.

- [ ] **Step 5: ExpenseRepository 인터페이스에 getRecentExpenses 추가**

`lib/features/expense/domain/repositories/expense_repository.dart` 전체를 교체:

```dart
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';

/// 지출 데이터 접근을 위한 레포지토리 인터페이스
abstract interface class ExpenseRepository {
  /// 특정 날짜의 지출 목록을 한 번 조회한다
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date);

  /// 새 지출을 저장하고 저장된 엔티티를 반환한다
  Future<ExpenseEntity> addExpense(ExpenseEntity expense);

  /// 기존 지출을 수정한다
  Future<void> updateExpense(ExpenseEntity expense);

  /// 지출을 삭제한다
  Future<void> deleteExpense(int id);

  /// 특정 날짜의 지출 목록을 실시간으로 구독한다 (DB 변경 시 자동 방출)
  Stream<List<ExpenseEntity>> watchExpensesByDate(DateTime date);

  /// 최근 [days]일 이내 지출을 최신순으로 최대 [limit]건 조회한다
  Future<List<ExpenseEntity>> getRecentExpenses({int limit = 10, int days = 7});
}
```

- [ ] **Step 6: ExpenseRepositoryImpl에 getRecentExpenses delegate 추가**

`lib/features/expense/data/repositories/expense_repository_impl.dart` 의 `watchExpensesByDate` 오버라이드 다음에 아래를 추가:

```dart
  @override
  Future<List<ExpenseEntity>> getRecentExpenses({
    int limit = 10,
    int days = 7,
  }) {
    return _datasource.getRecentExpenses(limit: limit, days: days);
  }
```

- [ ] **Step 7: GetRecentExpensesUseCase 생성**

`lib/features/expense/domain/usecases/get_recent_expenses_use_case.dart` 를 아래 내용으로 생성:

```dart
import 'package:injectable/injectable.dart';

import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// 최근 N일 내 지출을 최대 M건 조회 (최신순)
@lazySingleton
class GetRecentExpensesUseCase {
  const GetRecentExpensesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<List<ExpenseEntity>> execute({int limit = 10, int days = 7}) =>
      _repository.getRecentExpenses(limit: limit, days: days);
}
```

- [ ] **Step 8: build_runner로 injection.config.dart 재생성**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/core/di/injection.config.dart` 재생성. `GetRecentExpensesUseCase` DI 등록 포함.

- [ ] **Step 9: 컴파일 오류 없음 확인**

```bash
flutter analyze lib/features/expense/
```

Expected: 오류 없음.

- [ ] **Step 10: 커밋**

```bash
git add lib/features/expense/data/datasources/expense_local_datasource.dart \
        lib/features/expense/domain/repositories/expense_repository.dart \
        lib/features/expense/data/repositories/expense_repository_impl.dart \
        lib/features/expense/domain/usecases/get_recent_expenses_use_case.dart \
        lib/core/di/injection.config.dart \
        test/features/expense/data/datasources/expense_local_datasource_recent_test.dart
git commit -m "feat(datasource): getRecentExpenses 추가, GetRecentExpensesUseCase 생성"
```

---

## Task 6: HomeState + HomeViewModel 갱신

**Files:**
- Modify: `lib/features/home/presentation/viewmodels/home_view_model.dart`

### 6-A: HomeState에 recentExpenses 필드 추가

- [ ] **Step 1: HomeState 클래스 갱신**

`lib/features/home/presentation/viewmodels/home_view_model.dart` 의 `HomeState` 클래스 전체를 교체:

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

  /// 수동 즐겨찾기 목록 (usageCount 내림차순)
  final List<FavoriteExpenseEntity> favorites;

  /// 최근 7일 내 지출 최대 10건 (최신순) — "최근 내역" 탭용
  final List<ExpenseEntity> recentExpenses;

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
    this.recentExpenses = const [],
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
    List<ExpenseEntity>? recentExpenses,
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
      recentExpenses: recentExpenses ?? this.recentExpenses,
    );
  }
}
```

### 6-B: import 정리

- [ ] **Step 2: GetRecentExpensesUseCase import 추가**

> ⚠️ `FavoriteExpenseRepository` import는 Step 5(6-E) 이후에 제거한다.
> 지금 제거하면 아직 남아 있는 `syncAutoFavorites()` 호출이 컴파일 오류를 유발한다.

파일 상단에 아래를 추가 (없는 경우):
```dart
import '../../../expense/domain/usecases/get_recent_expenses_use_case.dart';
```

### 6-C: _loadData 갱신

- [ ] **Step 3: _loadData에서 syncAutoFavorites + clearLegacyDismissedSuggestions 제거 + recentExpenses 로드**

`_loadData` 내 아래 두 줄 삭제:
```dart
      // 구버전 dismiss 데이터 일회성 삭제 (기존 사용자 마이그레이션)
      await settingsRepository.clearLegacyDismissedSuggestions();
      // 앱 시작 시 자동 즐겨찾기 동기화
      await getIt<FavoriteExpenseRepository>().syncAutoFavorites();
```

> `clearLegacyDismissedSuggestions`는 삭제된 자동학습 기능의 마이그레이션 코드다.
> 해당 SharedPreferences 키는 이 리팩토링 이후 앱이 다시는 쓰지 않으므로 함께 제거한다.

`favoritesList` 로드 직후에 `recentExpenses` 로드 추가:
```dart
      final favoritesList = await getIt<GetFavoritesUseCase>().execute();
      final recentList = await getIt<GetRecentExpensesUseCase>().execute();
```

`state = state.copyWith(...)` 블록에 `recentExpenses: recentList` 추가:
```dart
      state = state.copyWith(
        remainingBudget: remaining,
        totalBudget: totalBudget,
        expenses: expenses,
        totalAcorns: acorns,
        streakDays: streak,
        isLoading: false,
        carryOver: carryOver,
        isNewWeek: isNewWeek,
        favorites: favoritesList,
        recentExpenses: recentList,
      );
```

### 6-D: _watchExpenses 갱신

- [ ] **Step 4: _watchExpenses 리스너 내 recentExpenses 갱신 추가**

리스너 내 아래 블록:
```dart
          if (!state.isLoading) {
            final favoritesList = await getIt<GetFavoritesUseCase>().execute();
            state = state.copyWith(favorites: favoritesList);
```

를 아래로 교체:
```dart
          if (!state.isLoading) {
            final favoritesList = await getIt<GetFavoritesUseCase>().execute();
            final recentList = await getIt<GetRecentExpensesUseCase>().execute();
            state = state.copyWith(
              favorites: favoritesList,
              recentExpenses: recentList,
            );
```

### 6-E: addExpense / updateExpense / deleteExpense — syncAutoFavorites 제거

- [ ] **Step 5: 지출 CUD 메서드에서 syncAutoFavorites 제거**

`addExpense` 메서드를 아래로 교체:
```dart
  /// 지출 추가
  Future<void> addExpense(ExpenseEntity expense) async {
    await getIt<AddExpenseUseCase>().execute(expense);
    ref.invalidate(calendarViewModelProvider);
  }
```

`updateExpense` 메서드를 아래로 교체:
```dart
  /// 지출 수정
  Future<void> updateExpense(ExpenseEntity expense) async {
    await getIt<UpdateExpenseUseCase>().execute(expense);
    ref.invalidate(calendarViewModelProvider);
  }
```

`deleteExpense` 메서드를 아래로 교체:
```dart
  /// 지출 삭제
  Future<void> deleteExpense(int id) async {
    await getIt<DeleteExpenseUseCase>().execute(id);
    ref.invalidate(calendarViewModelProvider);
  }
```

### 6-F: FavoriteExpenseRepository import 제거 + clearLegacyDismissedSuggestions 관련 파일 정리

- [ ] **Step 6: home_view_model.dart에서 FavoriteExpenseRepository import 제거**

> 이 시점에서는 `syncAutoFavorites()` 호출이 모두 제거됐으므로 import가 완전히 미사용 상태다.

`lib/features/home/presentation/viewmodels/home_view_model.dart` 상단에서 아래를 삭제:
```dart
import '../../../expense/domain/repositories/favorite_expense_repository.dart';
```

- [ ] **Step 7: SettingsRepository 인터페이스에서 clearLegacyDismissedSuggestions 제거**

`lib/features/settings/domain/repositories/settings_repository.dart` 에서 아래 메서드 선언을 삭제:
```dart
  /// 구버전 자동학습 dismiss 데이터를 SharedPreferences에서 일회성 삭제한다.
  /// 앱 초기 로드 시 한 번만 호출하면 된다.
  Future<void> clearLegacyDismissedSuggestions();
```

- [ ] **Step 8: SettingsLocalDatasource에서 clearLegacyDismissedSuggestions 제거**

`lib/features/settings/data/datasources/settings_local_datasource.dart` 에서 아래 상수와 메서드를 삭제:
```dart
  static const _dismissedAutoKey = 'dismissed_auto_suggestions';

  /// 구버전 자동학습 dismiss SharedPreferences 키를 일회성 삭제
  Future<void> clearLegacyDismissedSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedAutoKey);
  }
```

- [ ] **Step 9: SettingsRepositoryImpl에서 clearLegacyDismissedSuggestions 제거**

`lib/features/settings/data/repositories/settings_repository_impl.dart` 에서 아래 오버라이드를 삭제:
```dart
  @override
  Future<void> clearLegacyDismissedSuggestions() =>
      _datasource.clearLegacyDismissedSuggestions();
```

- [ ] **Step 10: 컴파일 오류 없음 확인 (전체 프로젝트)**

```bash
flutter analyze
```

Expected: 오류 없음. Task 3~5 이후 처음으로 전체 분석이 통과해야 한다.

- [ ] **Step 11: 커밋**

```bash
git add lib/features/home/presentation/viewmodels/home_view_model.dart \
        lib/features/settings/domain/repositories/settings_repository.dart \
        lib/features/settings/data/datasources/settings_local_datasource.dart \
        lib/features/settings/data/repositories/settings_repository_impl.dart
git commit -m "refactor(home-vm): recentExpenses 추가, syncAutoFavorites+clearLegacyDismissed 제거"
```

---

## Task 7: FavoriteTemplatesSection 위젯 갱신

**Files:**
- Modify: `lib/features/expense/presentation/widgets/favorite_templates_section.dart`
- Modify: `test/features/expense/presentation/widgets/favorite_templates_section_test.dart`

### 7-A: 위젯 테스트 갱신

- [ ] **Step 1: 테스트 전체를 교체**

`test/features/expense/presentation/widgets/favorite_templates_section_test.dart` 전체를 교체:

```dart
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
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
  testWidgets('즐겨찾기 없고 최근 내역 없으면 첫 탭에 칩 미표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [],
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
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('즐겨찾기 1개 표시', (tester) async {
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
                    usageCount: 3,
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

  testWidgets('즐겨찾기 2개 표시', (tester) async {
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
                    usageCount: 2,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                  FavoriteExpenseEntity(
                    id: 2, amount: 3000, category: 0,
                    usageCount: 1,
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

  testWidgets('"최근 내역" 탭 전환 후 recentExpenses 칩 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [
                  ExpenseEntity(
                    id: 10, amount: 4500, category: 1,
                    memo: '점심',
                    createdAt: DateTime.utc(2026, 4, 16),
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

    // 기본 탭("자주 쓰는")에는 칩 없음
    expect(find.byType(InputChip), findsNothing);

    // "최근 내역" 탭 탭
    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 빈 상태 — 안내 문구 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [],
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

    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsNothing);
    expect(find.text('최근 내역이 없습니다.'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 테스트 실행 → FAIL 확인**

```bash
flutter test test/features/expense/presentation/widgets/favorite_templates_section_test.dart
```

Expected: `isAuto` 참조 컴파일 오류 또는 `recentExpenses` 미존재로 FAIL.

### 7-B: 위젯 구현 갱신

- [ ] **Step 3: FavoriteTemplatesSection 위젯 전체를 교체**

`lib/features/expense/presentation/widgets/favorite_templates_section.dart` 전체를 교체:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';

/// 즐겨찾기("자주 쓰는") / 최근 내역 탭 섹션
/// - 자주 쓰는: 수동 즐겨찾기 칩 (삭제 버튼 포함)
/// - 최근 내역: 최근 7일 내 지출 최대 10건 칩 (탭으로 재사용만 가능)
class FavoriteTemplatesSection extends ConsumerStatefulWidget {
  final void Function(({int amount, int category, String memo})) onTemplateTap;

  const FavoriteTemplatesSection({super.key, required this.onTemplateTap});

  @override
  ConsumerState<FavoriteTemplatesSection> createState() =>
      _FavoriteTemplatesSectionState();
}

class _FavoriteTemplatesSectionState
    extends ConsumerState<FavoriteTemplatesSection> {
  int _selectedTabIndex = 0; // 0: 자주 쓰는, 1: 최근 내역

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    if (homeState.isLoading) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 탭 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildTab('자주 쓰는', 0, textMainColor, textSubColor),
              const SizedBox(width: 16),
              _buildTab('최근 내역', 1, textMainColor, textSubColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 내용 영역
        SizedBox(
          height: 70,
          child: _selectedTabIndex == 0
              ? _buildFavoritesTab(homeState, isDark)
              : _buildRecentTab(homeState, isDark),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTab(String title, int index, Color mainColor, Color subColor) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? mainColor : subColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 32,
            color: isSelected ? mainColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── "자주 쓰는" 탭 ────────────────────────────────────────────────────────

  Widget _buildFavoritesTab(HomeState homeState, bool isDark) {
    final favorites = homeState.favorites;
    if (favorites.isEmpty) {
      return Center(
        child: Text(
          '즐겨찾기가 없습니다.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSub),
        ),
      );
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: favorites.map((fav) {
        final cat = ExpenseCategory.values[fav.category];
        final title = fav.memo.isNotEmpty ? fav.memo : cat.label;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: _TemplateChip(
              title: title,
              amount: fav.amount,
              cat: cat,
              isDark: isDark,
              onTap: () async {
                try {
                  await ref
                      .read(homeViewModelProvider.notifier)
                      .incrementFavoriteUsage(fav.id);
                } catch (_) {}
                widget.onTemplateTap((
                  amount: fav.amount,
                  category: fav.category,
                  memo: fav.memo,
                ));
              },
              onDelete: () => ref
                  .read(homeViewModelProvider.notifier)
                  .deleteFavorite(fav.id),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── "최근 내역" 탭 ────────────────────────────────────────────────────────

  Widget _buildRecentTab(HomeState homeState, bool isDark) {
    final recentExpenses = homeState.recentExpenses;
    if (recentExpenses.isEmpty) {
      return Center(
        child: Text(
          '최근 내역이 없습니다.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSub),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recentExpenses.length,
      itemBuilder: (context, index) {
        final expense = recentExpenses[index];
        final cat = ExpenseCategory.values[expense.category];
        final title = expense.memo.isNotEmpty ? expense.memo : cat.label;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: _TemplateChip(
              title: title,
              amount: expense.amount,
              cat: cat,
              isDark: isDark,
              onTap: () => widget.onTemplateTap((
                amount: expense.amount,
                category: expense.category,
                memo: expense.memo,
              )),
              // onDelete 없음 — 최근 내역은 탭으로 재사용만 가능
            ),
          ),
        );
      },
    );
  }
}

// ── 공통 템플릿 칩 ─────────────────────────────────────────────────────────

class _TemplateChip extends StatelessWidget {
  final String title;
  final int amount;
  final ExpenseCategory cat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TemplateChip({
    required this.title,
    required this.amount,
    required this.cat,
    required this.isDark,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Image.asset(cat.assetPath, width: 24, height: 24),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
            ),
          ),
          Text(
            _formatAmount(amount),
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      side: BorderSide(
        color: isDark ? AppColors.white : AppColors.black,
        width: 1.5,
      ),
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
git commit -m "refactor(ui): FavoriteTemplatesSection — 자주 쓰는(수동)/최근 내역(7일) 분리, isAuto 제거"
```

---

## Task 8: 전체 정적 분석 + 테스트 + build_runner 검증

- [ ] **Step 1: 전체 정적 분석**

```bash
flutter analyze
```

Expected: 오류 0개. 경고가 있으면 확인 후 제거.

- [ ] **Step 2: 전체 테스트 실행**

```bash
flutter test
```

Expected: 전체 PASS. 실패 시 해당 Task로 돌아가 수정.

- [ ] **Step 3: build_runner 최종 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: 생성 파일 변경 없음. 변경이 생기면 커밋 후 `flutter analyze` 재실행.

- [ ] **Step 4: 최종 커밋 (build_runner 생성 파일 포함)**

```bash
git add lib/core/database/app_database.g.dart \
        lib/features/expense/domain/entities/favorite_expense.freezed.dart \
        lib/core/di/injection.config.dart
git commit -m "chore: favorites/recent split 리팩토링 완료 — isAuto 제거, recentExpenses 분리"
```

---

## 자가 검토 체크리스트

| 항목 | Task |
|---|---|
| `FavoriteExpenses.isAuto` 컬럼 제거 + schema v10 마이그레이션 (isAuto=true row 삭제 + alterTable) | Task 1 |
| `FavoriteExpenseEntity.isAuto` 필드 제거 + freezed 재생성 + mapper 갱신 | Task 2 |
| `syncAutoFavorites` datasource·repository·impl 3곳 완전 제거 | Task 3, 4 |
| datasource 테스트에서 `syncAutoFavorites` group 제거 | Task 3 |
| `getRecentExpenses` datasource → repository → use case 계층 완전 구현 | Task 5 |
| `getRecentExpenses` 단위 테스트 (7일 필터, limit 10, 최신순) | Task 5 |
| `HomeState.recentExpenses` 필드 추가 + `_loadData` / `_watchExpenses` 양쪽에서 갱신 | Task 6 |
| `addExpense` / `updateExpense` / `deleteExpense` 에서 `syncAutoFavorites` 호출 제거 | Task 6 |
| `FavoriteExpenseRepository` import 제거 (Step 6-F Step 6, syncAutoFavorites 호출 완전 제거 후) | Task 6 |
| `clearLegacyDismissedSuggestions` SettingsRepository·Impl·Datasource·HomeViewModel 4곳 완전 제거 | Task 6 |
| "자주 쓰는" 탭 `isAuto` 분기 제거 — 모든 즐겨찾기가 수동이므로 항상 `incrementFavoriteUsage` 호출 | Task 7 |
| "최근 내역" 탭이 `homeState.recentExpenses` 사용 (기존 `homeState.expenses` 아님) | Task 7 |
| 위젯 테스트에 "최근 내역" 탭 전환 시나리오 포함 | Task 7 |
| `build_runner` 검증 포함 | Task 8 |
