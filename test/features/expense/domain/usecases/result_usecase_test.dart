import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/core/utils/result.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_expense_use_case.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

void main() {
  late MockExpenseRepository mockRepo;
  late AddExpenseUseCase sut;

  final tExpense = ExpenseEntity(
    amount: 3000,
    category: ExpenseCategory.cafe,
    createdAt: DateTime(2026, 4, 17),
  );

  setUp(() {
    mockRepo = MockExpenseRepository();
    sut = AddExpenseUseCase(mockRepo);
    registerFallbackValue(tExpense);
  });

  test('성공 시 Success<ExpenseEntity> 반환', () async {
    when(() => mockRepo.addExpense(any())).thenAnswer((_) async => tExpense);
    final result = await sut.execute(tExpense);
    expect(result, isA<Success<ExpenseEntity>>());
  });

  test('DB 예외 시 Failed<DatabaseFailure> 반환', () async {
    when(() => mockRepo.addExpense(any())).thenThrow(Exception('DB error'));
    final result = await sut.execute(tExpense);
    expect(result, isA<Failed<ExpenseEntity>>());
    expect((result as Failed).failure, isA<DatabaseFailure>());
  });
}
