import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/presentation/screens/expense_add_screen.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// HomeViewModel 스텁 — DI/DB 없이 바텀시트 렌더링만 테스트하기 위한 최소 구현
class _StubHomeViewModel extends HomeViewModel {
  @override
  HomeState build() => const HomeState(isLoading: false);

  @override
  Future<void> addExpense(ExpenseEntity expense) async {}

  @override
  Future<void> refresh() async {}
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        homeViewModelProvider.overrideWith(_StubHomeViewModel.new),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('showExpenseAddBottomSheet — date 파라미터 헤더 표시', () {
    testWidgets('date 없이 열면 오늘 날짜가 헤더에 표시된다', (tester) async {
      final today = DateTime.now();
      final expectedTitle = '${today.month}월 ${today.day}일 지출 기록';

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () => showExpenseAddBottomSheet(ctx),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(expectedTitle), findsOneWidget);
    });

    testWidgets('과거 date를 지정하면 해당 날짜가 헤더에 표시된다', (tester) async {
      final pastDate = DateTime(2026, 4, 9);
      const expectedTitle = '4월 9일 지출 기록';

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () =>
                  showExpenseAddBottomSheet(ctx, date: pastDate),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(expectedTitle), findsOneWidget);
    });

    testWidgets('편집 모드에서는 기존 지출의 날짜가 헤더에 표시된다', (tester) async {
      final existingExpense = ExpenseEntity(
        id: 1,
        amount: 3000,
        category: 0,
        createdAt: DateTime(2026, 3, 15),
      );
      const expectedTitle = '3월 15일 지출 기록';

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () =>
                  showExpenseAddBottomSheet(ctx, expense: existingExpense),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text(expectedTitle), findsOneWidget);
    });
  });
}
