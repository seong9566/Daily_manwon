import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:daily_manwon/features/settings/data/repositories/settings_repository_impl.dart';

class MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

void main() {
  late MockSettingsLocalDatasource mockDatasource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockSettingsLocalDatasource();
    repository = SettingsRepositoryImpl(mockDatasource);
  });

  // ─── getIsDarkMode / setIsDarkMode ──────────────────────────────────────────

  group('getIsDarkMode()', () {
    test('datasource.getIsDarkMode()를 1회 호출하고 결과를 반환한다', () async {
      when(() => mockDatasource.getIsDarkMode()).thenAnswer((_) async => true);

      final result = await repository.getIsDarkMode();

      expect(result, isTrue);
      verify(() => mockDatasource.getIsDarkMode()).called(1);
    });
  });

  group('setIsDarkMode()', () {
    test('datasource.setIsDarkMode()를 올바른 값으로 1회 호출한다', () async {
      when(() => mockDatasource.setIsDarkMode(value: any(named: 'value')))
          .thenAnswer((_) async {});

      await repository.setIsDarkMode(value: true);

      verify(() => mockDatasource.setIsDarkMode(value: true)).called(1);
    });
  });

  // ─── getDailyBudget / setDailyBudget ────────────────────────────────────────

  group('getDailyBudget()', () {
    test('datasource.getDailyBudget()를 1회 호출하고 결과를 반환한다', () async {
      when(() => mockDatasource.getDailyBudget())
          .thenAnswer((_) async => 15000);

      final result = await repository.getDailyBudget();

      expect(result, equals(15000));
      verify(() => mockDatasource.getDailyBudget()).called(1);
    });
  });

  group('setDailyBudget()', () {
    test('datasource.setDailyBudget()를 올바른 금액으로 1회 호출한다', () async {
      when(() => mockDatasource.setDailyBudget(any()))
          .thenAnswer((_) async {});

      await repository.setDailyBudget(20000);

      verify(() => mockDatasource.setDailyBudget(20000)).called(1);
    });
  });

  // ─── getCarryoverEnabled / setCarryoverEnabled ──────────────────────────────

  group('getCarryoverEnabled()', () {
    test('datasource.getCarryoverEnabled()를 1회 호출하고 결과를 반환한다', () async {
      when(() => mockDatasource.getCarryoverEnabled())
          .thenAnswer((_) async => true);

      final result = await repository.getCarryoverEnabled();

      expect(result, isTrue);
      verify(() => mockDatasource.getCarryoverEnabled()).called(1);
    });
  });

  group('setCarryoverEnabled()', () {
    test('datasource.setCarryoverEnabled()를 올바른 값으로 1회 호출한다', () async {
      when(() => mockDatasource.setCarryoverEnabled(any()))
          .thenAnswer((_) async {});

      await repository.setCarryoverEnabled(true);

      verify(() => mockDatasource.setCarryoverEnabled(true)).called(1);
    });
  });

  // ─── hasSeenNewWeekThisWeek / markNewWeekSeen ───────────────────────────────

  group('hasSeenNewWeekThisWeek()', () {
    test('datasource.hasSeenNewWeekThisWeek()를 1회 호출하고 결과를 반환한다', () async {
      when(() => mockDatasource.hasSeenNewWeekThisWeek(any()))
          .thenAnswer((_) async => false);

      final result = await repository.hasSeenNewWeekThisWeek('2024-W01');

      expect(result, isFalse);
      verify(() => mockDatasource.hasSeenNewWeekThisWeek('2024-W01')).called(1);
    });
  });

  group('markNewWeekSeen()', () {
    test('datasource.markNewWeekSeen()를 올바른 weekKey로 1회 호출한다', () async {
      when(() => mockDatasource.markNewWeekSeen(any()))
          .thenAnswer((_) async {});

      await repository.markNewWeekSeen('2024-W01');

      verify(() => mockDatasource.markNewWeekSeen('2024-W01')).called(1);
    });
  });
}
