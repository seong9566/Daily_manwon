import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:daily_manwon/core/di/injection.dart';
import 'package:daily_manwon/main.dart';

void main() {
  group('앱 기본 실행 smoke test', () {
    setUpAll(() async {
      await configureDependencies();
    });

    tearDownAll(() async {
      await GetIt.instance.reset();
    });

    testWidgets('앱이 ProviderScope로 감싸져 정상 실행된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: DailyManwonApp(isOnboardingCompleted: true),
        ),
      );

      expect(find.byType(DailyManwonApp), findsOneWidget);
    });
  });
}
