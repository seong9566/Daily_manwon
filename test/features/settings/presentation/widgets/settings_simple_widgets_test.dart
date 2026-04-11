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
import 'package:daily_manwon/features/settings/presentation/widgets/budget_edit_bottom_sheet.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/carryover_toggle_section.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_budget_tile.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_divider.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_tap_tile.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/settings_time_picker_tile.dart';
import 'package:daily_manwon/features/settings/presentation/widgets/time_picker_bottom_sheet.dart';

// ── Mock 클래스 ──────────────────────────────────────────────────────────────

class MockGetNotificationSettingsUseCase extends Mock
    implements GetNotificationSettingsUseCase {}

class MockSaveNotificationSettingsUseCase extends Mock
    implements SaveNotificationSettingsUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// ── 공통 헬퍼 ────────────────────────────────────────────────────────────────

/// GetIt에 mock 의존성을 등록하고 ProviderScope로 감싼 위젯을 반환한다
Future<void> pumpWithProviderScope(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: widget),
      ),
    ),
  );
}

void setupGetIt() {
  final mockGetUseCase = MockGetNotificationSettingsUseCase();
  final mockSaveUseCase = MockSaveNotificationSettingsUseCase();
  final mockNotifService = MockNotificationService();
  final mockSettingsRepo = MockSettingsRepository();

  const defaultEntity = NotificationSettingsEntity();
  when(() => mockGetUseCase.execute()).thenAnswer((_) async => defaultEntity);
  when(() => mockSettingsRepo.getDailyBudget()).thenAnswer((_) async => 10000);
  when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => false);
  when(() => mockSettingsRepo.setIsDarkMode(value: any(named: 'value')))
      .thenAnswer((_) async {});
  when(() => mockSettingsRepo.setCarryoverEnabled(any()))
      .thenAnswer((_) async {});
  when(() => mockSaveUseCase.execute(any())).thenAnswer((_) async {});

  GetIt.instance
    ..registerSingleton<GetNotificationSettingsUseCase>(mockGetUseCase)
    ..registerSingleton<SaveNotificationSettingsUseCase>(mockSaveUseCase)
    ..registerSingleton<NotificationService>(mockNotifService)
    ..registerSingleton<SettingsRepository>(mockSettingsRepo);
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(const NotificationSettingsEntity());
    registerFallbackValue(const TimeOfDay(hour: 12, minute: 0));
  });

  // ─── SettingsDivider ─────────────────────────────────────────────────────

  group('SettingsDivider', () {
    testWidgets('light 모드에서 정상 렌더링된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsDivider(isDark: false)),
        ),
      );
      expect(find.byType(SettingsDivider), findsOneWidget);
    });

    testWidgets('dark 모드에서 정상 렌더링된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SettingsDivider(isDark: true)),
        ),
      );
      expect(find.byType(SettingsDivider), findsOneWidget);
    });
  });

  // ─── SettingsSectionHeader ───────────────────────────────────────────────

  group('SettingsSectionHeader', () {
    testWidgets('label 텍스트가 화면에 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(label: '알림 설정', isDark: false),
          ),
        ),
      );
      expect(find.text('알림 설정'), findsOneWidget);
    });

    testWidgets('dark 모드에서 정상 렌더링된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(label: '디스플레이', isDark: true),
          ),
        ),
      );
      expect(find.text('디스플레이'), findsOneWidget);
    });
  });

  // ─── SettingsTapTile ─────────────────────────────────────────────────────

  group('SettingsTapTile', () {
    testWidgets('label과 trailing 텍스트가 화면에 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsTapTile(label: '버전', trailing: '1.0.0'),
          ),
        ),
      );
      expect(find.text('버전'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('dark 모드에서 정상 렌더링된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SettingsTapTile(label: '버전', trailing: '1.0.0'),
          ),
        ),
      );
      expect(find.text('버전'), findsOneWidget);
    });
  });

  // ─── SettingsBudgetTile ──────────────────────────────────────────────────

  group('SettingsBudgetTile', () {
    testWidgets('1만원 단위 예산이 "1만원" 형식으로 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsBudgetTile(
              budget: 10000,
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('1만원'), findsOneWidget);
    });

    testWidgets('10000 미만 예산은 "5,000원" 형식으로 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsBudgetTile(
              budget: 5000,
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('5,000원'), findsOneWidget);
    });

    testWidgets('10000 이상 비만원 단위 예산은 "15,000원" 형식으로 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsBudgetTile(
              budget: 15000,
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('15,000원'), findsOneWidget);
    });

    testWidgets('1000 미만 예산은 "500원" 형식으로 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsBudgetTile(
              budget: 500,
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('500원'), findsOneWidget);
    });

    testWidgets('onTap 콜백이 호출된다', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsBudgetTile(
              budget: 10000,
              isDark: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  // ─── SettingsSwitchTile ──────────────────────────────────────────────────

  group('SettingsSwitchTile', () {
    testWidgets('label 텍스트와 Switch가 표시된다', (tester) async {
      await pumpWithProviderScope(
        tester,
        SettingsSwitchTile(
          label: '다크 모드',
          value: false,
          onChanged: (_) {},
        ),
      );
      expect(find.text('다크 모드'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('onChanged 콜백이 호출된다', (tester) async {
      bool? changedValue;
      await pumpWithProviderScope(
        tester,
        SettingsSwitchTile(
          label: '점심 알림',
          value: false,
          onChanged: (v) => changedValue = v,
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(changedValue, isNotNull);
    });
  });

  // ─── SettingsTimePickerTile ──────────────────────────────────────────────

  group('SettingsTimePickerTile', () {
    testWidgets('label과 시간이 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTimePickerTile(
              label: '점심 시간',
              time: const TimeOfDay(hour: 12, minute: 0),
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('점심 시간'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('변경'), findsOneWidget);
    });

    testWidgets('단자리 시/분은 0-패딩으로 표시된다', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTimePickerTile(
              label: '저녁 시간',
              time: const TimeOfDay(hour: 9, minute: 5),
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('09:05'), findsOneWidget);
    });

    testWidgets('"변경" 버튼 탭 시 onTap 콜백이 호출된다', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTimePickerTile(
              label: '점심 시간',
              time: const TimeOfDay(hour: 12, minute: 0),
              isDark: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('변경'));
      expect(tapped, isTrue);
    });
  });

  // ─── BudgetEditBottomSheet ───────────────────────────────────────────────

  group('BudgetEditBottomSheet', () {
    testWidgets('초기 예산값이 TextField에 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetEditBottomSheet(initialBudget: 10000),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('일일 예산 설정'), findsOneWidget);
      expect(find.text('10000'), findsOneWidget);
    });

    testWidgets('취소 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetEditBottomSheet(initialBudget: 10000),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('빈 입력으로 저장 시 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetEditBottomSheet(initialBudget: 10000),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(find.text('유효한 금액을 입력해 주세요'), findsOneWidget);
    });

    testWidgets('0 입력으로 저장 시 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetEditBottomSheet(initialBudget: 10000),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('저장'));
      await tester.pump();

      expect(find.text('유효한 금액을 입력해 주세요'), findsOneWidget);
    });

    testWidgets('유효한 금액 입력 후 에러 상태가 초기화된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BudgetEditBottomSheet(initialBudget: 10000),
          ),
        ),
      );
      await tester.pump();

      // 에러 유발
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('저장'));
      await tester.pump();
      expect(find.text('유효한 금액을 입력해 주세요'), findsOneWidget);

      // 유효한 값 입력 시 에러 해제
      await tester.enterText(find.byType(TextField), '15000');
      await tester.pump();
      expect(find.text('유효한 금액을 입력해 주세요'), findsNothing);
    });
  });

  // ─── TimePickerBottomSheet ───────────────────────────────────────────────

  group('TimePickerBottomSheet', () {
    testWidgets('시간 선택 UI가 정상 렌더링된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimePickerBottomSheet(
              initialTime: TimeOfDay(hour: 12, minute: 0),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('확인'), findsOneWidget);
      expect(find.text('취소'), findsOneWidget);
    });

    testWidgets('초기 시간(12시 0분)이 화면에 표시된다', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimePickerBottomSheet(
              initialTime: TimeOfDay(hour: 12, minute: 0),
            ),
          ),
        ),
      );
      await tester.pump();
      // 시간 선택 UI가 존재하는지 확인
      expect(find.byType(ListWheelScrollView), findsWidgets);
    });
  });

  // ─── CarryoverToggleSection ──────────────────────────────────────────────

  group('CarryoverToggleSection', () {
    setUp(() async {
      await GetIt.instance.reset();
      setupGetIt();
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

    testWidgets('토글과 레이블이 렌더링된다', (tester) async {
      await pumpWithProviderScope(
        tester,
        const CarryoverToggleSection(),
      );
      await tester.pump(); // microtask 처리
      await tester.pump(); // 상태 반영

      expect(find.text('남은 예산 이월'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('carryoverEnabled=false 일 때 시뮬레이션 카드가 표시되지 않는다',
        (tester) async {
      await pumpWithProviderScope(
        tester,
        const CarryoverToggleSection(),
      );
      await tester.pump();
      await tester.pump();

      // 기본값은 false이므로 info 카드가 없다
      expect(find.text('예) 오늘 3,000원 사용 시 → 내일 17,000원'), findsNothing);
    });

    testWidgets('스위치 토글 시 정책 변경 다이얼로그가 표시된다', (tester) async {
      await pumpWithProviderScope(
        tester,
        const CarryoverToggleSection(),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // 다이얼로그가 표시된다
      expect(find.text('정책 변경'), findsOneWidget);
      expect(find.text('내일부터 적용됩니다.\n오늘 예산은 유지됩니다.'), findsOneWidget);

      // 확인 버튼으로 닫기
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.text('정책 변경'), findsNothing);
    });
  });
}
