import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/weekday_stat.dart';

/// 통계 화면용 Drift 로컬 데이터 접근 객체
/// Expenses + DailyBudgets 테이블을 읽기 전용으로 집계한다
@lazySingleton
class StatsLocalDatasource {
  final AppDatabase _db;

  StatsLocalDatasource(this._db);

  /// [from] 이상 [to] 미만 기간의 카테고리별 지출 합계를 내림차순으로 반환한다
  Future<List<CategoryStat>> getCategoryStatsForRange(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.customSelect(
      'SELECT category, SUM(amount) AS total '
      'FROM expenses '
      'WHERE created_at >= ? AND created_at < ? '
      'GROUP BY category '
      'ORDER BY total DESC',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
      readsFrom: {_db.expenses},
    ).get();

    if (rows.isEmpty) return [];

    final grandTotal =
        rows.fold<int>(0, (sum, r) => sum + r.read<int>('total'));
    return rows.map((r) {
      final total = r.read<int>('total');
      return CategoryStat(
        categoryIndex: r.read<int>('category'),
        totalAmount: total,
        percentage: grandTotal > 0 ? total / grandTotal : 0.0,
      );
    }).toList();
  }

  /// 특정 월의 카테고리별 지출 합계를 내림차순으로 반환한다
  Future<List<CategoryStat>> getCategoryStats({
    required int year,
    required int month,
  }) => getCategoryStatsForRange(
        DateTime(year, month, 1),
        DateTime(year, month + 1, 1),
      );

  /// 해당 주(일~토) 7일의 일별 지출을 반환한다
  /// [weekStart]: 해당 주 일요일 00:00:00 (로컬 시간)
  /// [반환]: 지출 없는 날은 amount=0으로 채워 항상 7개 반환
  Future<List<DailyStat>> getDailyAmountsForWeek(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));

    final expenses = await (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.createdAt.isBiggerOrEqualValue(weekStart) &
                e.createdAt.isSmallerThanValue(weekEnd),
          ))
        .get();

    // Dart 로컬 날짜 기준 집계 — SQLite strftime UTC 오류 방지
    final Map<String, int> dayMap = {};
    for (final e in expenses) {
      final key = _localDayKey(e.createdAt.toLocal());
      dayMap[key] = (dayMap[key] ?? 0) + e.amount;
    }

    return List.generate(7, (i) {
      // DST 안전: Duration 덧셈 대신 날짜 필드로 직접 생성
      final date = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + i,
      );
      return DailyStat(date: date, amount: dayMap[_localDayKey(date)] ?? 0);
    });
  }

  /// 로컬 날짜를 'yyyy-MM-dd' 문자열 key로 변환한다
  String _localDayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  /// 지정된 월의 요일별 일평균 지출을 반환한다
  ///
  /// 요일 인덱스: 0=일, 1=월 … 6=토 (SQLite %w 동일)
  /// Dart-layer에서 로컬 날짜 기준 집계 — SQLite unixepoch UTC 오류 방지
  Future<List<WeekdayStat>> getWeekdayStats({
    required int year,
    required int month,
  }) async {
    final from = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 1);

    final expenses = await (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.createdAt.isBiggerOrEqualValue(from) &
                e.createdAt.isSmallerThanValue(monthEnd),
          ))
        .get();

    if (expenses.isEmpty) return [];

    // 로컬 날짜별 일 합계 및 요일 매핑
    final Map<String, int> dayTotals = {};
    final Map<String, int> dayWeekday = {};
    for (final e in expenses) {
      final local = e.createdAt.toLocal();
      final key = _localDayKey(local);
      dayTotals[key] = (dayTotals[key] ?? 0) + e.amount;
      // Dart weekday: 1=Mon…7=Sun → % 7 → 0=Sun, 1=Mon…6=Sat
      dayWeekday[key] ??= local.weekday % 7;
    }

    // 요일별 금액 리스트 집계
    final Map<int, List<int>> weekdayAmounts = {};
    for (final entry in dayTotals.entries) {
      final wd = dayWeekday[entry.key]!;
      (weekdayAmounts[wd] ??= []).add(entry.value);
    }

    return weekdayAmounts.entries
        .map(
          (e) => WeekdayStat(
            weekday: e.key,
            avgAmount:
                (e.value.fold(0, (s, v) => s + v) / e.value.length).round(),
          ),
        )
        .toList()
      ..sort((a, b) => a.weekday.compareTo(b.weekday));
  }

  /// [from] 이상 [to] 미만 기간의 지출 요약을 반환한다
  Future<ExpenseSummary> getExpenseSummary({
    required DateTime from,
    required DateTime to,
    int dailyBudget = AppConstants.dailyBudget,
  }) async {
    final expenses = await (_db.select(_db.expenses)
          ..where(
            (e) =>
                e.createdAt.isBiggerOrEqualValue(from) &
                e.createdAt.isSmallerThanValue(to),
          ))
        .get();

    if (expenses.isEmpty) {
      return const ExpenseSummary(
        totalSpent: 0,
        totalDays: 0,
        successDays: 0,
        topCategoryIndex: null,
      );
    }

    final Map<DateTime, int> dailyTotals = {};
    final Map<int, int> categoryTotals = {};
    for (final e in expenses) {
      final dayKey = DateTime(
        e.createdAt.year,
        e.createdAt.month,
        e.createdAt.day,
      );
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + e.amount;
      categoryTotals[e.category] =
          (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final budgetRows = await (_db.select(_db.dailyBudgets)
          ..where(
            (b) =>
                b.date.isBiggerOrEqualValue(from) &
                b.date.isSmallerThanValue(to),
          ))
        .get();
    final Map<DateTime, int> effectiveBudgets = {
      for (final b in budgetRows)
        DateTime(b.date.year, b.date.month, b.date.day):
            b.baseAmount + b.carryOver,
    };

    final totalSpent = dailyTotals.values.fold(0, (s, v) => s + v);
    final successDays = dailyTotals.entries.where((entry) {
      final budget = effectiveBudgets[entry.key] ?? dailyBudget;
      return entry.value <= budget;
    }).length;

    int? topCategory;
    if (categoryTotals.isNotEmpty) {
      topCategory = categoryTotals.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return ExpenseSummary(
      totalSpent: totalSpent,
      totalDays: dailyTotals.length,
      successDays: successDays,
      topCategoryIndex: topCategory,
    );
  }
}
