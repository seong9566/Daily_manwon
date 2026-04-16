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

      final auto =
          (await datasource.getFavorites()).where((f) => f.isAuto).toList();
      expect(auto.length, 1);
      expect(auto.first.amount, 1000);
      expect(auto.first.category, 2);
      expect(auto.first.isAuto, true);
    });

    test('지출 4종 → 최근 3개만 자동 즐겨찾기 유지', () async {
      final base = DateTime.now();
      // 오래된 순으로 4종 삽입
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 500,
          category: 4,
          createdAt: base.subtract(const Duration(days: 3))));
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 1000,
          category: 2,
          createdAt: base.subtract(const Duration(days: 2))));
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 3000,
          category: 0,
          createdAt: base.subtract(const Duration(days: 1))));
      await db.into(db.expenses).insert(ExpensesCompanion.insert(
          amount: 8000, category: 1, createdAt: base));

      await datasource.syncAutoFavorites();

      final auto =
          (await datasource.getFavorites()).where((f) => f.isAuto).toList();
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
          amount: 1000,
          category: 2,
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

      final auto =
          (await datasource.getFavorites()).where((f) => f.isAuto).toList();
      expect(auto.length, 3);
      expect(auto.any((f) => f.amount == 1000 && f.category == 2), false);
    });

    test('수동 즐겨찾기와 동일 조합 공존 가능 — 각각 별도 ID', () async {
      // 수동 즐겨찾기 먼저 추가
      await datasource.addFavorite(FavoriteExpenseEntity(
          id: 0,
          amount: 1000,
          category: 2,
          usageCount: 0,
          createdAt: DateTime.now()));

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

      final before =
          (await datasource.getFavorites()).where((f) => f.isAuto).toList();
      expect(before.length, 1);
      await datasource.deleteFavorite(before.first.id); // X버튼으로 삭제

      await datasource.syncAutoFavorites(); // 다음 지출 입력 시 재sync

      final after =
          (await datasource.getFavorites()).where((f) => f.isAuto).toList();
      expect(after.length, 1); // 여전히 top1이므로 재추가
    });
  });
}
