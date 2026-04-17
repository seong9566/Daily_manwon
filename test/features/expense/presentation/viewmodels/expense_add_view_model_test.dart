import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/core/utils/result.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/expense_add_view_model.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_state.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// HomeViewModel 스텁 — DI/DB 없이 ExpenseAddViewModel 동작 테스트용
/// Notifier 내부를 mock하기 어려우므로 실제 HomeViewModel을 상속해 쓰기 메서드만 오버라이드한다.
class _FakeHomeViewModel extends HomeViewModel {
  _FakeHomeViewModel({
    this.addExpenseResult = const Success<void>(null),
  });

  final Result<void> addExpenseResult;
  final Result<void> updateExpenseResult = const Success<void>(null);
  final Result<void> addFavoriteResult = const Success<void>(null);

  int addExpenseCallCount = 0;
  int updateExpenseCallCount = 0;
  int addFavoriteCallCount = 0;
  ExpenseEntity? lastAddedExpense;
  ExpenseEntity? lastUpdatedExpense;

  @override
  HomeState build() => const HomeState(isLoading: false);

  @override
  Future<Result<void>> addExpense(ExpenseEntity expense) async {
    addExpenseCallCount++;
    lastAddedExpense = expense;
    return addExpenseResult;
  }

  @override
  Future<Result<void>> updateExpense(ExpenseEntity expense) async {
    updateExpenseCallCount++;
    lastUpdatedExpense = expense;
    return updateExpenseResult;
  }

  @override
  Future<Result<void>> addFavorite({
    required int amount,
    required ExpenseCategory category,
    String memo = '',
  }) async {
    addFavoriteCallCount++;
    return addFavoriteResult;
  }

  @override
  Future<void> refresh() async {}
}

ProviderContainer _container({
  required _FakeHomeViewModel homeVm,
}) {
  return ProviderContainer(
    overrides: [homeViewModelProvider.overrideWith(() => homeVm)],
  );
}

void main() {
  group('초기 상태', () {
    test('expense=null, date=null이면 amountString이 비어 있다', () {
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final state = container.read(
        expenseAddViewModelProvider((expense: null, date: null)),
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
      final args = (expense: tExpense, date: null);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final state = container.read(expenseAddViewModelProvider(args));
      expect(state.amountString, '5000');
      expect(state.selectedCategory, ExpenseCategory.food);
      expect(state.recordDate, DateTime(2026, 4, 17));
      expect(state.saveCreatedAt, DateTime(2026, 4, 17, 10));
    });

    test('과거 날짜 모드에서 saveCreatedAt이 정오(12시)로 설정된다', () {
      final args = (
        expense: null as ExpenseEntity?,
        date: DateTime(2026, 4, 1) as DateTime?,
      );
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final state = container.read(expenseAddViewModelProvider(args));
      expect(state.saveCreatedAt, DateTime(2026, 4, 1, 12));
    });
  });

  group('onNumberPressed', () {
    test('7자리 초과 시 true(흔들림) 반환', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      for (final d in ['1', '2', '3', '4', '5', '6', '7']) {
        notifier.onNumberPressed(d);
      }
      final needsShake = notifier.onNumberPressed('8');
      expect(needsShake, true);
      expect(
        container.read(expenseAddViewModelProvider(args)).amountString,
        '1234567',
      );
    });

    test('선행 0 입력 시 무시된다', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      final needsShake = notifier.onNumberPressed('0');
      expect(needsShake, false);
      expect(container.read(expenseAddViewModelProvider(args)).amountString, '');
    });

    test('"00" 입력 시 두 번 이어붙인다', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      notifier.onNumberPressed('5');
      notifier.onNumberPressed('00');
      expect(
        container.read(expenseAddViewModelProvider(args)).amountString,
        '500',
      );
    });
  });

  group('addAmount', () {
    test('9,999,999 초과 시 true(흔들림) 반환', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      for (final d in ['9', '9', '9', '9', '9', '9', '9']) {
        notifier.onNumberPressed(d);
      }
      final needsShake = notifier.addAmount(1);
      expect(needsShake, true);
    });

    test('정상 범위 추가 시 false 반환, 금액 갱신', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      final needsShake = notifier.addAmount(5000);
      expect(needsShake, false);
      expect(
        container.read(expenseAddViewModelProvider(args)).amountString,
        '5000',
      );
    });
  });

  group('applyTemplate', () {
    test('템플릿 적용 시 금액·카테고리가 설정된다', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      notifier.applyTemplate((
        amount: 3500,
        category: ExpenseCategory.food,
        memo: '',
      ));

      final state = container.read(expenseAddViewModelProvider(args));
      expect(state.amountString, '3500');
      expect(state.selectedCategory, ExpenseCategory.food);
    });
  });

  group('toggleFavorite', () {
    test('호출할 때마다 addToFavorite이 토글된다', () {
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: _FakeHomeViewModel());
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      notifier.toggleFavorite();
      expect(
        container.read(expenseAddViewModelProvider(args)).addToFavorite,
        true,
      );
      notifier.toggleFavorite();
      expect(
        container.read(expenseAddViewModelProvider(args)).addToFavorite,
        false,
      );
    });
  });

  group('save', () {
    test('신규 저장 성공 시 Success 반환, addExpense 호출됨', () async {
      final fake = _FakeHomeViewModel();
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: fake);
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      // 3000 입력
      notifier.onNumberPressed('3');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');

      final result = await notifier.save();
      expect(result.isSuccess, true);
      expect(fake.addExpenseCallCount, 1);
      expect(fake.lastAddedExpense?.amount, 3000);
      expect(fake.lastAddedExpense?.category, ExpenseCategory.cafe);
    });

    test('편집 모드 저장 시 updateExpense가 호출된다', () async {
      final fake = _FakeHomeViewModel();
      final tExpense = ExpenseEntity(
        id: 42,
        amount: 2000,
        category: ExpenseCategory.food,
        createdAt: DateTime(2026, 4, 17, 10),
      );
      final args = (expense: tExpense, date: null);
      final container = _container(homeVm: fake);
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      // 기존 2000 → 5000으로 변경 (백스페이스 후 새 금액 입력)
      notifier.addAmount(3000);

      final result = await notifier.save();
      expect(result.isSuccess, true);
      expect(fake.updateExpenseCallCount, 1);
      expect(fake.addExpenseCallCount, 0);
      expect(fake.lastUpdatedExpense?.id, 42);
      expect(fake.lastUpdatedExpense?.amount, 5000);
    });

    test('addToFavorite=true이면 성공 시 addFavorite도 호출된다', () async {
      final fake = _FakeHomeViewModel();
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: fake);
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      notifier.onNumberPressed('5');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.toggleFavorite();

      await notifier.save();
      expect(fake.addExpenseCallCount, 1);
      expect(fake.addFavoriteCallCount, 1);
    });

    test('실패 시 saveError=true, isSaving=false로 복구된다', () async {
      final fake = _FakeHomeViewModel(
        addExpenseResult: const Failed<void>(DatabaseFailure('DB fail')),
      );
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: fake);
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      notifier.onNumberPressed('1');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');
      notifier.onNumberPressed('0');

      final result = await notifier.save();
      expect(result.isSuccess, false);
      final state = container.read(expenseAddViewModelProvider(args));
      expect(state.saveError, true);
      expect(state.isSaving, false);
    });

    test('canSave=false(금액 0)이면 ValidationFailure 반환하고 아무것도 호출하지 않는다', () async {
      final fake = _FakeHomeViewModel();
      final args = (expense: null as ExpenseEntity?, date: null as DateTime?);
      final container = _container(homeVm: fake);
      addTearDown(container.dispose);

      final notifier = container.read(
        expenseAddViewModelProvider(args).notifier,
      );
      final result = await notifier.save();
      expect(result.isSuccess, false);
      expect(fake.addExpenseCallCount, 0);
      expect(fake.updateExpenseCallCount, 0);
    });
  });
}
