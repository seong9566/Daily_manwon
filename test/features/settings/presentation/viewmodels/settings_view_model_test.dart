import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/core/services/notification_service.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:daily_manwon/features/settings/domain/usecases/get_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/domain/usecases/save_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/presentation/viewmodels/settings_view_model.dart';

// ── Mock 클래스 ──────────────────────────────────────────────────────────────

class MockGetNotificationSettingsUseCase extends Mock
    implements GetNotificationSettingsUseCase {}

class MockSaveNotificationSettingsUseCase extends Mock
    implements SaveNotificationSettingsUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockDailyBudgetRepository extends Mock
    implements DailyBudgetRepository {}

// ── 테스트 메인 ───────────────────────────────────────────────────────────────

void main() {
  late MockGetNotificationSettingsUseCase mockGetUseCase;
  late MockSaveNotificationSettingsUseCase mockSaveUseCase;
  late MockNotificationService mockNotifService;
  late MockSettingsRepository mockSettingsRepo;
  late MockDailyBudgetRepository mockDailyBudgetRepo;
  late ProviderContainer container;

  /// build() 의 microtask 로드에서 반환할 기본 DB 엔티티
  /// NotificationSettingsEntity 기본값: lunchEnabled=true, dinnerEnabled=true
  const defaultEntity = NotificationSettingsEntity();

  setUpAll(() {
    registerFallbackValue(defaultEntity);
    registerFallbackValue(const TimeOfDay(hour: 12, minute: 0));
  });

  setUp(() async {
    await GetIt.instance.reset();

    mockGetUseCase = MockGetNotificationSettingsUseCase();
    mockSaveUseCase = MockSaveNotificationSettingsUseCase();
    mockNotifService = MockNotificationService();
    mockSettingsRepo = MockSettingsRepository();
    mockDailyBudgetRepo = MockDailyBudgetRepository();

    // build() 의 microtask (loadNotificationSettings, _loadDailyBudget,
    // _loadCarryoverEnabled) 와 AppThemeMode._persistToDatabase 에 대한 기본 스텁
    when(() => mockGetUseCase.execute()).thenAnswer((_) async => defaultEntity);
    when(() => mockSettingsRepo.getDailyBudget()).thenAnswer((_) async => 10000);
    when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => false);
    when(() => mockSettingsRepo.setIsDarkMode(value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => mockSaveUseCase.execute(any())).thenAnswer((_) async {});
    when(() => mockDailyBudgetRepo.updateTodayBaseAmount(any()))
        .thenAnswer((_) async {});

    GetIt.instance
      ..registerSingleton<GetNotificationSettingsUseCase>(mockGetUseCase)
      ..registerSingleton<SaveNotificationSettingsUseCase>(mockSaveUseCase)
      ..registerSingleton<NotificationService>(mockNotifService)
      ..registerSingleton<SettingsRepository>(mockSettingsRepo)
      ..registerSingleton<DailyBudgetRepository>(mockDailyBudgetRepo);

    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await GetIt.instance.reset();
  });

  /// ViewModel을 읽고 build() 의 microtask 로드가 완료될 때까지 기다린다.
  /// 이후 테스트는 DB 초기값이 반영된 상태(lunchEnabled=true, dinnerEnabled=true)에서 시작한다.
  Future<SettingsViewModel> readViewModelAndWaitLoad() async {
    final vm = container.read(settingsViewModelProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    return vm;
  }

  // ─── T-S-01: 일일 예산 설정 ─────────────────────────────────────────────────

  group('T-S-01: setDailyBudget', () {
    setUp(() {
      when(() => mockSettingsRepo.setDailyBudget(any()))
          .thenAnswer((_) async {});
    });

    test('state.dailyBudget이 새 금액으로 업데이트된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.setDailyBudget(20000);

      // then
      expect(container.read(settingsViewModelProvider).dailyBudget, equals(20000));
    });

    test('settingsRepository.setDailyBudget이 올바른 금액으로 1회 호출된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.setDailyBudget(15000);

      // then
      verify(() => mockSettingsRepo.setDailyBudget(15000)).called(1);
    });

    test('예산을 연속으로 두 번 변경하면 마지막 값이 state에 반영된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.setDailyBudget(5000);
      await vm.setDailyBudget(30000);

      // then
      expect(container.read(settingsViewModelProvider).dailyBudget, equals(30000));
    });
  });

  // ─── T-S-02: 이월 기능 토글 ─────────────────────────────────────────────────

  group('T-S-02: setCarryoverEnabled', () {
    setUp(() {
      when(() => mockSettingsRepo.setCarryoverEnabled(any()))
          .thenAnswer((_) async {});
    });

    test('true로 설정 시 state.carryoverEnabled가 true가 된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.setCarryoverEnabled(true);

      // then
      expect(container.read(settingsViewModelProvider).carryoverEnabled, isTrue);
    });

    test('false로 설정 시 state.carryoverEnabled가 false가 된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();
      await vm.setCarryoverEnabled(true);

      // when
      await vm.setCarryoverEnabled(false);

      // then
      expect(container.read(settingsViewModelProvider).carryoverEnabled, isFalse);
    });

    test('settingsRepository.setCarryoverEnabled가 올바른 값으로 1회 호출된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.setCarryoverEnabled(true);

      // then
      verify(() => mockSettingsRepo.setCarryoverEnabled(true)).called(1);
    });

    test('사용자가 토글 후 DB 로드 시 DB 값이 state를 덮어쓰지 않는다 (race condition)', () async {
      // given: microtask 이전에 사용자가 먼저 상호작용
      final vm = container.read(settingsViewModelProvider.notifier);
      await vm.setCarryoverEnabled(true); // _carryoverInteracted = true

      // DB에는 false가 저장된 상태로 microtask 완료
      when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => false);
      await Future<void>.delayed(Duration.zero);

      // then: 사용자가 설정한 true가 유지됨
      expect(container.read(settingsViewModelProvider).carryoverEnabled, isTrue);
    });
  });

  // ─── T-S-03: 점심 알림 토글 ─────────────────────────────────────────────────
  // build() 의 DB 로드 이후 lunchEnabled = true (defaultEntity 기본값)

  group('T-S-03: toggleLunch', () {
    setUp(() {
      when(() => mockNotifService.scheduleLunch(any()))
          .thenAnswer((_) async {});
      when(() => mockNotifService.cancelLunch()).thenAnswer((_) async {});
    });

    test('권한 허용 시 state.lunchEnabled가 true로 유지된다', () async {
      // given: DB 로드 후 lunchEnabled = true
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => true);
      final vm = await readViewModelAndWaitLoad();

      // when: true → true (권한 요청 발생)
      await vm.toggleLunch(true);

      // then
      expect(container.read(settingsViewModelProvider).lunchEnabled, isTrue);
    });

    test('권한 허용 시 scheduleLunch가 호출된다', () async {
      // given
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => true);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleLunch(true);

      // then
      verify(() => mockNotifService.scheduleLunch(any())).called(1);
    });

    test('권한 거부 시 state.lunchEnabled가 false로 되돌아간다', () async {
      // given
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => false);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleLunch(true);

      // then
      expect(container.read(settingsViewModelProvider).lunchEnabled, isFalse);
    });

    test('권한 거부 시 scheduleLunch가 호출되지 않는다', () async {
      // given
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => false);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleLunch(true);

      // then
      verifyNever(() => mockNotifService.scheduleLunch(any()));
    });

    test('비활성화 시 cancelLunch가 1회 호출된다', () async {
      // given: DB 로드 후 lunchEnabled = true이므로 바로 비활성화 가능
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleLunch(false);

      // then
      verify(() => mockNotifService.cancelLunch()).called(1);
    });

    test('비활성화 시 state.lunchEnabled가 false가 된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleLunch(false);

      // then
      expect(container.read(settingsViewModelProvider).lunchEnabled, isFalse);
    });
  });

  // ─── T-S-04: 점심 시간 변경 ─────────────────────────────────────────────────

  group('T-S-04: updateLunchTime', () {
    setUp(() {
      when(() => mockNotifService.scheduleLunch(any()))
          .thenAnswer((_) async {});
    });

    test('state.lunchTime이 새 시간으로 업데이트된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();
      const newTime = TimeOfDay(hour: 11, minute: 30);

      // when
      await vm.updateLunchTime(newTime);

      // then
      expect(
        container.read(settingsViewModelProvider).lunchTime,
        equals(newTime),
      );
    });

    test('점심 알림 활성 상태에서 scheduleLunch가 새 시간으로 호출된다', () async {
      // given: DB 로드 후 lunchEnabled = true
      final vm = await readViewModelAndWaitLoad();
      const newTime = TimeOfDay(hour: 11, minute: 30);

      // when
      await vm.updateLunchTime(newTime);

      // then
      verify(() => mockNotifService.scheduleLunch(newTime)).called(1);
    });

    test('점심 알림 비활성 상태에서 scheduleLunch가 호출되지 않는다', () async {
      // given: 먼저 알림 비활성화
      when(() => mockNotifService.cancelLunch()).thenAnswer((_) async {});
      final vm = await readViewModelAndWaitLoad();
      await vm.toggleLunch(false);
      clearInteractions(mockNotifService);

      // when
      await vm.updateLunchTime(const TimeOfDay(hour: 9, minute: 0));

      // then
      verifyNever(() => mockNotifService.scheduleLunch(any()));
    });
  });

  // ─── T-S-05: 저녁 알림 토글 ─────────────────────────────────────────────────
  // build() 의 DB 로드 이후 dinnerEnabled = true (defaultEntity 기본값)

  group('T-S-05: toggleDinner', () {
    setUp(() {
      when(() => mockNotifService.scheduleDinner(any()))
          .thenAnswer((_) async {});
      when(() => mockNotifService.cancelDinner()).thenAnswer((_) async {});
    });

    test('권한 허용 시 state.dinnerEnabled가 true로 유지된다', () async {
      // given
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => true);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleDinner(true);

      // then
      expect(container.read(settingsViewModelProvider).dinnerEnabled, isTrue);
    });

    test('권한 거부 시 state.dinnerEnabled가 false로 되돌아간다', () async {
      // given
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => false);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleDinner(true);

      // then
      expect(container.read(settingsViewModelProvider).dinnerEnabled, isFalse);
    });

    test('권한 거부 시 scheduleDinner가 호출되지 않는다', () async {
      // given
      when(() => mockNotifService.requestPermission())
          .thenAnswer((_) async => false);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleDinner(true);

      // then
      verifyNever(() => mockNotifService.scheduleDinner(any()));
    });

    test('비활성화 시 cancelDinner가 1회 호출된다', () async {
      // given: DB 로드 후 dinnerEnabled = true
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleDinner(false);

      // then
      verify(() => mockNotifService.cancelDinner()).called(1);
    });

    test('비활성화 시 state.dinnerEnabled가 false가 된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.toggleDinner(false);

      // then
      expect(container.read(settingsViewModelProvider).dinnerEnabled, isFalse);
    });
  });

  // ─── T-S-06: 저녁 시간 변경 ─────────────────────────────────────────────────

  group('T-S-06: updateDinnerTime', () {
    setUp(() {
      when(() => mockNotifService.scheduleDinner(any()))
          .thenAnswer((_) async {});
    });

    test('state.dinnerTime이 새 시간으로 업데이트된다', () async {
      // given
      final vm = await readViewModelAndWaitLoad();
      const newTime = TimeOfDay(hour: 19, minute: 0);

      // when
      await vm.updateDinnerTime(newTime);

      // then
      expect(
        container.read(settingsViewModelProvider).dinnerTime,
        equals(newTime),
      );
    });

    test('저녁 알림 활성 상태에서 scheduleDinner가 새 시간으로 호출된다', () async {
      // given: DB 로드 후 dinnerEnabled = true
      final vm = await readViewModelAndWaitLoad();
      const newTime = TimeOfDay(hour: 19, minute: 0);

      // when
      await vm.updateDinnerTime(newTime);

      // then
      verify(() => mockNotifService.scheduleDinner(newTime)).called(1);
    });

    test('저녁 알림 비활성 상태에서 scheduleDinner가 호출되지 않는다', () async {
      // given: 먼저 알림 비활성화
      when(() => mockNotifService.cancelDinner()).thenAnswer((_) async {});
      final vm = await readViewModelAndWaitLoad();
      await vm.toggleDinner(false);
      clearInteractions(mockNotifService);

      // when
      await vm.updateDinnerTime(const TimeOfDay(hour: 17, minute: 0));

      // then
      verifyNever(() => mockNotifService.scheduleDinner(any()));
    });
  });

  // ─── T-S-07: 알림 설정 로드 (loadNotificationSettings) ─────────────────────

  group('T-S-07: loadNotificationSettings', () {
    test('DB 값으로 미상호작용 필드가 업데이트된다', () async {
      // given: DB에 저장된 커스텀 설정
      const dbEntity = NotificationSettingsEntity(
        lunchEnabled: false,
        lunchTimeHour: 11,
        lunchTimeMinute: 30,
        dinnerEnabled: false,
        dinnerTimeHour: 19,
        dinnerTimeMinute: 0,
      );
      when(() => mockGetUseCase.execute()).thenAnswer((_) async => dbEntity);
      final vm = await readViewModelAndWaitLoad();

      // when
      await vm.loadNotificationSettings();

      // then
      final state = container.read(settingsViewModelProvider);
      expect(state.lunchEnabled, isFalse);
      expect(state.lunchTime, equals(const TimeOfDay(hour: 11, minute: 30)));
      expect(state.dinnerEnabled, isFalse);
      expect(state.dinnerTime, equals(const TimeOfDay(hour: 19, minute: 0)));
    });

    test('사용자가 상호작용한 필드는 DB 값으로 덮어쓰지 않는다', () async {
      // given: 사용자가 먼저 점심 알림을 비활성화
      when(() => mockNotifService.cancelLunch()).thenAnswer((_) async {});
      final vm = await readViewModelAndWaitLoad();
      await vm.toggleLunch(false); // _lunchEnabledInteracted = true, lunchEnabled = false

      // DB에는 lunchEnabled: true가 저장됨
      when(() => mockGetUseCase.execute())
          .thenAnswer((_) async => const NotificationSettingsEntity(lunchEnabled: true));

      // when
      await vm.loadNotificationSettings();

      // then: 사용자가 설정한 false가 유지됨
      expect(container.read(settingsViewModelProvider).lunchEnabled, isFalse);
    });

    test('로드 중에는 state.isLoading이 true가 된다', () async {
      // given
      final states = <bool>[];
      container.listen(
        settingsViewModelProvider.select((s) => s.isLoading),
        (_, next) => states.add(next),
      );
      when(() => mockGetUseCase.execute()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 10), () => defaultEntity),
      );
      final vm = await readViewModelAndWaitLoad();

      // when
      final future = vm.loadNotificationSettings();
      states.add(container.read(settingsViewModelProvider).isLoading);
      await future;

      // then: 로드 중 true, 완료 후 false
      expect(states, containsAllInOrder([true, false]));
    });
  });
}
