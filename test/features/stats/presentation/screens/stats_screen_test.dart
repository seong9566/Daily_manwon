import 'package:daily_manwon/features/stats/presentation/screens/stats_screen.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// StatsViewModel 스텁 — DB/DI 없이 StatsScreen 렌더링만 테스트
class _StubStatsViewModelLoading extends StatsViewModel {
  @override
  StatsState build() {
    return StatsState(
      selectedMonth: DateTime(2024, 4, 1),
      isLoading: true,
    );
  }
}

/// StatsViewModel 에러 스텁
class _StubStatsViewModelError extends StatsViewModel {
  @override
  StatsState build() {
    return StatsState(
      selectedMonth: DateTime(2024, 4, 1),
      isLoading: false,
      errorMessage: '통계를 불러오지 못했습니다.',
    );
  }
}

Widget _buildApp(StatsViewModel Function() factory) => ProviderScope(
      overrides: [
        statsViewModelProvider.overrideWith(factory),
      ],
      child: const MaterialApp(home: StatsScreen()),
    );

void main() {
  group('StatsScreen', () {
    testWidgets('로딩 상태에서 CircularProgressIndicator를 표시한다', (tester) async {
      await tester.pumpWidget(_buildApp(_StubStatsViewModelLoading.new));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('에러 상태에서 에러 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(_buildApp(_StubStatsViewModelError.new));
      await tester.pump();

      expect(find.text('통계를 불러오지 못했습니다.'), findsOneWidget);
    });
  });
}
