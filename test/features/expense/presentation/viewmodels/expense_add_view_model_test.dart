import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/core/di/injection.dart';
import 'package:daily_manwon/core/utils/result.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_expense_use_case.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_favorite_use_case.dart';
import 'package:daily_manwon/features/expense/domain/usecases/update_expense_use_case.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/expense_add_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAddExpense implements AddExpenseUseCase {
  Result<ExpenseEntity>? result;
  int callCount = 0;
  ExpenseEntity? lastExpense;

  @override
  Future<Result<ExpenseEntity>> execute(ExpenseEntity expense) async {
    callCount++;
    lastExpense = expense;
    return result ?? Result.success(expense);
  }
}

class _FakeUpdateExpense implements UpdateExpenseUseCase {
  Result<void>? result;
  int callCount = 0;
  ExpenseEntity? lastExpense;

  @override
  Future<Result<void>> execute(ExpenseEntity expense) async {
    callCount++;
    lastExpense = expense;
    return result ?? Result.success(null);
  }
}

class _FakeAddFavorite implements AddFavoriteUseCase {
  int callCount = 0;

  @override
  Future<Result<void>> execute({
    required int amount,
    required ExpenseCategory category,
    String memo = '',
  }) async {
    callCount++;
    return Result.success(null);
  }
}

ProviderContainer _container() => ProviderContainer();

void _registerFakes({
  _FakeAddExpense? addExpense,
  _FakeUpdateExpense? updateExpense,
  _FakeAddFavorite? addFavorite,
}) {
  getIt.reset();
  getIt.registerSingleton<AddExpenseUseCase>(addExpense ?? _FakeAddExpense());
  getIt.registerSingleton<UpdateExpenseUseCase>(
    updateExpense ?? _FakeUpdateExpense(),
  );
  getIt.registerSingleton<AddFavoriteUseCase>(addFavorite ?? _FakeAddFavorite());
}

void main() {
  tearDown(() => getIt.reset());

  group('초기 상태', () {
    test('expense=null, date=null이면 amountString이 비어 있다', () {
      final container = _container();
      addTearDown(container.dispose);

      final state = container.read(
        expenseAddViewModelProvider(expense: null, date: null),
      );
      expect(state.amountString, '');
      expect(state.selectedCategory, ExpenseCategory.cafe);
      expect(state.isSaving, false);
      expect(state.addToFavorite, false);
    });

    test('편집 모드에서 expense 금액·카테고리로 초기화된다', () {
      final tExpense = ExpenseEntity(
        id: 1,
        amount: 5000,
        category: ExpenseCategory.food,
        createdAt: DateTime(2026, 4, 17, 10),
      );
      final container = _container();
      addTearDown(container.dispose);

      final state = container.read(
        expenseAddViewModelProvider(expense: tExpense, date: null),
      );
      expect(state.amountString, '5000');
      expect(state.selectedCategory, ExpenseCategory.food);
      expect(state.recordDate, DateTime(2026, 4, 17));
      expect(state.saveCreatedAt, DateTime(2026, 4, 17, 10));
    });

    test('과거 날짜 모드에서 saveCreatedAt이 정오(12시)로 설정된다', () {
      final container = _container();
      addTearDown(container.dispose);

      final state = container.read(
        expenseAddViewModelProvider(expense: null, date: DateTime(2026, 4, 1)),
      );
      expect(state.saveCreatedAt, DateTime(2026, 4, 1, 12));
    });
  });

  group('onNumberPressed', () {
    test('7자리 초과 시 true(흔들림) 반환', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      for (final d in ['1', '2', '3', '4', '5', '6', '7']) {
        notifier.onNumberPressed(d);
      }
      final needsShake = notifier.onNumberPressed('8');
      expect(needsShake, true);
      expect(
        container
            .read(expenseAddViewModelProvider(expense: null, date: null))
            .amountString,
        '1234567',
      );
    });

    test('선행 0 입력 시 무시된다', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      final needsShake = notifier.onNumberPressed('0');
      expect(needsShake, false);
      expect(
        container
            .read(expenseAddViewModelProvider(expense: null, date: null))
            .amountString,
        '',
      );
    });

    test('"00" 입력 시 두 번 이어붙인다', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      notifier.onNumberPressed('5');
      notifier.onNumberPressed('00');
      expect(
        container
            .read(expenseAddViewModelProvider(expense: null, date: null))
            .amountString,
        '500',
      );
    });
  });

  group('addAmount', () {
    test('9,999,999 초과 시 true(흔들림) 반환', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      for (final d in ['9', '9', '9', '9', '9', '9', '9']) {
        notifier.onNumberPressed(d);
      }
      final needsShake = notifier.addAmount(1);
      expect(needsShake, true);
    });

    test('정상 범위 추가 시 false 반환, 금액 갱신', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      final needsShake = notifier.addAmount(5000);
      expect(needsShake, false);
      expect(
        container
            .read(expenseAddViewModelProvider(expense: null, date: null))
            .amountString,
        '5000',
      );
    });
  });

  group('applyTemplate', () {
    test('템플릿 적용 시 금액·카테고리가 설정된다', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      notifier.applyTemplate((
        amount: 3500,
        category: ExpenseCategory.food,
        memo: '',
      ));

      final state =
          container.read(expenseAddViewModelProvider(expense: null, date: null));
      expect(state.amountString, '3500');
      expect(state.selectedCategory, ExpenseCategory.food);
    });
  });

  group('toggleFavorite', () {
    test('호출할 때마다 addToFavorite이 토글된다', () {
      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      notifier.toggleFavorite();
      expect(
        container
            .read(expenseAddViewModelProvider(expense: null, date: null))
            .addToFavorite,
        true,
      );
      notifier.toggleFavorite();
      expect(
        container
            .read(expenseAddViewModelProvider(expense: null, date: null))
            .addToFavorite,
        false,
      );
    });
  });

  group('save', () {
    test('신규 저장 성공 시 Success 반환, addExpense 호출됨', () async {
      final fakeAdd = _FakeAddExpense();
      _registerFakes(addExpense: fakeAdd);

      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      notifier.onNumberPressed('3');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');

      final result = await notifier.save();
      expect(result.isSuccess, true);
      expect(fakeAdd.callCount, 1);
      expect(fakeAdd.lastExpense?.amount, 3000);
      expect(fakeAdd.lastExpense?.category, ExpenseCategory.cafe);
    });

    test('편집 모드 저장 시 updateExpense가 호출된다', () async {
      final fakeUpdate = _FakeUpdateExpense();
      final fakeAdd = _FakeAddExpense();
      _registerFakes(addExpense: fakeAdd, updateExpense: fakeUpdate);

      final tExpense = ExpenseEntity(
        id: 42,
        amount: 2000,
        category: ExpenseCategory.food,
        createdAt: DateTime(2026, 4, 17, 10),
      );

      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: tExpense, date: null).notifier,
      );
      notifier.addAmount(3000);

      final result = await notifier.save(originalExpense: tExpense);
      expect(result.isSuccess, true);
      expect(fakeUpdate.callCount, 1);
      expect(fakeAdd.callCount, 0);
      expect(fakeUpdate.lastExpense?.id, 42);
      expect(fakeUpdate.lastExpense?.amount, 5000);
    });

    test('addToFavorite=true이면 성공 시 addFavorite도 호출된다', () async {
      final fakeAdd = _FakeAddExpense();
      final fakeFav = _FakeAddFavorite();
      _registerFakes(addExpense: fakeAdd, addFavorite: fakeFav);

      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      notifier.onNumberPressed('5');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.toggleFavorite();

      await notifier.save();
      expect(fakeAdd.callCount, 1);
      expect(fakeFav.callCount, 1);
    });

    test('실패 시 saveError=true, isSaving=false로 복구된다', () async {
      final fakeAdd = _FakeAddExpense()
        ..result = const Failed<ExpenseEntity>(DatabaseFailure('DB fail'));
      _registerFakes(addExpense: fakeAdd);

      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      notifier.onNumberPressed('1');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');

      final result = await notifier.save();
      expect(result.isSuccess, false);
      final state =
          container.read(expenseAddViewModelProvider(expense: null, date: null));
      expect(state.saveError, true);
      expect(state.isSaving, false);
    });

    test('canSave=false(금액 0)이면 ValidationFailure 반환하고 아무것도 호출하지 않는다', () async {
      final fakeAdd = _FakeAddExpense();
      final fakeUpdate = _FakeUpdateExpense();
      _registerFakes(addExpense: fakeAdd, updateExpense: fakeUpdate);

      final container = _container();
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(expense: null, date: null).notifier,
      );
      final result = await notifier.save();
      expect(result.isSuccess, false);
      expect(fakeAdd.callCount, 0);
      expect(fakeUpdate.callCount, 0);
    });
  });
}
