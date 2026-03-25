import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_manwon/main.dart';

void main() {
  group('앱 기본 실행 smoke test', () {
    testWidgets('앱이 ProviderScope로 감싸져 정상 실행된다', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: DailyManwonApp(),
        ),
      );

      expect(find.byType(DailyManwonApp), findsOneWidget);
    });
  });
}
