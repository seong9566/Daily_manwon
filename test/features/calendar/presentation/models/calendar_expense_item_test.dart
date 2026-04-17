import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/calendar/presentation/models/calendar_expense_item.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarExpenseItem', () {
    final item = CalendarExpenseItem(
      id: 1,
      amount: 4800,
      category: ExpenseCategory.food,
      memo: '점심',
      createdAt: DateTime(2026, 4, 17, 12, 30),
    );

    test('필드 값이 올바르게 저장된다', () {
      expect(item.id, 1);
      expect(item.amount, 4800);
      expect(item.category, ExpenseCategory.food);
      expect(item.memo, '점심');
      expect(item.createdAt, DateTime(2026, 4, 17, 12, 30));
    });

    test('toExpenseEntity()는 동일 필드를 가진 ExpenseEntity를 반환한다', () {
      final entity = item.toExpenseEntity();
      expect(entity.id, item.id);
      expect(entity.amount, item.amount);
      expect(entity.category, item.category);
      expect(entity.memo, item.memo);
      expect(entity.createdAt, item.createdAt);
    });

    test('fromExpenseEntity()는 올바른 CalendarExpenseItem을 생성한다', () {
      final entity = ExpenseEntity(
        id: 2,
        amount: 9000,
        category: ExpenseCategory.transport,
        memo: '버스',
        createdAt: DateTime(2026, 4, 17, 9, 0),
      );
      final converted = CalendarExpenseItem.fromExpenseEntity(entity);
      expect(converted.id, entity.id);
      expect(converted.amount, entity.amount);
      expect(converted.category, entity.category);
      expect(converted.memo, entity.memo);
      expect(converted.createdAt, entity.createdAt);
    });
  });
}
