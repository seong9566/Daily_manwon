import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/home/presentation/widgets/expense_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final expense = ExpenseEntity(
    id: 1, amount: 3500, category: 2, memo: '',
    createdAt: DateTime(2026, 4, 13, 10, 30),
  );

  testWidgets('onRepeat null이면 반복 버튼 미표시', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(expense: expense, onTap: () {}),
        ),
      ),
    );
    expect(find.text('↩'), findsNothing);
  });

  testWidgets('onRepeat 제공 시 반복 버튼 표시', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(
            expense: expense,
            onTap: () {},
            onRepeat: () {},
          ),
        ),
      ),
    );
    expect(find.text('↩'), findsOneWidget);
  });

  testWidgets('반복 버튼 탭 시 onRepeat 호출', (tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(
            expense: expense,
            onTap: () {},
            onRepeat: () => called = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('↩'));
    expect(called, isTrue);
  });
}
