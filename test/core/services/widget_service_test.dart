import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_manwon/core/services/widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WidgetService service;
  final List<MethodCall> log = [];

  setUp(() async {
    service = WidgetService();
    log.clear();

    // home_widget 메서드 채널 모킹
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (MethodCall call) async {
        log.add(call);
        if (call.method == 'getWidgetData') return null;
        return true;
      },
    );

    // iOS 플랫폼으로 강제 설정 → init()의 플랫폼 가드 통과
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await service.init();
    log.clear(); // init 호출 로그는 테스트 대상 아님
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
  });

  group('WidgetService.updateWidget', () {
    test('prevDayRemainingKey를 remainingKey와 동일한 값으로 저장한다', () async {
      await service.updateWidget(
        total: 10000,
        baseDailyBudget: 10000,
        used: 3000,
        remaining: 7000,
        streak: 5,
        weeklySuccessDays: 3,
        carryOverEnabled: true,
        expenses: [],
        catMood: 'comfortable',
      );

      final prevDayCalls = log.where(
        (c) =>
            c.method == 'saveWidgetData' &&
            c.arguments['id'] == 'prevDayRemainingKey',
      ).toList();

      expect(
        prevDayCalls,
        hasLength(1),
        reason: 'prevDayRemainingKey는 정확히 한 번 저장되어야 한다',
      );
      expect(
        prevDayCalls.first.arguments['data'],
        equals(7000),
        reason: 'prevDayRemainingKey는 remaining(7000)과 같아야 한다',
      );
    });

    test('remainingKey와 prevDayRemainingKey는 항상 같은 값이다', () async {
      await service.updateWidget(
        total: 12000,
        baseDailyBudget: 10000,
        used: 9000,
        remaining: 3000,
        streak: 0,
        weeklySuccessDays: 0,
        carryOverEnabled: false,
        expenses: [],
        catMood: 'over',
      );

      final remainingVal = log
          .where((c) =>
              c.method == 'saveWidgetData' && c.arguments['id'] == 'remainingKey')
          .first
          .arguments['data'] as int;

      final prevDayVal = log
          .where((c) =>
              c.method == 'saveWidgetData' &&
              c.arguments['id'] == 'prevDayRemainingKey')
          .first
          .arguments['data'] as int;

      expect(
        prevDayVal,
        equals(remainingVal),
        reason: 'prevDayRemainingKey는 Intent가 오염시키기 전 스냅샷이므로 remainingKey와 같아야 한다',
      );
    });
  });
}
