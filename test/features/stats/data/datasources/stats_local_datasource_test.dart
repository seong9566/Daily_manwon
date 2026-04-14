import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/stats/data/datasources/stats_local_datasource.dart';

void main() {
  late AppDatabase db;
  late StatsLocalDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    datasource = StatsLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('getCategoryStats', () {
    test('지출이 없을 때 빈 리스트를 반환한다', () async {
      final result = await datasource.getCategoryStats(year: 2026, month: 4);
      expect(result, isEmpty);
    });

    test('같은 달 카테고리별 합계를 내림차순으로 반환한다', () async {
      final april1 = DateTime(2026, 4, 1);
      final april2 = DateTime(2026, 4, 2);
      // food 3000+2000=5000, cafe 1500
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 3000, category: 0, createdAt: april1),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 2000, category: 0, createdAt: april2),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 1500, category: 2, createdAt: april1),
      );

      final result = await datasource.getCategoryStats(year: 2026, month: 4);

      expect(result.length, 2);
      expect(result[0].categoryIndex, 0); // food = 5000 (1위)
      expect(result[0].totalAmount, 5000);
      expect(result[0].percentage, closeTo(5000 / 6500, 0.001));
      expect(result[1].categoryIndex, 2); // cafe = 1500 (2위)
    });

    test('다른 달 지출은 포함하지 않는다', () async {
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 5000,
          category: 0,
          createdAt: DateTime(2026, 3, 31), // 3월
        ),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 1000,
          category: 1,
          createdAt: DateTime(2026, 4, 1), // 4월
        ),
      );

      final result = await datasource.getCategoryStats(year: 2026, month: 4);
      expect(result.length, 1);
      expect(result[0].totalAmount, 1000);
    });
  });

  group('getWeekdayStats', () {
    test('지출이 없을 때 빈 리스트를 반환한다', () async {
      final result = await datasource.getWeekdayStats(year: 2026, month: 4);
      expect(result, isEmpty);
    });

    test('선택된 월의 요일별 평균 지출을 반환한다', () async {
      // 2026년 4월 내 지출 삽입
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 6000,
          category: 0,
          createdAt: DateTime(2026, 4, 13), // 2026-04-13 (월)
        ),
      );

      final result = await datasource.getWeekdayStats(year: 2026, month: 4);
      expect(result, isNotEmpty);
      expect(result.any((s) => s.avgAmount > 0), isTrue);
    });

    test('다른 월의 지출은 포함하지 않는다', () async {
      // 3월 지출 삽입
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 5000,
          category: 0,
          createdAt: DateTime(2026, 3, 15),
        ),
      );

      final result = await datasource.getWeekdayStats(year: 2026, month: 4);
      expect(result, isEmpty);
    });
  });

  group('getExpenseSummary', () {
    test('지출이 없을 때 0을 반환한다', () async {
      final from = DateTime(2026, 4, 7); // 월요일
      final to = DateTime(2026, 4, 13);
      final result = await datasource.getExpenseSummary(from: from, to: to);
      expect(result.totalSpent, 0);
      expect(result.successDays, 0);
      expect(result.topCategoryIndex, isNull);
    });

    test('기간 내 총 지출, 성공일, 최다 카테고리를 반환한다', () async {
      // 4/7 food 8000 (예산 10000 → 성공)
      // 4/8 transport 12000 (예산 10000 → 실패)
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 8000,
          category: 0,
          createdAt: DateTime(2026, 4, 7, 12),
        ),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 12000,
          category: 1,
          createdAt: DateTime(2026, 4, 8, 12),
        ),
      );

      final result = await datasource.getExpenseSummary(
        from: DateTime(2026, 4, 7),
        to: DateTime(2026, 4, 9), // 7,8일 포함
        dailyBudget: 10000,
      );

      expect(result.totalSpent, 20000);
      expect(result.successDays, 1);
      expect(result.topCategoryIndex, 1); // transport 12000 최다
    });
  });

  group('getDailyAmountsForWeek', () {
    test('지출이 없는 주는 amount=0인 7개 DailyStat을 반환한다', () async {
      final weekStart = DateTime(2026, 4, 6); // 일요일
      final result = await datasource.getDailyAmountsForWeek(weekStart);

      expect(result.length, 7);
      expect(result.every((s) => s.amount == 0), isTrue);
      expect(result.first.date, weekStart);
      expect(result.last.date, DateTime(2026, 4, 12)); // 토요일
    });

    test('지출이 있는 날은 amount를 채우고 없는 날은 0으로 반환한다', () async {
      final weekStart = DateTime(2026, 4, 6);
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 5000, category: 0, createdAt: DateTime(2026, 4, 7, 12)),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 3000, category: 1, createdAt: DateTime(2026, 4, 7, 15)),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 12000, category: 0, createdAt: DateTime(2026, 4, 9, 10)),
      );

      final result = await datasource.getDailyAmountsForWeek(weekStart);

      expect(result.length, 7);
      expect(result[0].amount, 0);     // 일요일
      expect(result[1].amount, 8000);  // 월요일 5000+3000
      expect(result[2].amount, 0);     // 화요일
      expect(result[3].amount, 12000); // 수요일
      expect(result[4].amount, 0);     // 목요일
      expect(result[5].amount, 0);     // 금요일
      expect(result[6].amount, 0);     // 토요일
    });

    test('주 범위 밖의 지출은 포함하지 않는다', () async {
      final weekStart = DateTime(2026, 4, 6);
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 9000, category: 0, createdAt: DateTime(2026, 4, 5, 12)),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 7000, category: 0, createdAt: DateTime(2026, 4, 13, 12)),
      );

      final result = await datasource.getDailyAmountsForWeek(weekStart);
      expect(result.every((s) => s.amount == 0), isTrue);
    });

    test('자정 직후(00:30) 지출은 해당 날짜 로컬 기준으로 집계한다', () async {
      final weekStart = DateTime(2026, 4, 6); // 일요일 (local)
      // 월요일 00:30 local
      final mondayMorning = DateTime(2026, 4, 7, 0, 30);
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(
          amount: 4000,
          category: 0,
          createdAt: mondayMorning,
        ),
      );

      final result = await datasource.getDailyAmountsForWeek(weekStart);

      expect(result.length, 7);
      // 월요일(index 1)에 집계돼야 한다
      expect(result[1].amount, 4000); // Monday
      expect(result[0].amount, 0);    // Sunday
    });
  });

  group('getCategoryStatsForRange', () {
    test('날짜 범위 내 지출만 집계한다', () async {
      final from = DateTime(2026, 4, 6);
      final to = DateTime(2026, 4, 13);

      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 5000, category: 0, createdAt: DateTime(2026, 4, 7, 12)),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 3000, category: 0, createdAt: DateTime(2026, 4, 5, 12)),
      );
      await db.into(db.expenses).insert(
        ExpensesCompanion.insert(amount: 2000, category: 1, createdAt: DateTime(2026, 4, 13, 10)),
      );

      final result = await datasource.getCategoryStatsForRange(from, to);
      expect(result.length, 1);
      expect(result[0].categoryIndex, 0);
      expect(result[0].totalAmount, 5000);
    });
  });
}
