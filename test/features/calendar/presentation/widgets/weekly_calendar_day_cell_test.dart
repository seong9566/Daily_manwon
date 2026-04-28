import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/calendar/presentation/widgets/weekly_calendar_day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WeeklyCalendarDayCell', () {
    testWidgets('지출이 있을 때 금액 텍스트를 표시한다', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 10),
          isToday: false,
          isSelected: false,
          isFuture: false,
          mood: CharacterMood.normal,
          totalSpent: 5500,
        ),
      ));

      expect(find.text('5,500'), findsOneWidget);
    });

    testWidgets('totalSpent가 null이면 금액 텍스트를 표시하지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 15),
          isToday: false,
          isSelected: false,
          isFuture: true,
          mood: null,
          totalSpent: null,
        ),
      ));

      expect(find.textContaining(','), findsNothing);
    });

    testWidgets('LinearProgressIndicator가 더 이상 렌더링되지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 10),
          isToday: false,
          isSelected: false,
          isFuture: false,
          mood: CharacterMood.comfortable,
          totalSpent: 3000,
        ),
      ));

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('이월 예산이 있으면 미니 스플릿 바가 표시된다', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 22),
          isToday: false,
          isSelected: false,
          isFuture: false,
          mood: CharacterMood.comfortable,
          totalSpent: 3000,
          baseAmount: 10000,
          effectiveBudget: 20000,
        ),
      ));
      expect(find.byKey(const Key('mini-split-bar')), findsOneWidget);
    });

    testWidgets('이월 예산이 없으면 미니 스플릿 바가 표시되지 않는다', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 22),
          isToday: false,
          isSelected: false,
          isFuture: false,
          mood: CharacterMood.comfortable,
          totalSpent: 3000,
          baseAmount: 10000,
          effectiveBudget: 10000,
        ),
      ));
      expect(find.byKey(const Key('mini-split-bar')), findsNothing);
    });

    testWidgets('양수 이월: 미니 스플릿 바 표시, 음수 바 없음', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 22),
          isToday: false,
          isSelected: false,
          isFuture: false,
          mood: CharacterMood.comfortable,
          totalSpent: 3000,
          baseAmount: 10000,
          effectiveBudget: 15000,
        ),
      ));
      expect(find.byKey(const Key('mini-split-bar')), findsOneWidget);
      expect(find.byKey(const Key('mini-split-bar-negative')), findsNothing);
    });

    testWidgets('음수 이월: 미니 스플릿 바 + 음수 바 표시', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 22),
          isToday: false,
          isSelected: false,
          isFuture: false,
          mood: CharacterMood.comfortable,
          totalSpent: 3000,
          baseAmount: 10000,
          effectiveBudget: 5000,
        ),
      ));
      expect(find.byKey(const Key('mini-split-bar')), findsOneWidget);
      expect(find.byKey(const Key('mini-split-bar-negative')), findsOneWidget);
    });

    testWidgets('미래 날짜: 음수 이월이어도 미니 스플릿 바 미표시', (tester) async {
      await tester.pumpWidget(wrap(
        WeeklyCalendarDayCell(
          date: DateTime(2026, 4, 22),
          isToday: false,
          isSelected: false,
          isFuture: true,
          baseAmount: 10000,
          effectiveBudget: 5000,
        ),
      ));
      expect(find.byKey(const Key('mini-split-bar')), findsNothing);
    });
  });
}
