import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/home/data/models/daily_budget_mapper.dart';
import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// DailyBudgets 테이블에 대한 Drift 로컬 데이터소스
@lazySingleton
class DailyBudgetLocalDatasource {
  final AppDatabase _db;

  DailyBudgetLocalDatasource(this._db);

  /// 특정 날짜의 예산 조회 (없으면 null)
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final row = await (_db.select(_db.dailyBudgets)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .getSingleOrNull();

    return row?.toEntity();
  }

  /// carryOver는 UseCase가 계산하여 전달 (Clean Architecture)
  Future<DailyBudgetEntity> getOrCreateTodayBudget({required int carryOver}) async {
    final today = DateTime.now();
    final existing = await getBudgetByDate(today);
    if (existing != null) return existing;

    final prefRow = await (_db.select(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    final budgetAmount = prefRow?.dailyBudget ?? AppConstants.dailyBudget;

    final id = await _db.into(_db.dailyBudgets).insert(
      DailyBudgetsCompanion.insert(
        date: DateTime(today.year, today.month, today.day),
        baseAmount: Value(budgetAmount),
        carryOver: Value(carryOver),
      ),
    );

    final row = await (_db.select(_db.dailyBudgets)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return row.toEntity();
  }

  /// 날짜 지정 버전 — 갭 처리용
  ///
  /// [baseAmount]가 제공되면 해당 금액을 사용하고,
  /// 없으면 현재 설정값으로 폴백한다 (신규 사용자 첫 날 등).
  Future<DailyBudgetEntity> getOrCreateBudgetForDate({
    required DateTime date,
    required int carryOver,
    int? baseAmount,
  }) async {
    final existing = await getBudgetByDate(date);
    if (existing != null) return existing;

    final int resolvedBaseAmount;
    if (baseAmount != null) {
      resolvedBaseAmount = baseAmount;
    } else {
      final prefRow = await (_db.select(_db.userPreferences)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      resolvedBaseAmount = prefRow?.dailyBudget ?? AppConstants.dailyBudget;
    }

    final id = await _db.into(_db.dailyBudgets).insert(
      DailyBudgetsCompanion.insert(
        date: DateTime(date.year, date.month, date.day),
        baseAmount: Value(resolvedBaseAmount),
        carryOver: Value(carryOver),
      ),
    );

    final row = await (_db.select(_db.dailyBudgets)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return row.toEntity();
  }

  /// 특정 날짜의 남은 예산 계산 (effectiveBudget - 총 지출)
  Future<int> getRemainingBudget(DateTime date) async {
    final budget = await getBudgetByDate(date);
    final effectiveBudget = (budget?.baseAmount ?? AppConstants.dailyBudget)
        + (budget?.carryOver ?? 0);

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final expenses = await (_db.select(_db.expenses)
          ..where((e) =>
              e.createdAt.isBiggerOrEqualValue(start) &
              e.createdAt.isSmallerThanValue(end)))
        .get();

    final spent = expenses.fold(0, (sum, e) => sum + e.amount);
    return effectiveBudget - spent;
  }

  /// 특정 날짜의 남은 예산을 실시간 스트림으로 구독
  Stream<int> watchRemainingBudget(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    // 지출 변동 시 자동 재계산
    return (_db.select(_db.expenses)
          ..where((e) =>
              e.createdAt.isBiggerOrEqualValue(start) &
              e.createdAt.isSmallerThanValue(end)))
        .watch()
        .asyncMap((_) => getRemainingBudget(date));
  }

  Future<DateTime?> getLastBudgetDate() async {
    final row = await (_db.select(_db.dailyBudgets)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
    return row?.date;
  }

  Future<int> getTotalExpensesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final expenses = await (_db.select(_db.expenses)
          ..where((e) =>
              e.createdAt.isBiggerOrEqualValue(start) &
              e.createdAt.isSmallerThanValue(end)))
        .get();
    return expenses.fold<int>(0, (sum, e) => sum + e.amount);
  }
}
