import 'package:daily_manwon/features/expense/domain/entities/expense.dart';

/// 지출 데이터 접근을 위한 레포지토리 인터페이스
/// Data 레이어의 구현체가 이 인터페이스를 구현한다
abstract interface class ExpenseRepository {
  /// 특정 날짜의 지출 목록을 한 번 조회한다
  Future<List<ExpenseEntity>> getExpensesByDate(DateTime date);

  /// 새 지출을 저장하고 저장된 엔티티를 반환한다
  Future<ExpenseEntity> addExpense(ExpenseEntity expense);

  /// 기존 지출을 수정한다
  Future<void> updateExpense(ExpenseEntity expense);

  /// 지출을 삭제한다
  Future<void> deleteExpense(int id);

  /// 특정 날짜의 지출 목록을 실시간으로 구독한다 (DB 변경 시 자동 방출)
  Stream<List<ExpenseEntity>> watchExpensesByDate(DateTime date);
}
