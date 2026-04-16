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
    await _db.customUpdate(
      'UPDATE favorite_expenses SET usage_count = usage_count + 1 WHERE id = ?',
      variables: [Variable.withInt(id)],
      updates: {_db.favoriteExpenses},
    );
  }

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
}
