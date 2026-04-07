import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:daily_manwon/features/calendar/domain/usecases/get_monthly_calendar_data_use_case.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_expense_use_case.dart';
import 'package:daily_manwon/features/home/domain/usecases/delete_expense_use_case.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late MockExpenseRepository mockExpenseRepo;
  late MockCalendarRepository mockCalendarRepo;

  setUpAll(() {
    registerFallbackValue(
      ExpenseEntity(id: 0, amount: 0, category: 0, createdAt: DateTime(2026)),
    );
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockExpenseRepo = MockExpenseRepository();
    mockCalendarRepo = MockCalendarRepository();
  });

  // ─── T-02-1: 지출 추가 후 캘린더 날짜 상태 ───────────────────────────────

  group('T-02-1: 지출 추가 후 캘린더 날짜 상태 반영', () {
    test('지출 추가 후 해당 날짜의 캘린더 월별 데이터에 지출이 포함된다', () async {
      // given
      final today = DateTime(2026, 4, 7);
      final expense = ExpenseEntity(
        id: 1,
        amount: 5000,
        category: 1,
        memo: '점심',
        createdAt: today,
      );
      when(() => mockExpenseRepo.addExpense(any())).thenAnswer((_) async => expense);
      when(
        () => mockCalendarRepo.getMonthlyExpenses(year: 2026, month: 4),
      ).thenAnswer((_) async => {today: [expense]});

      final addExpenseUseCase = AddExpenseUseCase(mockExpenseRepo);
      final calendarUseCase = GetMonthlyCalendarDataUseCase(mockCalendarRepo);

      // when: 지출 추가 후 캘린더 조회
      await addExpenseUseCase.execute(expense);
      final monthlyData = await calendarUseCase.getMonthlyExpenses(year: 2026, month: 4);

      // then: 해당 날짜에 지출 존재
      expect(monthlyData.containsKey(today), isTrue);
      expect(monthlyData[today], isNotEmpty);
      expect(monthlyData[today]!.first.amount, equals(5000));
    });

    test('지출 추가 후 해당 날짜의 직접 조회에서도 지출이 반환된다', () async {
      // given
      final today = DateTime(2026, 4, 7);
      final expense = ExpenseEntity(
        id: 1,
        amount: 3000,
        category: 2,
        memo: '카페',
        createdAt: today,
      );
      when(() => mockExpenseRepo.addExpense(any())).thenAnswer((_) async => expense);
      when(
        () => mockCalendarRepo.getExpensesByDate(any()),
      ).thenAnswer((_) async => [expense]);

      final addExpenseUseCase = AddExpenseUseCase(mockExpenseRepo);

      // when
      await addExpenseUseCase.execute(expense);
      // CalendarRepository를 통한 날짜별 직접 조회
      final expenses = await mockCalendarRepo.getExpensesByDate(today);

      // then
      expect(expenses, isNotEmpty);
      expect(expenses.first.id, equals(1));
      expect(expenses.first.amount, equals(3000));
    });

    test('지출이 없는 날짜는 캘린더 월별 데이터에 포함되지 않는다', () async {
      // given
      final emptyDay = DateTime(2026, 4, 10);
      when(
        () => mockCalendarRepo.getMonthlyExpenses(year: 2026, month: 4),
      ).thenAnswer((_) async => {});

      final calendarUseCase = GetMonthlyCalendarDataUseCase(mockCalendarRepo);

      // when
      final monthlyData = await calendarUseCase.getMonthlyExpenses(year: 2026, month: 4);

      // then: 해당 날짜에 지출 없음
      expect(monthlyData.containsKey(emptyDay), isFalse);
    });

    test('여러 날짜에 지출이 있으면 각 날짜의 지출이 분리되어 반환된다', () async {
      // given
      final day1 = DateTime(2026, 4, 7);
      final day2 = DateTime(2026, 4, 8);
      final expense1 = ExpenseEntity(id: 1, amount: 3000, category: 1, createdAt: day1);
      final expense2 = ExpenseEntity(id: 2, amount: 7000, category: 2, createdAt: day2);
      when(
        () => mockCalendarRepo.getMonthlyExpenses(year: 2026, month: 4),
      ).thenAnswer((_) async => {
            day1: [expense1],
            day2: [expense2],
          });

      final calendarUseCase = GetMonthlyCalendarDataUseCase(mockCalendarRepo);

      // when
      final monthlyData = await calendarUseCase.getMonthlyExpenses(year: 2026, month: 4);

      // then: 두 날짜 모두 독립적으로 존재
      expect(monthlyData.length, equals(2));
      expect(monthlyData[day1]!.first.amount, equals(3000));
      expect(monthlyData[day2]!.first.amount, equals(7000));
    });
  });

  // ─── T-02-2: 지출 삭제 후 캘린더 상태 업데이트 ──────────────────────────

  group('T-02-2: 지출 삭제 후 캘린더 상태 업데이트', () {
    test('지출 삭제 후 캘린더 월별 데이터에서 해당 날짜 지출이 사라진다', () async {
      // given
      final today = DateTime(2026, 4, 7);
      when(() => mockExpenseRepo.deleteExpense(any())).thenAnswer((_) async {});
      // 삭제 후 캘린더 조회 시 빈 맵 반환
      when(
        () => mockCalendarRepo.getMonthlyExpenses(year: 2026, month: 4),
      ).thenAnswer((_) async => {});

      final deleteExpenseUseCase = DeleteExpenseUseCase(mockExpenseRepo);
      final calendarUseCase = GetMonthlyCalendarDataUseCase(mockCalendarRepo);

      // when
      await deleteExpenseUseCase.execute(1);
      final monthlyData = await calendarUseCase.getMonthlyExpenses(year: 2026, month: 4);

      // then: 해당 날짜에 지출 없음
      expect(monthlyData[today], isNull);
    });

    test('지출 삭제 시 ExpenseRepository.deleteExpense가 올바른 ID로 1회 호출된다', () async {
      // given
      const expenseId = 42;
      when(() => mockExpenseRepo.deleteExpense(expenseId)).thenAnswer((_) async {});

      final deleteExpenseUseCase = DeleteExpenseUseCase(mockExpenseRepo);

      // when
      await deleteExpenseUseCase.execute(expenseId);

      // then
      verify(() => mockExpenseRepo.deleteExpense(expenseId)).called(1);
    });

    test('여러 지출 중 하나 삭제 후 나머지 지출은 캘린더에 남아있다', () async {
      // given
      final today = DateTime(2026, 4, 7);
      final remainingExpense = ExpenseEntity(
        id: 2,
        amount: 4000,
        category: 1,
        createdAt: today,
      );
      when(() => mockExpenseRepo.deleteExpense(1)).thenAnswer((_) async {});
      // 삭제 후 캘린더엔 나머지 지출만 남아 있음
      when(
        () => mockCalendarRepo.getMonthlyExpenses(year: 2026, month: 4),
      ).thenAnswer((_) async => {today: [remainingExpense]});

      final deleteExpenseUseCase = DeleteExpenseUseCase(mockExpenseRepo);
      final calendarUseCase = GetMonthlyCalendarDataUseCase(mockCalendarRepo);

      // when: ID=1 지출 삭제
      await deleteExpenseUseCase.execute(1);
      final monthlyData = await calendarUseCase.getMonthlyExpenses(year: 2026, month: 4);

      // then: 삭제된 지출(id=1)은 없고 나머지(id=2)만 존재
      expect(monthlyData[today], isNotNull);
      expect(monthlyData[today]!.length, equals(1));
      expect(monthlyData[today]!.first.id, equals(2));
    });
  });
}
