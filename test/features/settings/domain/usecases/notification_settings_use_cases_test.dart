import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:daily_manwon/features/settings/domain/repositories/notification_settings_repository.dart';
import 'package:daily_manwon/features/settings/domain/usecases/get_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/domain/usecases/save_notification_settings_use_case.dart';

class MockNotificationSettingsRepository extends Mock
    implements NotificationSettingsRepository {}

void main() {
  late MockNotificationSettingsRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const NotificationSettingsEntity());
  });

  setUp(() {
    mockRepo = MockNotificationSettingsRepository();
  });

  // ─── GetNotificationSettingsUseCase ────────────────────────────────────────

  group('GetNotificationSettingsUseCase', () {
    test('execute() 호출 시 repository.getSettings()가 1회 호출된다', () async {
      // given
      when(() => mockRepo.getSettings())
          .thenAnswer((_) async => const NotificationSettingsEntity());
      final useCase = GetNotificationSettingsUseCase(mockRepo);

      // when
      await useCase.execute();

      // then
      verify(() => mockRepo.getSettings()).called(1);
    });

    test('execute() 는 repository에서 받은 엔티티를 그대로 반환한다', () async {
      // given
      const entity = NotificationSettingsEntity(
        lunchEnabled: true,
        lunchTimeHour: 11,
        lunchTimeMinute: 30,
        dinnerEnabled: false,
        dinnerTimeHour: 19,
        dinnerTimeMinute: 0,
      );
      when(() => mockRepo.getSettings()).thenAnswer((_) async => entity);
      final useCase = GetNotificationSettingsUseCase(mockRepo);

      // when
      final result = await useCase.execute();

      // then
      expect(result, equals(entity));
    });

    test('repository가 기본값 엔티티를 반환하면 그대로 전달된다', () async {
      // given
      const defaultEntity = NotificationSettingsEntity();
      when(() => mockRepo.getSettings()).thenAnswer((_) async => defaultEntity);
      final useCase = GetNotificationSettingsUseCase(mockRepo);

      // when
      final result = await useCase.execute();

      // then
      expect(result.lunchEnabled, isTrue);
      expect(result.lunchTimeHour, equals(12));
      expect(result.dinnerEnabled, isTrue);
      expect(result.dinnerTimeHour, equals(20));
    });
  });

  // ─── SaveNotificationSettingsUseCase ───────────────────────────────────────

  group('SaveNotificationSettingsUseCase', () {
    test('execute() 호출 시 repository.saveSettings()가 1회 호출된다', () async {
      // given
      when(() => mockRepo.saveSettings(any())).thenAnswer((_) async {});
      final useCase = SaveNotificationSettingsUseCase(mockRepo);

      // when
      await useCase.execute(const NotificationSettingsEntity());

      // then
      verify(() => mockRepo.saveSettings(any())).called(1);
    });

    test('execute() 는 전달받은 엔티티를 변경 없이 repository에 전달한다', () async {
      // given
      const entity = NotificationSettingsEntity(
        lunchEnabled: false,
        lunchTimeHour: 8,
        lunchTimeMinute: 30,
        dinnerEnabled: true,
        dinnerTimeHour: 18,
        dinnerTimeMinute: 0,
      );
      NotificationSettingsEntity? captured;
      when(() => mockRepo.saveSettings(any())).thenAnswer((inv) async {
        captured = inv.positionalArguments[0] as NotificationSettingsEntity;
      });
      final useCase = SaveNotificationSettingsUseCase(mockRepo);

      // when
      await useCase.execute(entity);

      // then
      expect(captured, equals(entity));
    });

    test('다른 엔티티를 연속 저장하면 각각 1회씩 repository가 호출된다', () async {
      // given
      when(() => mockRepo.saveSettings(any())).thenAnswer((_) async {});
      final useCase = SaveNotificationSettingsUseCase(mockRepo);
      const first = NotificationSettingsEntity(lunchEnabled: true);
      const second = NotificationSettingsEntity(dinnerEnabled: false);

      // when
      await useCase.execute(first);
      await useCase.execute(second);

      // then
      verify(() => mockRepo.saveSettings(any())).called(2);
    });
  });
}
