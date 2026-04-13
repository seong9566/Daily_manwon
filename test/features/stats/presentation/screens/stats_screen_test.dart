// test/features/stats/presentation/screens/stats_screen_test.dart
import 'package:daily_manwon/features/stats/presentation/screens/stats_screen.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubStatsViewModel extends StatsViewModel {
  @override
  StatsState build() {
    return StatsState(
      selectedMonth: DateTime(2024, 4, 1),
      isLoading: true,
    );
  }
}

Widget _buildApp() => ProviderScope(
      overrides: [
        statsViewModelProvider.overrideWith(_StubStatsViewModel.new),
      ],
      child: const MaterialApp(home: StatsScreen()),
    );

void main() {
  group('StatsScreen 독립 화면', () {
    testWidgets('Scaffold를 포함한다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('로딩 상태에서 CircularProgressIndicator를 표시한다', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
