import 'dart:async';

import 'package:daily_manwon/features/stats/presentation/screens/stats_screen.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_state.dart';
import 'package:daily_manwon/features/stats/presentation/viewmodels/stats_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// StatsViewModel 스텁 — 영원히 완료되지 않아 AsyncLoading 상태 유지
class _StubStatsViewModelLoading extends StatsViewModel {
  @override
  Future<StatsState> build() => Completer<StatsState>().future;
}

/// StatsViewModel 에러 스텁
class _StubStatsViewModelError extends StatsViewModel {
  @override
  Future<StatsState> build() async {
    throw Exception('통계를 불러오지 못했습니다.');
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
      // pumpAndSettle: Future 에러 완료 후 AsyncError 상태 반영 대기
      await tester.pumpAndSettle();

      expect(find.text('통계를 불러오지 못했습니다.'), findsOneWidget);
    });
  });
}
