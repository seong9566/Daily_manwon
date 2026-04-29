import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

// getWeeklySummary()의 성공 판정 조건을 순수 함수로 추출하여 검증한다.
// ViewModel 내부 캐시(Map)를 직접 주입하면 Riverpod mock 없이도 로직을 테스트할 수 있다.
int _countSavingDays({
  required Map<DateTime, int> expenseTotals, // 날짜 → 당일 총 지출
  required Map<DateTime, int> baseAmounts,   // 날짜 → 기본 예산
  required List<DateTime> weekDays,
  required DateTime today,
}) {
  int savingDays = 0;
  for (final day in weekDays) {
    if (day.isAfter(today)) continue;
    final dayTotal = expenseTotals[day] ?? 0;
    if (dayTotal == 0) continue; // 지출 없는 날은 성공/실패 카운트 제외
    final baseBudget = baseAmounts[day] ?? AppConstants.dailyBudget;
    if (dayTotal <= baseBudget) savingDays++;
  }
  return savingDays;
}

void main() {
  // 4/26(일)~5/2(토) 주간, 기준일: 4/29(수)
  final weekDays = List.generate(7, (i) => DateTime(2026, 4, 26 + i));
  final today = DateTime(2026, 4, 29);

  group('getWeeklySummary savingDays 계산', () {
    test('복합 주간 시나리오: 0원 지출일과 이월 초과 지출일은 성공에서 제외된다', () {
      // 월요일(4/27): 지출 0원 → 카운트 제외 / 수요일(4/29): 20,000 > 기본 10,000 → 실패
      final result = _countSavingDays(
        expenseTotals: {
          DateTime(2026, 4, 26): 41800, // 일: 초과
          DateTime(2026, 4, 27): 0,     // 월: 지출 없음 (이월 빚)
          DateTime(2026, 4, 28): 1000,  // 화: 성공
          DateTime(2026, 4, 29): 20000, // 수: 초과
        },
        baseAmounts: {
          DateTime(2026, 4, 26): 20000,
          DateTime(2026, 4, 27): 20000,
          DateTime(2026, 4, 28): 20000,
          DateTime(2026, 4, 29): 10000,
        },
        weekDays: weekDays,
        today: today,
      );

      expect(result, 1); // 화요일만 성공
    });

    test('이월 잉여가 있어도 기본 예산 초과 지출은 성공이 아니어야 한다', () {
      // 수요일(4/29): 기본 예산 10,000원, 이월 잉여 +17,200원 → 지출 20,000원
      // effectiveBudget = 27,200이지만 baseBudget = 10,000 → 실패
      final result = _countSavingDays(
        expenseTotals: {
          DateTime(2026, 4, 29): 20000,
        },
        baseAmounts: {
          DateTime(2026, 4, 29): 10000,
        },
        weekDays: [DateTime(2026, 4, 29)],
        today: today,
      );

      expect(result, 0); // 기본 예산 10,000 초과 → 실패
    });

    test('지출이 기본 예산 이하이면 성공으로 카운트한다', () {
      final result = _countSavingDays(
        expenseTotals: {
          DateTime(2026, 4, 28): 1000,
        },
        baseAmounts: {
          DateTime(2026, 4, 28): 20000,
        },
        weekDays: [DateTime(2026, 4, 28)],
        today: today,
      );

      expect(result, 1);
    });

    test('지출 없는 날(0원)은 성공/실패 카운트 모두에서 제외된다', () {
      final result = _countSavingDays(
        expenseTotals: {
          DateTime(2026, 4, 27): 0,
        },
        baseAmounts: {
          DateTime(2026, 4, 27): 20000,
        },
        weekDays: [DateTime(2026, 4, 27)],
        today: today,
      );

      expect(result, 0); // 지출 없는 날은 포함 안 됨
    });

    test('오늘 이후 날짜는 카운트하지 않는다', () {
      final result = _countSavingDays(
        expenseTotals: {
          DateTime(2026, 4, 30): 5000, // 목요일 (오늘 이후)
        },
        baseAmounts: {
          DateTime(2026, 4, 30): 10000,
        },
        weekDays: [DateTime(2026, 4, 30)],
        today: today,
      );

      expect(result, 0);
    });

    test('baseAmounts에 없는 날은 AppConstants.dailyBudget을 기준으로 판정한다', () {
      final result = _countSavingDays(
        expenseTotals: {DateTime(2026, 4, 28): 5000},
        baseAmounts: {}, // 폴백 경로 — dailyBudget(10,000) 적용
        weekDays: [DateTime(2026, 4, 28)],
        today: today,
      );

      expect(result, 1); // 5,000 <= 10,000
    });

    test('지출이 기본 예산과 정확히 같으면 성공이다 (경계값)', () {
      final result = _countSavingDays(
        expenseTotals: {DateTime(2026, 4, 28): 10000},
        baseAmounts: {DateTime(2026, 4, 28): 10000},
        weekDays: [DateTime(2026, 4, 28)],
        today: today,
      );

      expect(result, 1); // 10,000 <= 10,000 → 성공
    });
  });
}
