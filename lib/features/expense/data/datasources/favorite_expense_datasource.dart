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
