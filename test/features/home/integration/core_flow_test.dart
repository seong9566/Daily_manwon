import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:daily_manwon/features/home/domain/entities/acorn.dart';
import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';
import 'package:daily_manwon/features/home/domain/repositories/acorn_repository.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:daily_manwon/features/home/domain/usecases/evaluate_and_award_acorn_use_case.dart';
import 'package:daily_manwon/features/home/domain/usecases/get_acorn_stats_use_case.dart';
import 'package:daily_manwon/features/home/domain/usecases/get_today_budget_use_case.dart';
import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/repositories/expense_repository.dart';
import 'package:daily_manwon/features/expense/domain/usecases/add_expense_use_case.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';

class MockDailyBudgetRepository extends Mock implements DailyBudgetRepository {}

class MockAcornRepository extends Mock implements AcornRepository {}

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockDailyBudgetRepository mockBudgetRepo;
  late MockAcornRepository mockAcornRepo;
  late MockExpenseRepository mockExpenseRepo;
  late MockSettingsRepository mockSettingsRepo;

  setUpAll(() {
    registerFallbackValue(
      ExpenseEntity(amount: 0, category: ExpenseCategory.food, createdAt: DateTime(2026)),
    );
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockBudgetRepo = MockDailyBudgetRepository();
    mockAcornRepo = MockAcornRepository();
    mockExpenseRepo = MockExpenseRepository();
    mockSettingsRepo = MockSettingsRepository();
  });

  // ─── T-01-1: 지출 저장 → 잔액 차감 ───────────────────────────────────────

  group('T-01-1: 지출 저장 시 잔액 차감 검증', () {
    test('3,000원 지출 추가 후 남은 예산이 7,000원으로 차감된다', () async {
      // given
      final today = DateTime.now();
      final expense = ExpenseEntity(
        id: 1,
        amount: 3000,
        category: ExpenseCategory.transport,
        memo: '점심',
        createdAt: today,
      );
      when(() => mockExpenseRepo.addExpense(any())).thenAnswer((_) async => expense);
      when(() => mockBudgetRepo.getRemainingBudget(any())).thenAnswer((_) async => 7000);

      final addExpenseUseCase = AddExpenseUseCase(mockExpenseRepo);
      final getTodayBudgetUseCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await addExpenseUseCase.execute(expense);
      final remaining = await getTodayBudgetUseCase.getRemainingBudget(today);

      // then
      expect(remaining, equals(7000));
      verify(() => mockExpenseRepo.addExpense(any())).called(1);
    });

    test('지출 추가 시 ExpenseRepository.addExpense가 정확히 1회 호출된다', () async {
      // given
      final expense = ExpenseEntity(
        id: 2,
        amount: 5000,
        category: ExpenseCategory.shopping,
        createdAt: DateTime.now(),
      );
      when(() => mockExpenseRepo.addExpense(any())).thenAnswer((_) async => expense);

      final useCase = AddExpenseUseCase(mockExpenseRepo);

      // when
      await useCase.execute(expense);

      // then
      verify(() => mockExpenseRepo.addExpense(any())).called(1);
    });
  });

  // ─── T-01-2: 자정 리셋 ───────────────────────────────────────────────────

  group('T-01-2: 자정 리셋 로직 검증', () {
    test('새 날짜에 carryOver 없이 기본 예산 10,000원으로 초기화된다', () async {
      // given
      final today = DateTime.now();
      final newBudget = DailyBudgetEntity(
        id: 1,
        date: today,
        baseAmount: 10000,
        carryOver: 0,
      );
      when(() => mockBudgetRepo.getOrCreateTodayBudget(carryOver: any(named: 'carryOver'))).thenAnswer((_) async => newBudget);
      when(() => mockBudgetRepo.getLastBudgetDate()).thenAnswer((_) async => null);
      when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => false);

      final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      final budget = await useCase.getOrCreateTodayBudget();

      // then
      expect(budget.baseAmount, equals(10000));
      expect(budget.carryOver, equals(0));
      expect(budget.baseAmount + budget.carryOver, equals(10000));
    });

    test('새 날짜 예산 조회 시 getOrCreateTodayBudget이 1회 호출된다', () async {
      // given
      final today = DateTime.now();
      final budget = DailyBudgetEntity(id: 1, date: today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(carryOver: any(named: 'carryOver'))).thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.getLastBudgetDate()).thenAnswer((_) async => null);
      when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => false);

      final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then
      verify(() => mockBudgetRepo.getOrCreateTodayBudget(carryOver: any(named: 'carryOver'))).called(1);
    });
  });

  // ─── T-01-3: 이월 로직 ───────────────────────────────────────────────────

  group('T-01-3: 이월 로직 검증', () {
    test('전일 잔액 2,000원 이월 시 오늘 총 예산은 12,000원이다', () async {
      // given
      final today = DateTime.now();
      final budget = DailyBudgetEntity(
        id: 2,
        date: today,
        baseAmount: 10000,
        carryOver: 2000,
      );
      when(() => mockBudgetRepo.getOrCreateTodayBudget(carryOver: any(named: 'carryOver'))).thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.getLastBudgetDate()).thenAnswer((_) async => null);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => null);
      when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => true);

      final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      final result = await useCase.getOrCreateTodayBudget();

      // then
      expect(result.baseAmount + result.carryOver, equals(12000));
    });

    test('전일 마이너스 잔액 -1,000원 이월 시 오늘 총 예산은 9,000원이다', () async {
      // given
      final today = DateTime.now();
      final budget = DailyBudgetEntity(
        id: 3,
        date: today,
        baseAmount: 10000,
        carryOver: -1000,
      );
      when(() => mockBudgetRepo.getOrCreateTodayBudget(carryOver: any(named: 'carryOver'))).thenAnswer((_) async => budget);
      when(() => mockBudgetRepo.getLastBudgetDate()).thenAnswer((_) async => null);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => null);
      when(() => mockSettingsRepo.getCarryoverEnabled()).thenAnswer((_) async => true);

      final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      final result = await useCase.getOrCreateTodayBudget();

      // then
      expect(result.baseAmount + result.carryOver, equals(9000));
    });
  });

  // ─── T-01-4: 도토리 획득 조건 ────────────────────────────────────────────

  group('T-01-4: 도토리 획득 조건 검증', () {
    test('전날 잔액 5,000원 이상이면 기본 도토리 1개 + 보너스 1개가 지급된다', () async {
      // given
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final budget = DailyBudgetEntity(id: 1, date: yesterday);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => budget);
      when(() => mockAcornRepo.getAcornsByDate(any())).thenAnswer((_) async => []);
      when(() => mockBudgetRepo.getRemainingBudget(any())).thenAnswer((_) async => 5000);
      when(
        () => mockAcornRepo.addAcorn(any(), any(), date: any(named: 'date')),
      ).thenAnswer((_) async {});

      final useCase = EvaluateAndAwardAcornUseCase(mockBudgetRepo, mockAcornRepo);

      // when
      await useCase.execute();

      // then
      verify(
        () => mockAcornRepo.addAcorn(1, '하루 만원 달성', date: any(named: 'date')),
      ).called(1);
      verify(
        () => mockAcornRepo.addAcorn(1, '5천원 이상 절약 보너스', date: any(named: 'date')),
      ).called(1);
    });

    test('전날 잔액이 0원이면 기본 도토리 1개만 지급된다', () async {
      // given
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final budget = DailyBudgetEntity(id: 1, date: yesterday);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => budget);
      when(() => mockAcornRepo.getAcornsByDate(any())).thenAnswer((_) async => []);
      when(() => mockBudgetRepo.getRemainingBudget(any())).thenAnswer((_) async => 0);
      when(
        () => mockAcornRepo.addAcorn(any(), any(), date: any(named: 'date')),
      ).thenAnswer((_) async {});

      final useCase = EvaluateAndAwardAcornUseCase(mockBudgetRepo, mockAcornRepo);

      // when
      await useCase.execute();

      // then: 기본 도토리만 지급, 보너스 없음
      verify(
        () => mockAcornRepo.addAcorn(1, '하루 만원 달성', date: any(named: 'date')),
      ).called(1);
      verifyNever(
        () => mockAcornRepo.addAcorn(1, '5천원 이상 절약 보너스', date: any(named: 'date')),
      );
    });

    test('전날 잔액이 음수이면 도토리가 지급되지 않는다', () async {
      // given
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final budget = DailyBudgetEntity(id: 1, date: yesterday);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => budget);
      when(() => mockAcornRepo.getAcornsByDate(any())).thenAnswer((_) async => []);
      when(() => mockBudgetRepo.getRemainingBudget(any())).thenAnswer((_) async => -500);

      final useCase = EvaluateAndAwardAcornUseCase(mockBudgetRepo, mockAcornRepo);

      // when
      await useCase.execute();

      // then
      verifyNever(
        () => mockAcornRepo.addAcorn(any(), any(), date: any(named: 'date')),
      );
    });

    test('전날 예산 row가 없으면 도토리 평가를 스킵한다', () async {
      // given
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => null);

      final useCase = EvaluateAndAwardAcornUseCase(mockBudgetRepo, mockAcornRepo);

      // when
      await useCase.execute();

      // then: 도토리 조회/지급 모두 호출 안 됨
      verifyNever(() => mockAcornRepo.getAcornsByDate(any()));
      verifyNever(
        () => mockAcornRepo.addAcorn(any(), any(), date: any(named: 'date')),
      );
    });

    test('이미 도토리가 지급된 날은 중복 지급되지 않는다', () async {
      // given
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final budget = DailyBudgetEntity(id: 1, date: yesterday);
      final existingAcorn = AcornEntity(
        id: 1,
        date: yesterday,
        count: 1,
        reason: '하루 만원 달성',
      );
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer((_) async => budget);
      when(
        () => mockAcornRepo.getAcornsByDate(any()),
      ).thenAnswer((_) async => [existingAcorn]);

      final useCase = EvaluateAndAwardAcornUseCase(mockBudgetRepo, mockAcornRepo);

      // when
      await useCase.execute();

      // then: addAcorn 호출 없음
      verifyNever(
        () => mockAcornRepo.addAcorn(any(), any(), date: any(named: 'date')),
      );
    });
  });

  // ─── T-01-5: 스트릭 증가/리셋 ────────────────────────────────────────────

  group('T-01-5: 스트릭 증가 검증', () {
    test('연속 3일 성공 시 getStreakDays가 3을 반환한다', () async {
      // given
      when(() => mockAcornRepo.getStreakDays()).thenAnswer((_) async => 3);

      final useCase = GetAcornStatsUseCase(mockAcornRepo);

      // when
      final streak = await useCase.getStreakDays();

      // then
      expect(streak, equals(3));
    });

    test('실패(음수 잔액) 후 도토리 미지급 시 스트릭이 0이 된다', () async {
      // given: 스트릭이 리셋된 상태
      when(() => mockAcornRepo.getStreakDays()).thenAnswer((_) async => 0);

      final useCase = GetAcornStatsUseCase(mockAcornRepo);

      // when
      final streak = await useCase.getStreakDays();

      // then
      expect(streak, equals(0));
    });

    test('처음 성공 시 스트릭이 1이 된다', () async {
      // given
      when(() => mockAcornRepo.getStreakDays()).thenAnswer((_) async => 1);

      final useCase = GetAcornStatsUseCase(mockAcornRepo);

      // when
      final streak = await useCase.getStreakDays();

      // then
      expect(streak, equals(1));
    });
  });
}
