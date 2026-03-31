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
  ///
  /// [date] 생략 시 오늘 날짜로 기록된다. 전날 평가 결과를 기록할 때는 해당 날짜를 전달한다.
  Future<void> addAcorn(int count, String reason, {DateTime? date}) async {
    await _db.into(_db.acorns).insert(
          AcornsCompanion.insert(
            date: date ?? DateTime.now(),
            count: count,
            reason: reason,
          ),
        );
  }

  /// 어제부터 과거로 역추적하여 연속 성공 일수 계산
  ///
  /// 성공 기준: 해당 날짜에 도토리가 1개 이상 기록된 경우 (S-20a 도토리 지급 후 유효)
  /// 오늘은 아직 진행 중이므로 어제부터 역추적한다.
  Future<int> getStreakDays() async {
    int streak = 0;
    DateTime cursor = _todayStart().subtract(const Duration(days: 1));

    while (true) {
      final acorns = await getAcornsByDate(cursor);
      if (acorns.isEmpty) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

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
