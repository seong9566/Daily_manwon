import 'package:daily_manwon/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:daily_manwon/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// CalendarViewModel 스텁 — DB/DI 없이 FAB 렌더링만 테스트
class _StubCalendarViewModel extends CalendarViewModel {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(
      selectedMonth: DateTime(now.year, now.month, 1),
      selectedWeekStart: now,
      isLoading: false,
    );
  }
}

Widget _buildApp() => ProviderScope(
      overrides: [
        calendarViewModelProvider.overrideWith(_StubCalendarViewModel.new),
      ],
      child: const MaterialApp(home: CalendarScreen()),
    );

void main() {
  group('CalendarScreen FAB', () {
    testWidgets('FAB이 항상 렌더링된다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB 아이콘이 add_rounded이다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}
