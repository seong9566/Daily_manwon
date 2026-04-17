import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CalendarLocalDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    datasource = CalendarLocalDatasource(db);
  });

  tearDown(() => db.close());

  group('watchExpensesByMonth', () {
    test('초기 지출 없으면 빈 Map 방출', () async {
      final stream = datasource.watchExpensesByMonth(year: 2026, month: 4);
      final first = await stream.first;
      expect(first, isEmpty);
    });

    test('해당 월 지출 추가 시 스트림 갱신', () async {
      final stream = datasource.watchExpensesByMonth(year: 2026, month: 4);
      final emissions = <Map<DateTime, dynamic>>[];
      final sub = stream.listen(emissions.add);

      await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 3000,
        category: 0,
        createdAt: DateTime(2026, 4, 10, 12, 0),
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emissions.length, greaterThanOrEqualTo(2));
      final dayKey = DateTime(2026, 4, 10);
      expect(emissions.last[dayKey], isNotNull);
      expect(emissions.last[dayKey]!.first.amount, 3000);
    });

    test('다른 월 지출 추가 시 스트림 반응 없음', () async {
      final stream = datasource.watchExpensesByMonth(year: 2026, month: 4);
      int emitCount = 0;
      final sub = stream.listen((_) => emitCount++);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final before = emitCount;

      await db.into(db.expenses).insert(ExpensesCompanion.insert(
        amount: 5000,
        category: 1,
        createdAt: DateTime(2026, 5, 1, 9, 0), // 5월
      ));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emitCount, equals(before)); // 추가 방출 없음
    });
  });
}
