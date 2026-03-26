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

  /// 오늘 예산을 조회하거나 없으면 기본값으로 생성
  Future<DailyBudgetEntity> getOrCreateTodayBudget() async {
    final today = DateTime.now();
    final existing = await getBudgetByDate(today);
    if (existing != null) return existing;

    // 기본 예산 생성
    final id = await _db.into(_db.dailyBudgets).insert(
          DailyBudgetsCompanion.insert(
            date: DateTime(today.year, today.month, today.day),
            baseAmount: const Value(AppConstants.dailyBudget),
            carryOver: const Value(0),
          ),
        );

    final row = await (_db.select(_db.dailyBudgets)
          ..where((t) => t.id.equals(id)))
        .getSingle();

    return row.toEntity();
  }

  /// 특정 날짜의 남은 예산 계산 (baseAmount + carryOver - 총 지출)
  Future<int> getRemainingBudget(DateTime date) async {
    final budget = await getBudgetByDate(date);
    final total =
        (budget?.baseAmount ?? AppConstants.dailyBudget) +
        (budget?.carryOver ?? 0);

    // 해당 날짜 지출 합계 조회
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final expenses = await (_db.select(_db.expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end)))
        .get();

    final spent = expenses.fold(0, (sum, e) => sum + e.amount);
    return total - spent;
  }

  /// 특정 날짜의 남은 예산을 실시간 스트림으로 구독
  Stream<int> watchRemainingBudget(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    // 지출 변동 시 자동 재계산
    return (_db.select(_db.expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end)))
        .watch()
        .asyncMap((_) => getRemainingBudget(date));
  }
}
