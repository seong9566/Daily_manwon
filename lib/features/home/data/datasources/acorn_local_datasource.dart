import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/home/data/models/acorn_mapper.dart';
import 'package:daily_manwon/features/home/domain/entities/acorn.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// 도토리 Drift 로컬 데이터소스
/// Acorns 테이블 및 Expenses 테이블을 조합하여 도토리/스트릭 로직을 처리한다
@lazySingleton
class AcornLocalDatasource {
  final AppDatabase _db;

  AcornLocalDatasource(this._db);

  /// 전체 도토리 합산 개수 조회
  Future<int> getTotalAcorns() async {
    final result = await _db.acorns.all().get();
    return result.fold<int>(0, (sum, row) => sum + row.count);
  }

  /// 도토리 추가
  Future<void> addAcorn(int count, String reason) async {
    await _db.into(_db.acorns).insert(
          AcornsCompanion.insert(
            date: DateTime.now(),
            count: count,
            reason: reason,
          ),
        );
  }

  /// 오늘부터 과거로 역추적하여 연속 성공 일수 계산
  ///
  /// 성공 기준: 해당 날짜의 Expenses 합계 ≤ dailyBudget(10000원)
  /// Expenses 테이블에서 날짜별 합계를 계산하고,
  /// 오늘부터 거슬러 올라가며 연속 성공일을 카운트한다
  Future<int> getStreakDays() async {
    // 모든 지출 레코드를 날짜 오름차순으로 조회
    final expenses = await _db.expenses.all().get();

    if (expenses.isEmpty) return 0;

    // 날짜별 지출 합계 맵 구성 (날짜 key: "yyyy-MM-dd")
    final Map<String, int> dailyTotals = {};
    for (final expense in expenses) {
      final key = _dateKey(expense.createdAt);
      dailyTotals[key] = (dailyTotals[key] ?? 0) + expense.amount;
    }

    // 오늘부터 과거로 역추적하며 연속 성공일 계산
    int streak = 0;
    DateTime cursor = _todayStart();

    while (true) {
      final key = _dateKey(cursor);
      final total = dailyTotals[key];

      // 해당 날짜에 지출 기록이 없거나 예산 초과 시 연속 종료
      if (total == null || total > AppConstants.dailyBudget) break;

      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 날짜를 "yyyy-MM-dd" 문자열 키로 변환
  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// 오늘 자정(00:00:00) 반환
  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 특정 날짜의 도토리 목록 조회 (내부 유틸)
  Future<List<AcornEntity>> getAcornsByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final rows = await (_db.select(_db.acorns)
          ..where(
            (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
          ))
        .get();

    return rows.map((r) => r.toEntity()).toList();
  }
}
