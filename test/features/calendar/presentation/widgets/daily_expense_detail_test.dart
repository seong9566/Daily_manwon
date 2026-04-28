import 'package:daily_manwon/features/calendar/presentation/widgets/daily_expense_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('DailyExpenseDetail', () {
    testWidgets('이월이 없으면 예산 구성 카드가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        DailyExpenseDetail(
          date: DateTime(2026, 4, 22),
          expenses: const [],
          baseAmount: 10000,
          effectiveBudget: 10000,
        ),
      ));
      expect(find.text('오늘 예산 구성'), findsNothing);
    });

    testWidgets('이월이 있으면 예산 구성 카드가 표시된다', (tester) async {
      await tester.pumpWidget(wrap(
        DailyExpenseDetail(
          date: DateTime(2026, 4, 22),
          expenses: const [],
          baseAmount: 10000,
          effectiveBudget: 20000,
        ),
      ));
      expect(find.text('오늘 예산 구성'), findsOneWidget);
    });

    testWidgets('baseAmount가 null이면 카드가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        DailyExpenseDetail(
          date: DateTime(2026, 4, 22),
          expenses: const [],
        ),
      ));
      expect(find.text('오늘 예산 구성'), findsNothing);
    });

    testWidgets('양수 이월: 이월 라벨 표시, 초과이월 없음', (tester) async {
      await tester.pumpWidget(wrap(
        DailyExpenseDetail(
          date: DateTime(2026, 4, 22),
          expenses: const [],
          baseAmount: 10000,
          effectiveBudget: 15000,
        ),
      ));
      expect(find.text('오늘 예산 구성'), findsOneWidget);
      expect(find.text('이월'), findsOneWidget);
      expect(find.text('초과이월'), findsNothing);
    });

    testWidgets('음수 이월: 카드 표시, 초과이월 라벨, 이월 라벨 없음', (tester) async {
      await tester.pumpWidget(wrap(
        DailyExpenseDetail(
          date: DateTime(2026, 4, 22),
          expenses: const [],
          baseAmount: 10000,
          effectiveBudget: 5000,
        ),
      ));
      expect(find.text('오늘 예산 구성'), findsOneWidget);
      expect(find.text('초과이월'), findsOneWidget);
      expect(find.text('이월'), findsNothing);
    });

    testWidgets('합계가 음수일 때 카드 표시', (tester) async {
      await tester.pumpWidget(wrap(
        DailyExpenseDetail(
          date: DateTime(2026, 4, 22),
          expenses: const [],
          baseAmount: 10000,
          effectiveBudget: -2000,
        ),
      ));
      expect(find.text('오늘 예산 구성'), findsOneWidget);
      expect(find.text('초과이월'), findsOneWidget);
    });
  });
}
