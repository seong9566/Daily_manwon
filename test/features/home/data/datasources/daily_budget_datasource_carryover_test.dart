import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/home/data/datasources/daily_budget_local_datasource.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DailyBudgetLocalDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    datasource = DailyBudgetLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('updateCarryOverForDate', () {
    test('존재하는 날짜의 carryOver를 갱신하면 DB 값이 바뀐다', () async {
      final date = DateTime(2024, 1, 15);
      // 예산 row 생성
      await db.into(db.dailyBudgets).insert(
        DailyBudgetsCompanion.insert(
          date: date,
          baseAmount: const Value(10000),
          carryOver: const Value(0),
        ),
      );

      // carryOver 갱신
      await datasource.updateCarryOverForDate(date, 3000);

      // DB에서 직접 조회하여 확인
      final updated = await datasource.getBudgetByDate(date);
      expect(updated, isNotNull);
      expect(updated!.carryOver, 3000);
    });

    test('존재하지 않는 날짜를 대상으로 호출해도 에러 없이 silently pass한다', () async {
      final nonExistentDate = DateTime(2024, 6, 1);

      // 에러 없이 완료되어야 한다
      await expectLater(
        datasource.updateCarryOverForDate(nonExistentDate, 5000),
        completes,
      );

      // DB에 해당 날짜 row가 생성되지 않아야 한다
      final result = await datasource.getBudgetByDate(nonExistentDate);
      expect(result, isNull);
    });
  });
}
