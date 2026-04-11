import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/settings/data/datasources/settings_local_datasource.dart';

void main() {
  late AppDatabase db;
  late SettingsLocalDatasource datasource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    datasource = SettingsLocalDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ─── getIsDarkMode / setIsDarkMode ──────────────────────────────────────────

  group('getIsDarkMode()', () {
    test('row가 없으면 false를 반환한다', () async {
      final result = await datasource.getIsDarkMode();
      expect(result, isFalse);
    });

    test('true 저장 후 조회하면 true를 반환한다', () async {
      await datasource.setIsDarkMode(value: true);

      final result = await datasource.getIsDarkMode();
      expect(result, isTrue);
    });

    test('false로 변경 후 조회하면 false를 반환한다', () async {
      await datasource.setIsDarkMode(value: true);
      await datasource.setIsDarkMode(value: false);

      final result = await datasource.getIsDarkMode();
      expect(result, isFalse);
    });
  });

  // ─── getDailyBudget / setDailyBudget ────────────────────────────────────────

  group('getDailyBudget()', () {
    test('row가 없으면 10000을 반환한다', () async {
      final result = await datasource.getDailyBudget();
      expect(result, equals(10000));
    });

    test('저장된 값을 올바르게 반환한다', () async {
      await datasource.setDailyBudget(15000);

      final result = await datasource.getDailyBudget();
      expect(result, equals(15000));
    });

    test('여러 번 저장하면 최신 값이 반영된다', () async {
      await datasource.setDailyBudget(20000);
      await datasource.setDailyBudget(5000);

      final result = await datasource.getDailyBudget();
      expect(result, equals(5000));
    });
  });

  // ─── getCarryoverEnabled / setCarryoverEnabled ──────────────────────────────

  group('getCarryoverEnabled()', () {
    test('row가 없으면 false를 반환한다', () async {
      final result = await datasource.getCarryoverEnabled();
      expect(result, isFalse);
    });

    test('true 저장 후 조회하면 true를 반환한다', () async {
      await datasource.setCarryoverEnabled(true);

      final result = await datasource.getCarryoverEnabled();
      expect(result, isTrue);
    });

    test('false로 변경 후 조회하면 false를 반환한다', () async {
      await datasource.setCarryoverEnabled(true);
      await datasource.setCarryoverEnabled(false);

      final result = await datasource.getCarryoverEnabled();
      expect(result, isFalse);
    });
  });

  // ─── hasSeenNewWeekThisWeek / markNewWeekSeen ───────────────────────────────

  group('hasSeenNewWeekThisWeek()', () {
    test('미확인 weekKey는 false를 반환한다', () async {
      final result = await datasource.hasSeenNewWeekThisWeek('2024-W01');
      expect(result, isFalse);
    });

    test('markNewWeekSeen 후 조회하면 true를 반환한다', () async {
      await datasource.markNewWeekSeen('2024-W01');

      final result = await datasource.hasSeenNewWeekThisWeek('2024-W01');
      expect(result, isTrue);
    });

    test('다른 weekKey는 영향을 받지 않는다', () async {
      await datasource.markNewWeekSeen('2024-W01');

      final result = await datasource.hasSeenNewWeekThisWeek('2024-W02');
      expect(result, isFalse);
    });
  });

  // ─── getIsOnboardingCompleted / setIsOnboardingCompleted ────────────────────

  group('getIsOnboardingCompleted()', () {
    test('row가 없으면 false를 반환한다', () async {
      final result = await datasource.getIsOnboardingCompleted();
      expect(result, isFalse);
    });

    test('true 저장 후 조회하면 true를 반환한다', () async {
      await datasource.setIsOnboardingCompleted(value: true);

      final result = await datasource.getIsOnboardingCompleted();
      expect(result, isTrue);
    });
  });
}
