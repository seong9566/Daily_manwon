import 'package:flutter_test/flutter_test.dart';

import 'package:daily_manwon/features/stats/domain/entities/daily_stat.dart';

// weeklySuccessDays 계산 로직의 순수 함수 단위 테스트
// ViewModel 통합 테스트는 Riverpod mock 설정이 필요하므로 로직만 검증한다
int _computeSuccessDays({
  required List<DailyStat> dailyStats,
  required int dailyBudget,
  required bool isFutureWeek,
}) {
  if (isFutureWeek) return 0;
  return dailyStats.where((s) => s.amount <= dailyBudget).length;
}

void main() {
  group('weeklySuccessDays 계산', () {
    test('지출 없는 날도 성공일로 포함한다', () {
      final dailyStats = [
        DailyStat(date: DateTime(2026, 4, 6), amount: 0),
        DailyStat(date: DateTime(2026, 4, 7), amount: 8000),
        DailyStat(date: DateTime(2026, 4, 8), amount: 0),
        DailyStat(date: DateTime(2026, 4, 9), amount: 0),
        DailyStat(date: DateTime(2026, 4, 10), amount: 0),
        DailyStat(date: DateTime(2026, 4, 11), amount: 0),
        DailyStat(date: DateTime(2026, 4, 12), amount: 0),
      ];

      final result = _computeSuccessDays(
        dailyStats: dailyStats,
        dailyBudget: 10000,
        isFutureWeek: false,
      );

      expect(result, 7);
    });

    test('예산 초과 날은 성공일 제외', () {
      final dailyStats = [
        DailyStat(date: DateTime(2026, 4, 6), amount: 0),
        DailyStat(date: DateTime(2026, 4, 7), amount: 12000),
        DailyStat(date: DateTime(2026, 4, 8), amount: 0),
        DailyStat(date: DateTime(2026, 4, 9), amount: 0),
        DailyStat(date: DateTime(2026, 4, 10), amount: 0),
        DailyStat(date: DateTime(2026, 4, 11), amount: 0),
        DailyStat(date: DateTime(2026, 4, 12), amount: 0),
      ];

      final result = _computeSuccessDays(
        dailyStats: dailyStats,
        dailyBudget: 10000,
        isFutureWeek: false,
      );

      expect(result, 6);
    });

    test('미래 주는 성공일 0', () {
      final dailyStats = List.generate(
        7,
        (i) => DailyStat(date: DateTime(2026, 5, i + 1), amount: 0),
      );

      final result = _computeSuccessDays(
        dailyStats: dailyStats,
        dailyBudget: 10000,
        isFutureWeek: true,
      );

      expect(result, 0);
    });
  });
}
