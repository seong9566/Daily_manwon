import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/data/models/expense_mapper.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// Drift SQLite를 통한 지출 데이터 로컬 접근 객체
/// 실제 DB 쿼리를 담당하며, Repository 구현체에서 호출된다
@lazySingleton
class ExpenseLocalDatasource {
  final AppDatabase _db;

  ExpenseLocalDatasource(this._db);

  /// 특정 날짜(자정~다음 자정 미만)에 해당하는 지출 목록 조회
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final rows = await (_db.select(_db.expenses)
          ..where(
            (e) => e.createdAt.isBetweenValues(start, end),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();

    return rows.map((r) => r.toEntity()).toList();
  }

  /// 새 지출을 저장하고 자동 생성된 id를 포함한 엔티티를 반환
  Future<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    final companion = expense.toCompanion();
    final id = await _db.into(_db.expenses).insert(companion);
    // 삽입된 row를 id로 다시 조회하여 createdAt 등 실제 저장값을 반환
    final row = await (_db.select(_db.expenses)
          ..where((e) => e.id.equals(id)))
        .getSingle();
    return row.toEntity();
  }

  /// 기존 지출 내용을 수정한다
  Future<void> updateExpense(ExpenseEntity expense) async {
    await (_db.update(_db.expenses)
          ..where((e) => e.id.equals(expense.id)))
        .write(
      ExpensesCompanion(
        amount: Value(expense.amount),
        category: Value(expense.category.index),
        memo: Value(expense.memo),
      ),
    );
  }

  /// id로 지출을 삭제한다
  Future<void> deleteExpense(int id) async {
    await (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();
  }

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

  /// 특정 날짜의 지출 목록을 실시간 스트림으로 구독
  Stream<List<ExpenseEntity>> watchExpensesByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return (_db.select(_db.expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }
}
