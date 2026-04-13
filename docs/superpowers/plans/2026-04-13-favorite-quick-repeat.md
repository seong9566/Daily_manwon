# Favorite Template + 빠른 반복 입력 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 바텀시트에 수동 즐겨찾기(⭐) + 자동학습 추천 칩을 추가하고, 홈 지출 목록에 ↩ 반복 버튼을 추가하여 반복 지출을 탭 한 번으로 입력할 수 있도록 한다.

**Architecture:** `FavoriteExpenses` Drift 테이블(schema v8)을 추가해 수동 즐겨찾기를 저장한다. 자동학습은 `Expenses` 테이블 GROUP BY 집계로 도출(새 테이블 없음). 바텀시트 상단에 `FavoriteTemplatesSection`을 삽입하고, `ExpenseListItem`에 `onRepeat` 콜백을 추가한다.

**Tech Stack:** Drift (customSelect + migration v8), freezed, injectable, flutter_riverpod 3.x, mocktail (테스트)

---

## 파일 맵

### 신규 생성
```
lib/
├── features/expense/
│   ├── domain/entities/favorite_expense.dart         # FavoriteExpenseEntity (freezed)
│   ├── domain/repositories/favorite_expense_repository.dart  # 인터페이스
│   ├── domain/usecases/get_favorites_use_case.dart
│   ├── domain/usecases/add_favorite_use_case.dart
│   ├── domain/usecases/delete_favorite_use_case.dart
│   ├── domain/usecases/increment_favorite_usage_use_case.dart
│   ├── domain/usecases/get_frequent_templates_use_case.dart  # 자동학습
│   ├── data/datasources/favorite_expense_datasource.dart
│   ├── data/models/favorite_expense_mapper.dart
│   ├── data/repositories/favorite_expense_repository_impl.dart
│   └── presentation/widgets/favorite_templates_section.dart

test/features/expense/
├── data/datasources/favorite_expense_datasource_test.dart
├── domain/usecases/get_favorites_use_case_test.dart
├── domain/usecases/add_favorite_use_case_test.dart
└── presentation/widgets/favorite_templates_section_test.dart
```

### 수정
```
lib/
├── core/database/app_database.dart                   # FavoriteExpenses 테이블 + v8 마이그레이션
├── features/expense/
│   ├── presentation/screens/expense_add_screen.dart  # FavoriteTemplatesSection 삽입
└── features/home/
    ├── presentation/widgets/expense_list_item.dart   # onRepeat 콜백 + ↩ 버튼
    └── presentation/viewmodels/home_view_model.dart  # repeatExpense() 추가
```

---

## Task 1: DB 테이블 추가 + 마이그레이션 (schema v7 → v8)

**Files:**
- Modify: `lib/core/database/app_database.dart`

- [ ] **Step 1-1: FavoriteExpenses 테이블 클래스 추가**

`lib/core/database/app_database.dart` 의 `NotificationSettings` 클래스 아래에 추가:

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

- [ ] **Step 1-2: `@DriftDatabase` tables 목록에 FavoriteExpenses 추가**

```dart
@DriftDatabase(tables: [
  Expenses,
  DailyBudgets,
  Acorns,
  Achievements,
  UserPreferences,
  NotificationSettings,
  FavoriteExpenses,  // 추가
])
class AppDatabase extends _$AppDatabase {
```

- [ ] **Step 1-3: schemaVersion을 8로 올리고 마이그레이션 추가**

```dart
@override
int get schemaVersion => 8;

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
    if (from < 8) await m.createTable(favoriteExpenses);  // 추가
  },
);
```

- [ ] **Step 1-4: build_runner 실행**

```bash
cd /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon
dart run build_runner build --delete-conflicting-outputs
```

Expected: `app_database.g.dart` 재생성 — `FavoriteExpense` row 타입, `FavoriteExpensesCompanion` 생성 확인

- [ ] **Step 1-5: 커밋**

```bash
git add lib/core/database/app_database.dart lib/core/database/app_database.g.dart
git commit -m "feat(db): FavoriteExpenses 테이블 추가 및 schema v8 마이그레이션"
```

---

## Task 2: FavoriteExpenseEntity (Domain)

**Files:**
- Create: `lib/features/expense/domain/entities/favorite_expense.dart`

- [ ] **Step 2-1: freezed 엔티티 파일 생성**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_expense.freezed.dart';

@freezed
sealed class FavoriteExpenseEntity with _$FavoriteExpenseEntity {
  const factory FavoriteExpenseEntity({
    required int id,
    required int amount,
    required int category,   // ExpenseCategory.index
    @Default('') String memo,
    @Default(0) int usageCount,
    required DateTime createdAt,
  }) = _FavoriteExpenseEntity;
}
```

- [ ] **Step 2-2: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `favorite_expense.freezed.dart` 생성

- [ ] **Step 2-3: 커밋**

```bash
git add lib/features/expense/domain/entities/favorite_expense.dart \
        lib/features/expense/domain/entities/favorite_expense.freezed.dart
git commit -m "feat(expense): FavoriteExpenseEntity freezed 엔티티 추가"
```

---

## Task 3: Mapper + Datasource

**Files:**
- Create: `lib/features/expense/data/models/favorite_expense_mapper.dart`
- Create: `lib/features/expense/data/datasources/favorite_expense_datasource.dart`
- Test: `test/features/expense/data/datasources/favorite_expense_datasource_test.dart`

- [ ] **Step 3-1: Mapper 작성**

`lib/features/expense/data/models/favorite_expense_mapper.dart`:

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

- [ ] **Step 3-2: Datasource 테스트 작성 후 실행 (실패 확인)**

`test/features/expense/data/datasources/favorite_expense_datasource_test.dart`:

```dart
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/datasources/favorite_expense_datasource.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:drift/native_database.dart';
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
        const FavoriteExpenseEntity(
          id: 0, amount: 3500, category: 2, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      await datasource.addFavorite(
        const FavoriteExpenseEntity(
          id: 0, amount: 8000, category: 0, usageCount: 0,
          createdAt: DateTime.utc(2026, 4, 1),
        ),
      );
      await datasource.incrementUsageCount(2); // 8000원 항목 count 올리기
      final result = await datasource.getFavorites();
      expect(result.first.amount, 8000);
    });
  });

  group('addFavorite', () {
    test('즐겨찾기 저장 후 조회 가능', () async {
      await datasource.addFavorite(
        const FavoriteExpenseEntity(
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
        const FavoriteExpenseEntity(
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
        const FavoriteExpenseEntity(
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

  group('getFrequentTemplates', () {
    test('최근 30일 지출에서 상위 3개 집계', () async {
      final now = DateTime.now();
      // expenses 테이블에 직접 INSERT
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
            amount: 3500, category: 2, createdAt: now));
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
            amount: 3500, category: 2, createdAt: now));
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
            amount: 8000, category: 0, createdAt: now));

      final result = await datasource.getFrequentTemplates(limit: 3);
      expect(result.first['amount'], 3500);
      expect(result.first['frequency'], 2);
    });
  });
}
```

```bash
flutter test test/features/expense/data/datasources/favorite_expense_datasource_test.dart
```
Expected: FAIL (FavoriteExpenseDatasource not found)

- [ ] **Step 3-3: Datasource 구현**

`lib/features/expense/data/datasources/favorite_expense_datasource.dart`:

```dart
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/models/favorite_expense_mapper.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// 즐겨찾기 + 자동학습 템플릿 로컬 접근 객체
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
    await (_db.update(_db.favoriteExpenses)
          ..where((f) => f.id.equals(id)))
        .write(
      CustomExpression<int>('usage_count = usage_count + 1'),
    );
  }

  /// 최근 30일 지출을 (금액, 카테고리) 기준 집계 — 자동학습용
  Future<List<Map<String, int>>> getFrequentTemplates({int limit = 3}) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final query = _db.customSelect(
      'SELECT amount, category, COUNT(*) AS frequency '
      'FROM expenses '
      'WHERE created_at >= ? '
      'GROUP BY amount, category '
      'ORDER BY frequency DESC '
      'LIMIT ?',
      variables: [
        Variable.withDateTime(thirtyDaysAgo),
        Variable.withInt(limit),
      ],
      readsFrom: {_db.expenses},
    );
    final rows = await query.get();
    return rows
        .map((row) => {
              'amount': row.read<int>('amount'),
              'category': row.read<int>('category'),
              'frequency': row.read<int>('frequency'),
            })
        .toList();
  }
}
```

- [ ] **Step 3-4: 테스트 재실행 (통과 확인)**

```bash
flutter test test/features/expense/data/datasources/favorite_expense_datasource_test.dart
```
Expected: PASS (5 tests)

- [ ] **Step 3-5: 커밋**

```bash
git add lib/features/expense/data/models/favorite_expense_mapper.dart \
        lib/features/expense/data/datasources/favorite_expense_datasource.dart \
        test/features/expense/data/datasources/favorite_expense_datasource_test.dart
git commit -m "feat(expense): FavoriteExpense mapper, datasource 추가"
```

---

## Task 4: Repository 인터페이스 + 구현체

**Files:**
- Create: `lib/features/expense/domain/repositories/favorite_expense_repository.dart`
- Create: `lib/features/expense/data/repositories/favorite_expense_repository_impl.dart`

- [ ] **Step 4-1: Repository 인터페이스 작성**

`lib/features/expense/domain/repositories/favorite_expense_repository.dart`:

```dart
import '../entities/favorite_expense.dart';

abstract class FavoriteExpenseRepository {
  Future<List<FavoriteExpenseEntity>> getFavorites();
  Future<void> addFavorite(FavoriteExpenseEntity favorite);
  Future<void> deleteFavorite(int id);
  Future<void> incrementUsageCount(int id);
  Future<List<Map<String, int>>> getFrequentTemplates({int limit = 3});
}
```

- [ ] **Step 4-2: Repository 구현체 작성**

`lib/features/expense/data/repositories/favorite_expense_repository_impl.dart`:

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/favorite_expense.dart';
import '../../domain/repositories/favorite_expense_repository.dart';
import '../datasources/favorite_expense_datasource.dart';

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
  Future<List<Map<String, int>>> getFrequentTemplates({int limit = 3}) =>
      _datasource.getFrequentTemplates(limit: limit);
}
```

- [ ] **Step 4-3: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `injection.config.dart` 에 `FavoriteExpenseDatasource`, `FavoriteExpenseRepositoryImpl` 등록 확인

- [ ] **Step 4-4: 커밋**

```bash
git add lib/features/expense/domain/repositories/favorite_expense_repository.dart \
        lib/features/expense/data/repositories/favorite_expense_repository_impl.dart \
        lib/core/di/injection.config.dart
git commit -m "feat(expense): FavoriteExpenseRepository 인터페이스 및 구현체 추가"
```

---

## Task 5: Use Cases

**Files:**
- Create: `lib/features/expense/domain/usecases/get_favorites_use_case.dart`
- Create: `lib/features/expense/domain/usecases/add_favorite_use_case.dart`
- Create: `lib/features/expense/domain/usecases/delete_favorite_use_case.dart`
- Create: `lib/features/expense/domain/usecases/increment_favorite_usage_use_case.dart`
- Create: `lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart`
- Test: `test/features/expense/domain/usecases/get_favorites_use_case_test.dart`
- Test: `test/features/expense/domain/usecases/add_favorite_use_case_test.dart`

- [ ] **Step 5-1: Use Case 테스트 작성 후 실행 (실패 확인)**

`test/features/expense/domain/usecases/get_favorites_use_case_test.dart`:

```dart
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/favorite_expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/get_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteExpenseRepository extends Mock
    implements FavoriteExpenseRepository {}

void main() {
  late MockFavoriteExpenseRepository repository;
  late GetFavoritesUseCase useCase;

  setUp(() {
    repository = MockFavoriteExpenseRepository();
    useCase = GetFavoritesUseCase(repository);
  });

  test('repository에서 즐겨찾기 목록 반환', () async {
    final favorites = [
      const FavoriteExpenseEntity(
        id: 1, amount: 3500, category: 2, usageCount: 5,
        createdAt: DateTime.utc(2026, 4, 1),
      ),
    ];
    when(() => repository.getFavorites()).thenAnswer((_) async => favorites);

    final result = await useCase.execute();

    expect(result, favorites);
    verify(() => repository.getFavorites()).called(1);
  });
}
```

`test/features/expense/domain/usecases/add_favorite_use_case_test.dart`:

```dart
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/favorite_expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteExpenseRepository extends Mock
    implements FavoriteExpenseRepository {}

void main() {
  late MockFavoriteExpenseRepository repository;
  late AddFavoriteUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      const FavoriteExpenseEntity(
        id: 0, amount: 0, category: 0, usageCount: 0,
        createdAt: DateTime.utc(2026),
      ),
    );
  });

  setUp(() {
    repository = MockFavoriteExpenseRepository();
    useCase = AddFavoriteUseCase(repository);
  });

  test('repository.addFavorite 호출', () async {
    when(() => repository.addFavorite(any())).thenAnswer((_) async {});

    await useCase.execute(
      amount: 3500,
      category: 2,
      memo: '',
    );

    verify(() => repository.addFavorite(any())).called(1);
  });
}
```

```bash
flutter test test/features/expense/domain/usecases/
```
Expected: FAIL (use cases not found)

- [ ] **Step 5-2: Use Case 구현**

`lib/features/expense/domain/usecases/get_favorites_use_case.dart`:
```dart
import 'package:injectable/injectable.dart';
import '../entities/favorite_expense.dart';
import '../repositories/favorite_expense_repository.dart';

@lazySingleton
class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);
  final FavoriteExpenseRepository _repository;

  Future<List<FavoriteExpenseEntity>> execute() => _repository.getFavorites();
}
```

`lib/features/expense/domain/usecases/add_favorite_use_case.dart`:
```dart
import 'package:injectable/injectable.dart';
import '../entities/favorite_expense.dart';
import '../repositories/favorite_expense_repository.dart';

@lazySingleton
class AddFavoriteUseCase {
  const AddFavoriteUseCase(this._repository);
  final FavoriteExpenseRepository _repository;

  Future<void> execute({
    required int amount,
    required int category,
    String memo = '',
  }) =>
      _repository.addFavorite(
        FavoriteExpenseEntity(
          id: 0,
          amount: amount,
          category: category,
          memo: memo,
          createdAt: DateTime.now(),
        ),
      );
}
```

`lib/features/expense/domain/usecases/delete_favorite_use_case.dart`:
```dart
import 'package:injectable/injectable.dart';
import '../repositories/favorite_expense_repository.dart';

@lazySingleton
class DeleteFavoriteUseCase {
  const DeleteFavoriteUseCase(this._repository);
  final FavoriteExpenseRepository _repository;

  Future<void> execute(int id) => _repository.deleteFavorite(id);
}
```

`lib/features/expense/domain/usecases/increment_favorite_usage_use_case.dart`:
```dart
import 'package:injectable/injectable.dart';
import '../repositories/favorite_expense_repository.dart';

@lazySingleton
class IncrementFavoriteUsageUseCase {
  const IncrementFavoriteUsageUseCase(this._repository);
  final FavoriteExpenseRepository _repository;

  Future<void> execute(int id) => _repository.incrementUsageCount(id);
}
```

`lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart`:
```dart
import 'package:injectable/injectable.dart';
import '../repositories/favorite_expense_repository.dart';

@lazySingleton
class GetFrequentTemplatesUseCase {
  const GetFrequentTemplatesUseCase(this._repository);
  final FavoriteExpenseRepository _repository;

  /// [limit]개까지 자동학습 추천 반환 — 각 항목: {amount, category, frequency}
  Future<List<Map<String, int>>> execute({int limit = 3}) =>
      _repository.getFrequentTemplates(limit: limit);
}
```

- [ ] **Step 5-3: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5-4: 테스트 재실행 (통과 확인)**

```bash
flutter test test/features/expense/domain/usecases/
```
Expected: PASS (2 tests)

- [ ] **Step 5-5: 커밋**

```bash
git add lib/features/expense/domain/usecases/ \
        lib/core/di/injection.config.dart \
        test/features/expense/domain/usecases/
git commit -m "feat(expense): Favorite 관련 Use Case 5종 추가"
```

---

## Task 6: FavoriteTemplatesSection 위젯

**Files:**
- Create: `lib/features/expense/presentation/widgets/favorite_templates_section.dart`
- Test: `test/features/expense/presentation/widgets/favorite_templates_section_test.dart`

- [ ] **Step 6-1: 위젯 테스트 작성 후 실행 (실패 확인)**

`test/features/expense/presentation/widgets/favorite_templates_section_test.dart`:

```dart
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/presentation/widgets/favorite_templates_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('즐겨찾기가 없으면 섹션 미표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((_) async => []),
          frequentTemplatesProvider.overrideWith((_) async => []),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(onTemplateTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FavoriteTemplatesSection), findsOneWidget);
    // 칩이 없어야 함
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('수동 즐겨찾기 칩 표시', (tester) async {
    final favorites = [
      const FavoriteExpenseEntity(
        id: 1, amount: 3500, category: 2, usageCount: 3,
        createdAt: DateTime.utc(2026, 4, 1),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((_) async => favorites),
          frequentTemplatesProvider.overrideWith((_) async => []),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(onTemplateTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ActionChip), findsOneWidget);
  });
}
```

```bash
flutter test test/features/expense/presentation/widgets/favorite_templates_section_test.dart
```
Expected: FAIL (FavoriteTemplatesSection not found)

- [ ] **Step 6-2: FavoriteTemplatesSection 구현**

`lib/features/expense/presentation/widgets/favorite_templates_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/favorite_expense.dart';
import '../../domain/usecases/get_favorites_use_case.dart';
import '../../domain/usecases/get_frequent_templates_use_case.dart';
import '../../domain/usecases/increment_favorite_usage_use_case.dart';

/// 수동 즐겨찾기 + 자동학습 추천 칩 목록
/// 모두 비어 있으면 아무것도 렌더하지 않는다
class FavoriteTemplatesSection extends ConsumerWidget {
  /// 칩 탭 시 호출 — amount, category, memo 전달
  final void Function(({int amount, int category, String memo})) onTemplateTap;

  const FavoriteTemplatesSection({super.key, required this.onTemplateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final freqAsync = ref.watch(frequentTemplatesProvider);

    return favAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (favorites) => freqAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (frequent) {
          // 자동학습에서 수동 즐겨찾기와 중복 제거
          final favoriteKeys = favorites
              .map((f) => '${f.amount}_${f.category}')
              .toSet();
          final deduped = frequent
              .where((t) =>
                  !favoriteKeys.contains('${t['amount']}_${t['category']}'))
              .toList();

          if (favorites.isEmpty && deduped.isEmpty) {
            return const SizedBox.shrink();
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 수동 즐겨찾기 (⭐ 표시)
                      ...favorites.map((fav) {
                        final cat = ExpenseCategory.values[fav.category];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Text(cat.emoji,
                                style: const TextStyle(fontSize: 14)),
                            label: Text(
                              '⭐ ${_formatAmount(fav.amount)}',
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
                            onPressed: () {
                              getIt<IncrementFavoriteUsageUseCase>()
                                  .execute(fav.id);
                              onTemplateTap((
                                amount: fav.amount,
                                category: fav.category,
                                memo: fav.memo,
                              ));
                            },
                          ),
                        );
                      }),
                      // 자동학습 추천 (중복 제거된 것만)
                      ...deduped.map((t) {
                        final cat =
                            ExpenseCategory.values[t['category']!];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Text(cat.emoji,
                                style: const TextStyle(fontSize: 14)),
                            label: Text(
                              _formatAmount(t['amount']!),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.textSub,
                              ),
                            ),
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.primaryLight,
                            onPressed: () {
                              onTemplateTap((
                                amount: t['amount']!,
                                category: t['category']!,
                                memo: '',
                              ));
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
    }
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}원';
  }
}

/// 수동 즐겨찾기 프로바이더
final favoritesProvider =
    FutureProvider<List<FavoriteExpenseEntity>>((ref) async {
  return getIt<GetFavoritesUseCase>().execute();
});

/// 자동학습 추천 프로바이더
final frequentTemplatesProvider =
    FutureProvider<List<Map<String, int>>>((ref) async {
  return getIt<GetFrequentTemplatesUseCase>().execute(limit: 3);
});
```

- [ ] **Step 6-3: 테스트 재실행 (통과 확인)**

```bash
flutter test test/features/expense/presentation/widgets/favorite_templates_section_test.dart
```
Expected: PASS (2 tests)

- [ ] **Step 6-4: 커밋**

```bash
git add lib/features/expense/presentation/widgets/favorite_templates_section.dart \
        test/features/expense/presentation/widgets/favorite_templates_section_test.dart
git commit -m "feat(expense): FavoriteTemplatesSection 위젯 추가 (수동+자동학습 칩)"
```

---

## Task 7: ExpenseAddScreen 통합

**Files:**
- Modify: `lib/features/expense/presentation/screens/expense_add_screen.dart`

- [ ] **Step 7-1: `_ExpenseAddBottomSheetState`에 `_applyTemplate` 메서드 추가**

`expense_add_screen.dart` 의 `_isSaving` 선언 아래에 추가:

```dart
/// 즐겨찾기/자동학습 칩 탭 시 금액·카테고리 자동 채움
void _applyTemplate(({int amount, int category, String memo}) template) {
  setState(() {
    _amountString = template.amount.toString();
    _selectedCategory = ExpenseCategory.values[template.category];
  });
}
```

- [ ] **Step 7-2: build 메서드 안 카테고리 선택기 위에 `FavoriteTemplatesSection` 삽입**

`expense_add_screen.dart` 의 `const SizedBox(height: 12),` (드래그 핸들 아래 첫 번째) 뒤, `Flexible` 위에 추가:

```dart
// ── 즐겨찾기 / 자동학습 칩 ──────────────────────
if (widget.expense == null) // 새 지출 모드에서만 표시
  FavoriteTemplatesSection(onTemplateTap: _applyTemplate),
```

파일 상단 import에 추가:
```dart
import '../widgets/favorite_templates_section.dart';
```

- [ ] **Step 7-3: 저장 버튼 아래 "⭐ 즐겨찾기에 추가" 체크박스 추가**

`_ExpenseAddBottomSheetState` 에 상태 변수 추가:
```dart
bool _addToFavorite = false;
```

`_onSave` 메서드의 `addExpense` 호출 직후 (Navigator.pop 전)에 추가:
```dart
if (_addToFavorite) {
  await getIt<AddFavoriteUseCase>().execute(
    amount: _amount,
    category: _selectedCategory.index,
  );
  // 즐겨찾기 프로바이더 무효화 — 다음 열릴 때 최신 목록 반영
  ref.invalidate(favoritesProvider);
}
```

build 메서드의 저장 버튼 아래에 추가:
```dart
if (widget.expense == null)
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Checkbox(
        value: _addToFavorite,
        onChanged: (v) => setState(() => _addToFavorite = v ?? false),
      ),
      Text(
        '즐겨찾기에 추가',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  ),
```

import에 추가:
```dart
import '../../../../core/di/injection.dart';
import '../../domain/usecases/add_favorite_use_case.dart';
```

- [ ] **Step 7-4: 앱 실행 후 바텀시트 동작 확인**

```bash
flutter run
```

확인 항목:
- 지출 입력 바텀시트 열었을 때 즐겨찾기 칩 영역 표시
- 칩 탭 시 금액·카테고리 자동 채워짐
- "즐겨찾기에 추가" 체크 후 저장 시 다음 열기에서 칩 표시
- 편집 모드에서는 즐겨찾기 섹션 미표시

- [ ] **Step 7-5: 커밋**

```bash
git add lib/features/expense/presentation/screens/expense_add_screen.dart
git commit -m "feat(expense): 바텀시트에 즐겨찾기 칩 + 추가 체크박스 통합"
```

---

## Task 8: ExpenseListItem ↩ 반복 버튼

**Files:**
- Modify: `lib/features/home/presentation/widgets/expense_list_item.dart`
- Test: `test/features/home/presentation/widgets/expense_list_item_test.dart`

- [ ] **Step 8-1: 테스트 작성 후 실행 (실패 확인)**

`test/features/home/presentation/widgets/expense_list_item_test.dart`:

```dart
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/home/presentation/widgets/expense_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final expense = ExpenseEntity(
    id: 1, amount: 3500, category: 2, memo: '',
    createdAt: DateTime(2026, 4, 13, 10, 30),
  );

  testWidgets('onRepeat null이면 반복 버튼 미표시', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(expense: expense, onTap: () {}),
        ),
      ),
    );
    expect(find.text('↩'), findsNothing);
  });

  testWidgets('onRepeat 제공 시 반복 버튼 표시', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(
            expense: expense,
            onTap: () {},
            onRepeat: () {},
          ),
        ),
      ),
    );
    expect(find.text('↩'), findsOneWidget);
  });

  testWidgets('반복 버튼 탭 시 onRepeat 호출', (tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(
            expense: expense,
            onTap: () {},
            onRepeat: () => called = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('↩'));
    expect(called, isTrue);
  });
}
```

```bash
flutter test test/features/home/presentation/widgets/expense_list_item_test.dart
```
Expected: FAIL (onRepeat parameter not found)

- [ ] **Step 8-2: ExpenseListItem에 onRepeat 추가**

`lib/features/home/presentation/widgets/expense_list_item.dart` 수정:

```dart
class ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback? onTap;
  final VoidCallback? onRepeat;   // 추가

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
    this.onRepeat,               // 추가
  });
```

build 메서드의 금액 Text 뒤에 추가:

```dart
// 금액
Text(
  '-${CurrencyFormatter.formatNumberOnly(expense.amount)}',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
),
// ↩ 반복 버튼 (onRepeat이 제공된 경우에만 표시)
if (onRepeat != null) ...[
  const SizedBox(width: 8),
  GestureDetector(
    onTap: onRepeat,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.chipEtc,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '↩',
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkTextSub : AppColors.textSub,
        ),
      ),
    ),
  ),
],
```

- [ ] **Step 8-3: 테스트 재실행 (통과 확인)**

```bash
flutter test test/features/home/presentation/widgets/expense_list_item_test.dart
```
Expected: PASS (3 tests)

- [ ] **Step 8-4: 커밋**

```bash
git add lib/features/home/presentation/widgets/expense_list_item.dart \
        test/features/home/presentation/widgets/expense_list_item_test.dart
git commit -m "feat(home): ExpenseListItem에 ↩ 반복 버튼 추가"
```

---

## Task 9: HomeViewModel.repeatExpense() + 홈 화면 연결

**Files:**
- Modify: `lib/features/home/presentation/viewmodels/home_view_model.dart`
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

- [ ] **Step 9-1: HomeViewModel에 repeatExpense 추가**

`home_view_model.dart` 의 `deleteExpense` 메서드 아래에 추가:

```dart
/// 기존 지출과 동일한 내용을 현재 시각으로 새로 저장한다
Future<void> repeatExpense(ExpenseEntity expense) async {
  await addExpense(
    ExpenseEntity(
      id: 0,
      amount: expense.amount,
      category: expense.category,
      memo: expense.memo,
      createdAt: DateTime.now(),
    ),
  );
}
```

- [ ] **Step 9-2: HomeScreen에서 ExpenseListItem에 onRepeat 연결**

`lib/features/home/presentation/screens/home_screen.dart` 에서 `ExpenseListItem` 사용 부분을 찾아 `onRepeat` 추가:

```dart
ExpenseListItem(
  expense: expense,
  onTap: () => showExpenseAddBottomSheet(context, expense: expense),
  onRepeat: () =>
      ref.read(homeViewModelProvider.notifier).repeatExpense(expense),
),
```

- [ ] **Step 9-3: 앱 실행 후 전체 흐름 확인**

```bash
flutter run
```

확인 항목:
- 홈 화면 지출 목록 각 항목에 ↩ 버튼 표시
- ↩ 탭 시 동일 금액/카테고리로 새 지출 즉시 추가
- 잔액 즉시 갱신

- [ ] **Step 9-4: 전체 테스트 실행**

```bash
flutter test
```
Expected: All PASS

- [ ] **Step 9-5: 최종 커밋**

```bash
git add lib/features/home/presentation/viewmodels/home_view_model.dart \
        lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat(home): HomeViewModel.repeatExpense() 추가 및 홈 화면 연결"
```
