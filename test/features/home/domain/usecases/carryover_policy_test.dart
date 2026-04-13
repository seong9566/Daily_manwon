import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:daily_manwon/features/home/domain/usecases/get_today_budget_use_case.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDailyBudgetRepository extends Mock implements DailyBudgetRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

/// 어제 날짜 (시분초=0)
DateTime get _yesterday {
  final now = DateTime.now();
  final d = now.subtract(const Duration(days: 1));
  return DateTime(d.year, d.month, d.day);
}

/// 오늘 날짜 (시분초=0)
DateTime get _today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// 테스트가 실행되는 날이 일요일이면 이월 계산이 0으로 리셋되므로,
/// 정확한 carryOver 금액을 검증하는 테스트는 일요일에 건너뛴다.
bool get _isSunday => DateTime.now().weekday == DateTime.sunday;

void main() {
  late MockDailyBudgetRepository mockBudgetRepo;
  late MockSettingsRepository mockSettingsRepo;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockBudgetRepo = MockDailyBudgetRepository();
    mockSettingsRepo = MockSettingsRepository();
  });

  // ── 헬퍼: _fillMissingDays를 no-op으로 만든다 (lastDate=null 반환)
  void skipGapFill() {
    when(() => mockBudgetRepo.getLastBudgetDate()).thenAnswer((_) async => null);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // T-CRY-1: DailyBudgetEntity.effectiveBudget 순수 계산 검증
  // ──────────────────────────────────────────────────────────────────────────

  group('T-CRY-1: DailyBudgetEntity.effectiveBudget 계산', () {
    test('양수 carryOver: effectiveBudget = baseAmount + carryOver', () {
      final entity = DailyBudgetEntity(
        id: 1,
        date: _today,
        baseAmount: 10000,
        carryOver: 3000,
      );
      expect(entity.effectiveBudget, equals(13000));
    });

    test('음수 carryOver(초과이월): effectiveBudget = baseAmount - 초과금액', () {
      final entity = DailyBudgetEntity(
        id: 1,
        date: _today,
        baseAmount: 10000,
        carryOver: -2000,
      );
      expect(entity.effectiveBudget, equals(8000));
    });

    test('carryOver=0: effectiveBudget = baseAmount', () {
      final entity = DailyBudgetEntity(
        id: 1,
        date: _today,
        baseAmount: 10000,
        carryOver: 0,
      );
      expect(entity.effectiveBudget, equals(10000));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-CRY-2: _computeTodayCarryOver — 이월 비활성화 시 0 전달
  // ──────────────────────────────────────────────────────────────────────────

  group('T-CRY-2: 이월 비활성화 시 carryOver=0 전달', () {
    test('이월 OFF이면 어제 잔액에 상관없이 carryOver=0이 repo에 전달된다', () async {
      // given
      skipGapFill();
      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => false);

      // 어제 예산이 풍족해도 이월이 OFF면 0이어야 한다
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer(
        (_) async => DailyBudgetEntity(
          id: 1,
          date: _yesterday,
          baseAmount: 10000,
          carryOver: 0,
        ),
      );
      when(() => mockBudgetRepo.getTotalExpensesByDate(any()))
          .thenAnswer((_) async => 3000); // 7,000원 남아도 이월 OFF면 무시

      final todayBudget = DailyBudgetEntity(id: 2, date: _today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(
            carryOver: any(named: 'carryOver'),
          )).thenAnswer((_) async => todayBudget);

      final useCase =
          GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then: carryOver=0이 정확히 전달됐는지 캡처로 검증
      final captured = verify(
        () => mockBudgetRepo.getOrCreateTodayBudget(
          carryOver: captureAny(named: 'carryOver'),
        ),
      ).captured;
      expect(captured.last, equals(0),
          reason: '이월 OFF이면 어제 잔액에 상관없이 0이어야 한다');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-CRY-3: _computeTodayCarryOver — 이월 ON + 절약 시 정확한 금액 전달
  // ──────────────────────────────────────────────────────────────────────────

  group('T-CRY-3: 이월 ON — 절약 잔액 이월', () {
    test('어제 10,000원 예산에서 3,000원 지출 → carryOver=+7,000이 전달된다',
        () async {
      if (_isSunday) {
        // 일요일은 강제 리셋 정책으로 carryOver=0 — 별도 케이스(T-CRY-6)에서 검증
        return;
      }

      // given
      skipGapFill();
      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => true);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer(
        (_) async => DailyBudgetEntity(
          id: 1,
          date: _yesterday,
          baseAmount: 10000,
          carryOver: 0, // effectiveBudget = 10,000
        ),
      );
      when(() => mockBudgetRepo.getTotalExpensesByDate(any()))
          .thenAnswer((_) async => 3000); // 잔액 = 10,000 - 3,000 = 7,000

      final todayBudget = DailyBudgetEntity(id: 2, date: _today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(
            carryOver: any(named: 'carryOver'),
          )).thenAnswer((_) async => todayBudget);

      final useCase =
          GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then
      final captured = verify(
        () => mockBudgetRepo.getOrCreateTodayBudget(
          carryOver: captureAny(named: 'carryOver'),
        ),
      ).captured;
      expect(captured.last, equals(7000),
          reason: '어제 10,000 - 3,000 = 7,000원이 이월되어야 한다');
    });

    test('어제 effectiveBudget(이월 포함 15,000)에서 8,000원 지출 → carryOver=+7,000',
        () async {
      if (_isSunday) return;

      // given: 어제도 이월이 있어서 effectiveBudget=15,000이었던 경우
      skipGapFill();
      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => true);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer(
        (_) async => DailyBudgetEntity(
          id: 1,
          date: _yesterday,
          baseAmount: 10000,
          carryOver: 5000, // effectiveBudget = 15,000
        ),
      );
      when(() => mockBudgetRepo.getTotalExpensesByDate(any()))
          .thenAnswer((_) async => 8000); // 잔액 = 15,000 - 8,000 = 7,000

      final todayBudget = DailyBudgetEntity(id: 2, date: _today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(
            carryOver: any(named: 'carryOver'),
          )).thenAnswer((_) async => todayBudget);

      final useCase =
          GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then: effectiveBudget 기준으로 이월 계산
      final captured = verify(
        () => mockBudgetRepo.getOrCreateTodayBudget(
          carryOver: captureAny(named: 'carryOver'),
        ),
      ).captured;
      expect(captured.last, equals(7000),
          reason: '이월은 effectiveBudget(15,000) - 지출(8,000) = 7,000이어야 한다');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-CRY-4: _computeTodayCarryOver — 이월 ON + 초과 지출
  // ──────────────────────────────────────────────────────────────────────────

  group('T-CRY-4: 이월 ON — 초과 지출 음수 이월', () {
    test('어제 10,000원 예산에서 12,000원 초과 지출 → carryOver=-2,000이 전달된다',
        () async {
      if (_isSunday) return;

      // given
      skipGapFill();
      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => true);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer(
        (_) async => DailyBudgetEntity(
          id: 1,
          date: _yesterday,
          baseAmount: 10000,
          carryOver: 0, // effectiveBudget = 10,000
        ),
      );
      when(() => mockBudgetRepo.getTotalExpensesByDate(any()))
          .thenAnswer((_) async => 12000); // 10,000 - 12,000 = -2,000

      final todayBudget = DailyBudgetEntity(id: 2, date: _today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(
            carryOver: any(named: 'carryOver'),
          )).thenAnswer((_) async => todayBudget);

      final useCase =
          GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then: 음수 이월 허용
      final captured = verify(
        () => mockBudgetRepo.getOrCreateTodayBudget(
          carryOver: captureAny(named: 'carryOver'),
        ),
      ).captured;
      expect(captured.last, equals(-2000),
          reason: '초과 지출(-2,000)도 음수 이월로 다음날에 적용되어야 한다');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-CRY-5: _computeTodayCarryOver — 어제 row 없음
  // ──────────────────────────────────────────────────────────────────────────

  group('T-CRY-5: 이월 ON — 어제 예산 row 없으면 carryOver=0', () {
    test('이월 ON이지만 어제 DailyBudget row가 없으면 carryOver=0이 전달된다',
        () async {
      // given: 어제 row 없음 (null 반환)
      skipGapFill();
      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => true);
      when(() => mockBudgetRepo.getBudgetByDate(any()))
          .thenAnswer((_) async => null);

      final todayBudget = DailyBudgetEntity(id: 2, date: _today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(
            carryOver: any(named: 'carryOver'),
          )).thenAnswer((_) async => todayBudget);

      final useCase =
          GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then
      final captured = verify(
        () => mockBudgetRepo.getOrCreateTodayBudget(
          carryOver: captureAny(named: 'carryOver'),
        ),
      ).captured;
      expect(captured.last, equals(0),
          reason: '어제 row가 없으면 이월 기준값이 없으므로 0이어야 한다');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-CRY-6: 월요일 리셋 — 문서화 테스트
  // NOTE: GetTodayBudgetUseCase가 DateTime.now()를 직접 사용하므로
  //       월요일 리셋을 단위 테스트로 강제하려면 시간 주입(clock 파라미터)이 필요하다.
  //       현재 구조에서는 월요일에 실행할 때만 동작이 확인 가능하다.
  //       향후 개선: GetTodayBudgetUseCase 생성자에 Clock 파라미터 추가 권장.
  // ──────────────────────────────────────────────────────────────────────────

  group('T-CRY-6: 일요일 강제 리셋 (실행일이 일요일일 때만 검증)', () {
    test('오늘이 일요일이면 이월 ON이어도 carryOver=0이 전달된다', () async {
      if (!_isSunday) {
        // 일요일이 아닌 날은 이 케이스를 검증할 수 없으므로 스킵
        // ignore: avoid_print
        print('[SKIP] 일요일에만 실행 가능한 테스트 — 오늘은 일요일이 아님');
        return;
      }

      // given: 이월 ON, 어제(토요일) 잔액 충분
      skipGapFill();
      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => true);
      when(() => mockBudgetRepo.getBudgetByDate(any())).thenAnswer(
        (_) async => DailyBudgetEntity(
          id: 1,
          date: _yesterday,
          baseAmount: 10000,
          carryOver: 5000,
        ),
      );
      when(() => mockBudgetRepo.getTotalExpensesByDate(any()))
          .thenAnswer((_) async => 3000); // 잔액 12,000이 있어도 일요일이면 0

      final todayBudget = DailyBudgetEntity(id: 2, date: _today);
      when(() => mockBudgetRepo.getOrCreateTodayBudget(
            carryOver: any(named: 'carryOver'),
          )).thenAnswer((_) async => todayBudget);

      final useCase =
          GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then: 일요일(주 시작) → 강제 리셋
      final captured = verify(
        () => mockBudgetRepo.getOrCreateTodayBudget(
          carryOver: captureAny(named: 'carryOver'),
        ),
      ).captured;
      expect(captured.last, equals(0),
          reason: '일요일은 새 주의 시작이므로 이전 주 이월이 소멸되어 항상 0이어야 한다');
    });
  });
}
