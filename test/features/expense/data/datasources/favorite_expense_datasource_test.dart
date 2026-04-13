import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/datasources/favorite_expense_datasource.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:drift/drift.dart';
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
      await datasource.incrementUsageCount(2); // 8000원 항목 count 올리기
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
