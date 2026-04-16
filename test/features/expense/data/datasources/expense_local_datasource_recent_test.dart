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
