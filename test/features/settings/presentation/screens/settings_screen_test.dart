import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/core/services/notification_service.dart';
import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:daily_manwon/features/settings/domain/usecases/get_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/domain/usecases/save_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/presentation/screens/settings_screen.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/budget_edit_bottom_sheet.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_budget_tile.dart';

class MockGetNotificationSettingsUseCase extends Mock
    implements GetNotificationSettingsUseCase {}

class MockSaveNotificationSettingsUseCase extends Mock
    implements SaveNotificationSettingsUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void setupGetIt({
  bool carryoverEnabled = false,
  bool lunchEnabled = true,
  bool dinnerEnabled = true,
}) {
  final mockGetUseCase = MockGetNotificationSettingsUseCase();
  final mockSaveUseCase = MockSaveNotificationSettingsUseCase();
  final mockNotifService = MockNotificationService();
  final mockSettingsRepo = MockSettingsRepository();

  final entity = NotificationSettingsEntity(
    lunchEnabled: lunchEnabled,
    dinnerEnabled: dinnerEnabled,
  );
  when(() => mockGetUseCase.execute()).thenAnswer((_) async => entity);
  when(() => mockSettingsRepo.getDailyBudget()).thenAnswer((_) async => 10000);
  when(() => mockSettingsRepo.getCarryoverEnabled())
      .thenAnswer((_) async => carryoverEnabled);
  when(() => mockSettingsRepo.setIsDarkMode(value: any(named: 'value')))
      .thenAnswer((_) async {});
  when(() => mockSaveUseCase.execute(any())).thenAnswer((_) async {});
  when(() => mockSettingsRepo.setDailyBudget(any()))
      .thenAnswer((_) async {});
  when(() => mockSettingsRepo.setCarryoverEnabled(any()))
      .thenAnswer((_) async {});

  GetIt.instance
    ..registerSingleton<GetNotificationSettingsUseCase>(mockGetUseCase)
    ..registerSingleton<SaveNotificationSettingsUseCase>(mockSaveUseCase)
    ..registerSingleton<NotificationService>(mockNotifService)
    ..registerSingleton<SettingsRepository>(mockSettingsRepo);
}

/// 설정 화면을 ProviderScope + MaterialApp으로 감싸 펌핑한다
Future<void> pumpSettingsScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pump(); // microtask 처리
  await tester.pump(); // 상태 반영
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NotificationSettingsEntity());
    registerFallbackValue(const TimeOfDay(hour: 12, minute: 0));
  });

  setUp(() async {
    await GetIt.instance.reset();
    setupGetIt();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  // ─── 기본 렌더링 ─────────────────────────────────────────────────────────

  group('SettingsScreen 기본 렌더링', () {
    testWidgets('설정 화면이 정상 렌더링된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('설정'), findsOneWidget);
      expect(find.text('예산 관리'), findsOneWidget);
      expect(find.text('알림 설정'), findsOneWidget);
      expect(find.text('디스플레이'), findsOneWidget);
    });

    testWidgets('예산 관리 섹션이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.byType(SettingsBudgetTile), findsOneWidget);
    });

    testWidgets('스크롤 후 앱 정보 섹션이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      await tester.scrollUntilVisible(find.text('버전'), 100);
      expect(find.text('버전'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('점심 알림 토글이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('점심 알림'), findsOneWidget);
    });

    testWidgets('저녁 알림 토글이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('저녁 알림'), findsOneWidget);
    });

    testWidgets('다크 모드 토글이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('다크 모드'), findsOneWidget);
    });
  });

  // ─── 예산 편집 바텀시트 ───────────────────────────────────────────────────

  group('예산 편집 바텀시트', () {
    testWidgets('예산 타일 탭 시 BudgetEditBottomSheet가 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      await tester.tap(find.byType(SettingsBudgetTile));
      await tester.pumpAndSettle();

      expect(find.byType(BudgetEditBottomSheet), findsOneWidget);
    });

    testWidgets('바텀시트 취소 버튼 탭 시 닫힌다', (tester) async {
      await pumpSettingsScreen(tester);

      await tester.tap(find.byType(SettingsBudgetTile));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetEditBottomSheet), findsOneWidget);

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetEditBottomSheet), findsNothing);
    });
  });

  // ─── 알림 토글 ───────────────────────────────────────────────────────────

  group('알림 토글 상호작용', () {
    testWidgets('lunchEnabled=true 일 때 점심 시간 타일이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('점심 시간'), findsOneWidget);
    });

    testWidgets('dinnerEnabled=true 일 때 저녁 시간 타일이 표시된다', (tester) async {
      await pumpSettingsScreen(tester);

      expect(find.text('저녁 시간'), findsOneWidget);
    });

    testWidgets('lunchEnabled=false 일 때 점심 시간 타일이 숨겨진다', (tester) async {
      await GetIt.instance.reset();
      setupGetIt(lunchEnabled: false);
      await pumpSettingsScreen(tester);

      expect(find.text('점심 시간'), findsNothing);
    });

    testWidgets('dinnerEnabled=false 일 때 저녁 시간 타일이 숨겨진다', (tester) async {
      await GetIt.instance.reset();
      setupGetIt(dinnerEnabled: false);
      await pumpSettingsScreen(tester);

      expect(find.text('저녁 시간'), findsNothing);
    });
  });
}
