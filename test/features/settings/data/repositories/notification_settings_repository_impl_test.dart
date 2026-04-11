import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/settings/data/datasources/notification_settings_datasource.dart';
import 'package:daily_manwon/features/settings/data/repositories/notification_settings_repository_impl.dart';
import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';

class MockNotificationSettingsDatasource extends Mock
    implements NotificationSettingsDatasource {}

void main() {
  late MockNotificationSettingsDatasource mockDatasource;
  late NotificationSettingsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const NotificationSettingsEntity());
  });

  setUp(() {
    mockDatasource = MockNotificationSettingsDatasource();
    repository = NotificationSettingsRepositoryImpl(mockDatasource);
  });

  // ─── getSettings ────────────────────────────────────────────────────────────

  group('getSettings()', () {
    test('datasource.getSettings()를 1회 호출하고 결과를 그대로 반환한다', () async {
      const entity = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 12,
        lunchTimeMinute: 0,
        dinnerEnabled: true,
        dinnerTimeHour: 20,
        dinnerTimeMinute: 0,
      );
      when(() => mockDatasource.getSettings()).thenAnswer((_) async => entity);

      final result = await repository.getSettings();

      expect(result, equals(entity));
      verify(() => mockDatasource.getSettings()).called(1);
    });
  });

  // ─── saveSettings ───────────────────────────────────────────────────────────

  group('saveSettings()', () {
    test('datasource.saveSettings()를 1회 호출한다', () async {
      const entity = NotificationSettingsEntity(lunchEnabled: false);
      when(() => mockDatasource.saveSettings(any())).thenAnswer((_) async {});

      await repository.saveSettings(entity);

      verify(() => mockDatasource.saveSettings(entity)).called(1);
    });

    test('전달받은 엔티티를 변경 없이 datasource에 전달한다', () async {
      const entity = NotificationSettingsEntity(
        lunchEnabled: false,
        lunchTimeHour: 8,
        lunchTimeMinute: 30,
        dinnerEnabled: true,
        dinnerTimeHour: 18,
        dinnerTimeMinute: 0,
      );
      NotificationSettingsEntity? captured;
      when(() => mockDatasource.saveSettings(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as NotificationSettingsEntity;
      });

      await repository.saveSettings(entity);

      expect(captured, equals(entity));
    });
  });
}
