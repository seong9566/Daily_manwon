import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/calendar/presentation/widgets/calendar_amount_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );

  group('CalendarAmountBadge', () {
    testWidgets('지출 금액이 천단위 쉼표 포맷으로 표시된다', (tester) async {
      await tester.pumpWidget(wrap(
        const CalendarAmountBadge(
          totalSpent: 5500,
          mood: CharacterMood.normal,
          isDark: false,
        ),
      ));
      expect(find.text('5,500'), findsOneWidget);
    });

    testWidgets('12,000원 초과 지출도 올바르게 포맷된다', (tester) async {
      await tester.pumpWidget(wrap(
        const CalendarAmountBadge(
          totalSpent: 12000,
          mood: CharacterMood.over,
          isDark: false,
        ),
      ));
      expect(find.text('12,000'), findsOneWidget);
    });

    testWidgets('comfortable mood에서도 숫자가 표시된다', (tester) async {
      await tester.pumpWidget(wrap(
        const CalendarAmountBadge(
          totalSpent: 1500,
          mood: CharacterMood.comfortable,
          isDark: false,
        ),
      ));
      expect(find.text('1,500'), findsOneWidget);
    });

    testWidgets('다크모드에서도 렌더링 오류 없이 표시된다', (tester) async {
      await tester.pumpWidget(wrap(
        const CalendarAmountBadge(
          totalSpent: 3000,
          mood: CharacterMood.comfortable,
          isDark: true,
        ),
      ));
      expect(find.text('3,000'), findsOneWidget);
    });
  });
}
