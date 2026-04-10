import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../expense/data/models/expense_mapper.dart';
import '../../../expense/domain/entities/expense.dart';

/// 캘린더 화면용 Drift 로컬 데이터 접근 객체
/// 월별 집계, 연속 성공일 계산 등 캘린더 전용 쿼리를 담당한다
@lazySingleton
class CalendarLocalDatasource {
  final AppDatabase _db;

  CalendarLocalDatasource(this._db);

  /// 특정 월의 모든 지출을 조회하여 일별로 그룹화한다
  Future<Map<DateTime, List<ExpenseEntity>>> getMonthlyExpenses({
    required int year,
    required int month,
  }) async {
    // 월의 시작일과 다음 달 시작일로 범위를 설정한다
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final rows = await (_db.select(_db.expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .get();

    // 날짜(시분초 제거)를 키로 일별 그룹화
    final Map<DateTime, List<ExpenseEntity>> grouped = {};
    for (final row in rows) {
      final entity = row.toEntity();
      final dayKey = DateTime(
        entity.createdAt.year,
        entity.createdAt.month,
        entity.createdAt.day,
      );
      grouped.putIfAbsent(dayKey, () => []).add(entity);
    }

    return grouped;
  }

  /// 특정 날짜(자정~다음 자정 미만)의 지출 목록을 조회한다
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final rows = await (_db.select(_db.expenses)
          ..where((e) => e.createdAt.isBetweenValues(start, end))
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();

    return rows.map((r) => r.toEntity()).toList();
  }

  /// 오늘까지 거슬러 올라가며 연속 성공일 수를 계산한다
  /// 성공 기준: 해당일 총 지출 합계 ≤ DailyBudgets.baseAmount (없으면 AppConstants.dailyBudget)
  /// 단, 지출이 없는 날은 연속 성공에 포함하지 않는다 (기록이 없으면 집계 대상 아님)
  Future<int> getStreakDays() async {
    final allRows = await (_db.select(_db.expenses)
          ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
        .get();

    if (allRows.isEmpty) return 0;

    // 일별 합계 Map 구성
    final Map<DateTime, int> dailyTotals = {};
    for (final row in allRows) {
      final dayKey = DateTime(
        row.createdAt.year,
        row.createdAt.month,
        row.createdAt.day,
      );
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + row.amount;
    }

    // 날짜별 effectiveBudget 조회 (fallback: AppConstants.dailyBudget)
    final budgetRows = await _db.select(_db.dailyBudgets).get();
    final Map<DateTime, int> effectiveBudgets = {};
    for (final row in budgetRows) {
      final dayKey = DateTime(row.date.year, row.date.month, row.date.day);
      effectiveBudgets[dayKey] = row.baseAmount + row.carryOver;
    }

    // 오늘부터 과거로 거슬러 올라가며 연속 성공 계산
    int streak = 0;
    DateTime cursor = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    while (true) {
      final total = dailyTotals[cursor];
      if (total == null) {
        // 지출 기록이 없는 날 — 연속 끊김
        break;
      }
      final budget = effectiveBudgets[cursor] ?? AppConstants.dailyBudget;
      if (total <= budget) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        // 예산 초과일 — 연속 끊김
        break;
      }
    }

    return streak;
  }

  /// 전체 기간에서 성공한 날(지출이 있고 예산 이하)의 수를 반환한다
  Future<int> getTotalSuccessCount() async {
    final allRows = await _db.select(_db.expenses).get();

    if (allRows.isEmpty) return 0;

    // 일별 합계 계산
    final Map<DateTime, int> dailyTotals = {};
    for (final row in allRows) {
      final dayKey = DateTime(
        row.createdAt.year,
        row.createdAt.month,
        row.createdAt.day,
      );
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + row.amount;
    }

    // 날짜별 effectiveBudget 조회 (fallback: AppConstants.dailyBudget)
    final budgetRows = await _db.select(_db.dailyBudgets).get();
    final Map<DateTime, int> effectiveBudgets = {};
    for (final row in budgetRows) {
      final dayKey = DateTime(row.date.year, row.date.month, row.date.day);
      effectiveBudgets[dayKey] = row.baseAmount + row.carryOver;
    }

    // 오늘 이전(오늘 포함)이고 해당 날 예산 이하인 날만 성공으로 집계
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return dailyTotals.entries.where((e) {
      if (e.key.isAfter(today)) return false;
      final budget = effectiveBudgets[e.key] ?? AppConstants.dailyBudget;
      return e.value <= budget;
    }).length;
  }

  /// 특정 월의 일별 baseAmount 맵을 반환한다
  /// 키: 날짜(시분초=0), 값: baseAmount (DailyBudgets row가 없는 날은 포함되지 않음)
  Future<Map<DateTime, int>> getMonthlyBaseAmounts({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);

    final rows = await (_db.select(_db.dailyBudgets)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();

    final Map<DateTime, int> result = {};
    for (final row in rows) {
      final dayKey = DateTime(row.date.year, row.date.month, row.date.day);
      result[dayKey] = row.baseAmount;
    }
    return result;
  }

  /// 특정 월의 일별 effectiveBudget(baseAmount + carryOver) 맵을 반환한다
  Future<Map<DateTime, int>> getMonthlyEffectiveBudgets(int year, int month) async {
    final rows = await (_db.select(_db.dailyBudgets)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(DateTime(year, month, 1)) &
              t.date.isSmallerThanValue(DateTime(year, month + 1, 1))))
        .get();
    return {
      for (final r in rows)
        DateTime(r.date.year, r.date.month, r.date.day): r.baseAmount + r.carryOver,
    };
  }
}
