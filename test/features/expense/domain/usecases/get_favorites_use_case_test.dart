import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/favorite_expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/get_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteExpenseRepository extends Mock
    implements FavoriteExpenseRepository {}

void main() {
  late MockFavoriteExpenseRepository repository;
  late GetFavoritesUseCase useCase;

  setUp(() {
    repository = MockFavoriteExpenseRepository();
    useCase = GetFavoritesUseCase(repository);
  });

  test('repository에서 즐겨찾기 목록 반환', () async {
    final favorites = [
      FavoriteExpenseEntity(
        id: 1,
        amount: 3500,
        category: ExpenseCategory.shopping,
        usageCount: 5,
        createdAt: DateTime.utc(2026, 4, 1),
      ),
    ];
    when(() => repository.getFavorites()).thenAnswer((_) async => favorites);

    final result = await useCase.execute();

    expect(result, favorites);
    verify(() => repository.getFavorites()).called(1);
  });
}
