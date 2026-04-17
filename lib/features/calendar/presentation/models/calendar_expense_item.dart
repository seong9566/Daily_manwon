import '../../../../core/constants/app_constants.dart';
import '../../../expense/domain/entities/expense.dart';

/// 캘린더 화면 전용 지출 표현 모델.
///
/// CalendarState가 Domain Entity(ExpenseEntity)를 직접 포함하지 않도록
/// Presentation 레이어에서 필요한 필드만 보유한다.
/// bottom sheet 호출 시에는 toExpenseEntity()로 변환한다.
class CalendarExpenseItem {
  const CalendarExpenseItem({
    required this.id,
    required this.amount,
    required this.category,
    required this.memo,
    required this.createdAt,
  });

  final int id;
  final int amount;
  final ExpenseCategory category;
  final String memo;
  final DateTime createdAt;

  factory CalendarExpenseItem.fromExpenseEntity(ExpenseEntity entity) {
    return CalendarExpenseItem(
      id: entity.id,
      amount: entity.amount,
      category: entity.category,
      memo: entity.memo,
      createdAt: entity.createdAt,
    );
  }

  ExpenseEntity toExpenseEntity() => ExpenseEntity(
        id: id,
        amount: amount,
        category: category,
        memo: memo,
        createdAt: createdAt,
      );
}
