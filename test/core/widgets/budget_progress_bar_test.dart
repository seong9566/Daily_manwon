import 'package:daily_manwon/core/widgets/budget_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('BudgetProgressBar', () {
    testWidgets('carryOver가 0이면 범례가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        const BudgetProgressBar(remaining: 8000, total: 10000, carryOver: 0),
      ));
      expect(find.text('이월'), findsNothing);
    });

    testWidgets('carryOver > 0이면 이월 범례 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(wrap(
        const BudgetProgressBar(remaining: 15000, total: 20000, carryOver: 10000),
      ));
      await tester.pump();
      expect(find.textContaining('이월'), findsWidgets);
      expect(find.textContaining('기본'), findsOneWidget);
    });

    testWidgets('carryOver > 0이면 LinearProgressIndicator를 사용하지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        const BudgetProgressBar(remaining: 15000, total: 20000, carryOver: 10000),
      ));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
