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
  });
}
