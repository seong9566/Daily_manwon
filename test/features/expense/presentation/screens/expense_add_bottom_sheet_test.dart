import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/presentation/screens/expense_add_screen.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/favorite_templates_state.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/favorite_templates_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubFavoriteTemplatesViewModel extends FavoriteTemplatesViewModel {
  @override
  FavoriteTemplatesState build() =>
      const FavoriteTemplatesState(isLoading: false);
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        favoriteTemplatesViewModelProvider.overrideWith(
          _StubFavoriteTemplatesViewModel.new,
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('showExpenseAddBottomSheet — date 파라미터 헤더 표시', () {
    testWidgets('date 없이 열면 오늘 날짜가 헤더에 표시된다', (tester) async {
      final today = DateTime.now();
      const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
      final expectedTitle =
          '${today.month}월 ${today.day}일 ${weekdays[today.weekday - 1]}';

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
      // 2026-04-09 is a Thursday (목요일)
      final pastDate = DateTime(2026, 4, 9);
      const expectedTitle = '4월 9일 목요일';

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
      // 2026-03-15 is a Sunday (일요일)
      final existingExpense = ExpenseEntity(
        id: 1,
        amount: 3000,
        category: ExpenseCategory.food,
        createdAt: DateTime(2026, 3, 15),
      );
      const expectedTitle = '3월 15일 일요일';

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
