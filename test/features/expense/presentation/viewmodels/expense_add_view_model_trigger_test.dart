import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/core/di/injection.dart';
import 'package:daily_manwon/core/providers/budget_change_provider.dart';
import 'package:daily_manwon/core/utils/result.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_expense_use_case.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_favorite_use_case.dart';
import 'package:daily_manwon/features/expense/domain/usecases/delete_expense_use_case.dart';
import 'package:daily_manwon/features/expense/domain/usecases/update_expense_use_case.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/expense_add_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────

class _FakeAddExpense implements AddExpenseUseCase {
  Result<ExpenseEntity>? result;

  @override
  Future<Result<ExpenseEntity>> execute(ExpenseEntity expense) async {
    return result ?? Result.success(expense);
  }
}

class _FakeAddExpenseFail implements AddExpenseUseCase {
  @override
  Future<Result<ExpenseEntity>> execute(ExpenseEntity expense) async {
    return const Failed<ExpenseEntity>(DatabaseFailure('DB fail'));
  }
}

class _FakeUpdateExpense implements UpdateExpenseUseCase {
  @override
  Future<Result<void>> execute(ExpenseEntity expense) async {
    return Result.success(null);
  }
}

class _FakeAddFavorite implements AddFavoriteUseCase {
  @override
  Future<Result<void>> execute({
    required int amount,
    required ExpenseCategory category,
    String memo = '',
  }) async {
    return Result.success(null);
  }
}

class _FakeDeleteExpense implements DeleteExpenseUseCase {
  @override
  Future<void> execute(int id) async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────

void _registerFakes({AddExpenseUseCase? addExpense, bool failAdd = false}) {
  getIt.reset();
  if (failAdd) {
    getIt.registerSingleton<AddExpenseUseCase>(_FakeAddExpenseFail());
  } else {
    getIt.registerSingleton<AddExpenseUseCase>(addExpense ?? _FakeAddExpense());
  }
  getIt.registerSingleton<UpdateExpenseUseCase>(_FakeUpdateExpense());
  getIt.registerSingleton<AddFavoriteUseCase>(_FakeAddFavorite());
  getIt.registerSingleton<DeleteExpenseUseCase>(_FakeDeleteExpense());
}

ProviderContainer _container() => ProviderContainer();

// ── Tests ─────────────────────────────────────────────────────────────────

void main() {
  tearDown(() => getIt.reset());

  // T-TRIG-1: 과거 날짜 지출 저장 성공 시 budgetChangeProvider가 1 증가한다
  test('T-TRIG-1: 과거 날짜 지출 저장 성공 시 budgetChangeProvider가 1 증가한다', () async {
    _registerFakes();

    final container = _container();
    addTearDown(container.dispose);

    // 오늘보다 과거 날짜 지정
    final pastDate = DateTime.now().subtract(const Duration(days: 1));

    final notifier = container.read(
      expenseAddViewModelProvider(expense: null, date: pastDate).notifier,
    );
    notifier.onNumberPressed('5');
    notifier.onNumberPressed('0');
    notifier.onNumberPressed('0');
    notifier.onNumberPressed('0');

    final before = container.read(budgetChangeProvider);
    final result = await notifier.save();

    expect(result.isSuccess, true);
    expect(container.read(budgetChangeProvider), before + 1);
  });

  // T-TRIG-2: 오늘 날짜 지출 저장 시 budgetChangeProvider가 변경되지 않는다
  test('T-TRIG-2: 오늘 날짜 지출 저장 시 budgetChangeProvider가 변경되지 않는다', () async {
    _registerFakes();

    final container = _container();
    addTearDown(container.dispose);

    // date=null → 오늘 날짜로 초기화
    final notifier = container.read(
      expenseAddViewModelProvider(expense: null, date: null).notifier,
    );
    notifier.onNumberPressed('3');
    notifier.onNumberPressed('0');
    notifier.onNumberPressed('0');
    notifier.onNumberPressed('0');

    final before = container.read(budgetChangeProvider);
    final result = await notifier.save();

    expect(result.isSuccess, true);
    expect(container.read(budgetChangeProvider), before);
  });

  // T-TRIG-3: 저장 실패 시 budgetChangeProvider가 변경되지 않는다
  test('T-TRIG-3: 저장 실패 시 budgetChangeProvider가 변경되지 않는다', () async {
    _registerFakes(failAdd: true);

    final container = _container();
    addTearDown(container.dispose);

    final pastDate = DateTime.now().subtract(const Duration(days: 2));

    final notifier = container.read(
      expenseAddViewModelProvider(expense: null, date: pastDate).notifier,
    );
    notifier.onNumberPressed('1');
    notifier.onNumberPressed('0');
    notifier.onNumberPressed('0');
    notifier.onNumberPressed('0');

    final before = container.read(budgetChangeProvider);
    final result = await notifier.save();

    expect(result.isSuccess, false);
    expect(container.read(budgetChangeProvider), before);
  });

  // T-TRIG-4: 과거 날짜 지출 삭제 시 budgetChangeProvider가 1 증가한다
  test('T-TRIG-4: 과거 날짜 지출 삭제 시 budgetChangeProvider가 1 증가한다', () async {
    _registerFakes();

    final container = _container();
    addTearDown(container.dispose);

    final pastDate = DateTime.now().subtract(const Duration(days: 3));

    final notifier = container.read(
      expenseAddViewModelProvider(expense: null, date: pastDate).notifier,
    );

    final before = container.read(budgetChangeProvider);
    await notifier.delete(99);

    expect(container.read(budgetChangeProvider), before + 1);
  });

  // T-TRIG-5: 오늘 날짜 지출 삭제 시 budgetChangeProvider가 변경되지 않는다
  test('T-TRIG-5: 오늘 날짜 지출 삭제 시 budgetChangeProvider가 변경되지 않는다', () async {
    _registerFakes();

    final container = _container();
    addTearDown(container.dispose);

    // date=null → 오늘 날짜로 초기화
    final notifier = container.read(
      expenseAddViewModelProvider(expense: null, date: null).notifier,
    );

    final before = container.read(budgetChangeProvider);
    await notifier.delete(1);

    expect(container.read(budgetChangeProvider), before);
  });
}
