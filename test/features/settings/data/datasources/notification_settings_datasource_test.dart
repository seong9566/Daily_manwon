import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/settings/data/datasources/notification_settings_datasource.dart';
import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';

void main() {
  late AppDatabase db;
  late NotificationSettingsDatasource datasource;

  setUp(() {
    db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    datasource = NotificationSettingsDatasource(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ─── getSettings ────────────────────────────────────────────────────────────

  group('getSettings()', () {
    test('row가 없으면 lunchEnabled=false, dinnerEnabled=false 기본값을 반환한다', () async {
      final result = await datasource.getSettings();

      expect(result.lunchEnabled, isFalse);
      expect(result.dinnerEnabled, isFalse);
    });

    test('저장된 row가 있으면 해당 값을 반환한다', () async {
      const entity = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 11,
        lunchTimeMinute: 30,
        dinnerEnabled: false,
        dinnerTimeHour: 19,
        dinnerTimeMinute: 0,
      );
      await datasource.saveSettings(entity);

      final result = await datasource.getSettings();

      expect(result.lunchEnabled, isTrue);
      expect(result.lunchTimeHour, equals(11));
      expect(result.lunchTimeMinute, equals(30));
      expect(result.dinnerEnabled, isFalse);
      expect(result.dinnerTimeHour, equals(19));
      expect(result.dinnerTimeMinute, equals(0));
    });

    test('저녁 알림 비활성화 상태도 올바르게 반환한다', () async {
      const entity = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 12,
        lunchTimeMinute: 0,
        dinnerEnabled: false,
        dinnerTimeHour: 20,
        dinnerTimeMinute: 0,
      );
      await datasource.saveSettings(entity);

      final result = await datasource.getSettings();

      expect(result.dinnerEnabled, isFalse);
    });
  });

  // ─── saveSettings ───────────────────────────────────────────────────────────

  group('saveSettings()', () {
    test('최초 저장 시 row가 생성된다', () async {
      const entity = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 9,
        lunchTimeMinute: 0,
        dinnerEnabled: true,
        dinnerTimeHour: 18,
        dinnerTimeMinute: 30,
      );

      await datasource.saveSettings(entity);

      final result = await datasource.getSettings();
      expect(result, equals(entity));
    });

    test('두 번 저장하면 upsert로 최신 값이 반영된다', () async {
      const first = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 12,
        lunchTimeMinute: 0,
        dinnerEnabled: true,
        dinnerTimeHour: 20,
        dinnerTimeMinute: 0,
      );
      const second = NotificationSettingsEntity(
        lunchEnabled: false,
        lunchTimeHour: 8,
        lunchTimeMinute: 30,
        dinnerEnabled: false,
        dinnerTimeHour: 19,
        dinnerTimeMinute: 0,
      );

      await datasource.saveSettings(first);
      await datasource.saveSettings(second);

      final result = await datasource.getSettings();
      expect(result.lunchEnabled, isFalse);
      expect(result.lunchTimeHour, equals(8));
      expect(result.lunchTimeMinute, equals(30));
      expect(result.dinnerEnabled, isFalse);
    });

    test('시간이 한 자리수여도 HH:mm 형식으로 저장/복원된다', () async {
      const entity = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 9,
        lunchTimeMinute: 5,
        dinnerEnabled: true,
        dinnerTimeHour: 8,
        dinnerTimeMinute: 0,
      );
      await datasource.saveSettings(entity);

      final result = await datasource.getSettings();
      expect(result.lunchTimeHour, equals(9));
      expect(result.lunchTimeMinute, equals(5));
      expect(result.dinnerTimeHour, equals(8));
    });
  });
}
