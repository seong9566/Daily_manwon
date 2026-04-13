import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/favorite_expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteExpenseRepository extends Mock
    implements FavoriteExpenseRepository {}

void main() {
  late MockFavoriteExpenseRepository repository;
  late AddFavoriteUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      FavoriteExpenseEntity(
        id: 0,
        amount: 0,
        category: 0,
        usageCount: 0,
        createdAt: DateTime.utc(2026),
      ),
    );
  });

  setUp(() {
    repository = MockFavoriteExpenseRepository();
    useCase = AddFavoriteUseCase(repository);
  });

  test('repository.addFavorite 호출', () async {
    when(() => repository.addFavorite(any())).thenAnswer((_) async {});

    await useCase.execute(
      amount: 3500,
      category: 2,
      memo: '',
    );

    verify(() => repository.addFavorite(any())).called(1);
  });
}
