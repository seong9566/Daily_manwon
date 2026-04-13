import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/stats/domain/entities/category_stat.dart';
import 'package:daily_manwon/features/stats/domain/repositories/stats_repository.dart';
import 'package:daily_manwon/features/stats/domain/usecases/get_category_stats_use_case.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late MockStatsRepository repository;
  late GetCategoryStatsUseCase useCase;

  setUp(() {
    repository = MockStatsRepository();
    useCase = GetCategoryStatsUseCase(repository);
  });

  test('레포지토리 결과를 그대로 반환한다', () async {
    final stats = [
      const CategoryStat(categoryIndex: 0, totalAmount: 5000, percentage: 0.5),
      const CategoryStat(categoryIndex: 2, totalAmount: 5000, percentage: 0.5),
    ];
    when(() => repository.getCategoryStats(year: 2026, month: 4))
        .thenAnswer((_) async => stats);

    final result = await useCase.execute(year: 2026, month: 4);

    expect(result, stats);
    verify(() => repository.getCategoryStats(year: 2026, month: 4)).called(1);
  });
}
