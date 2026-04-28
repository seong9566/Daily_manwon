import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:daily_manwon/features/home/domain/usecases/get_today_budget_use_case.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDailyBudgetRepository extends Mock implements DailyBudgetRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// ───────────────────────────────────────────────────────
// 날짜 헬퍼 — 실제 오늘 기준으로 이번 주 날짜를 계산한다
// ───────────────────────────────────────────────────────

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime get _today => _dateOnly(DateTime.now());

/// 이번 주 일요일 (주 시작)
DateTime get _thisSunday {
  final day = _today;
  return day.subtract(Duration(days: day.weekday % 7));
}

/// 이번 주 월요일
DateTime get _thisMonday => _thisSunday.add(const Duration(days: 1));

/// 오늘이 화요일 이상인지 확인
bool get _isTuesdayOrLater => _today.weekday >= DateTime.tuesday;

/// 오늘이 일요일인지 확인
bool get _isSunday => _today.weekday == DateTime.sunday;

// ───────────────────────────────────────────────────────
// 공통 stub 헬퍼
// ───────────────────────────────────────────────────────

/// _fillMissingDays를 no-op으로 만든다 (lastDate=null)
void _skipGapFill(MockDailyBudgetRepository repo) {
  when(() => repo.getLastBudgetDate()).thenAnswer((_) async => null);
}

/// getOrCreateTodayBudget을 기본 stub으로 설정
void _stubGetOrCreateToday(MockDailyBudgetRepository repo) {
  when(
    () => repo.getOrCreateTodayBudget(carryOver: any(named: 'carryOver')),
  ).thenAnswer(
    (_) async => DailyBudgetEntity(id: 99, date: _today),
  );
}

/// updateCarryOverForDate를 성공 stub으로 설정
void _stubUpdateCarryOver(MockDailyBudgetRepository repo) {
  when(
    () => repo.updateCarryOverForDate(any(), any()),
  ).thenAnswer((_) async {});
}

/// getBudgetByDate를 날짜별 맵으로 stub한다.
/// _computeTodayCarryOver는 time-component가 포함된 날짜를 사용하므로
/// isSameDay 비교로 매칭한다.
void _stubBudgetByDateMap(
  MockDailyBudgetRepository repo,
  Map<DateTime, DailyBudgetEntity?> dateMap,
) {
  when(() => repo.getBudgetByDate(any())).thenAnswer((inv) async {
    final requested = inv.positionalArguments[0] as DateTime;
    final requestedDate = _dateOnly(requested);
    for (final entry in dateMap.entries) {
      final keyDate = _dateOnly(entry.key);
      if (keyDate == requestedDate) return entry.value;
    }
    return null;
  });
}

/// getTotalExpensesByDate를 날짜별 맵으로 stub한다.
void _stubExpensesByDateMap(
  MockDailyBudgetRepository repo,
  Map<DateTime, int> dateMap,
) {
  when(() => repo.getTotalExpensesByDate(any())).thenAnswer((inv) async {
    final requested = inv.positionalArguments[0] as DateTime;
    final requestedDate = _dateOnly(requested);
    for (final entry in dateMap.entries) {
      final keyDate = _dateOnly(entry.key);
      if (keyDate == requestedDate) return entry.value;
    }
    return 0;
  });
}

// ───────────────────────────────────────────────────────
// Main
// ───────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────────────────
  // T-SYNC-1: 핵심 버그 시나리오 — 소급 입력으로 stale carryOver 보정
  // 오늘=화요일, 일요일 지출 5,000 → 월요일 carryOver 20,000 → 15,000 보정
  // ──────────────────────────────────────────────────────────────────────────

  group('T-SYNC-1: 소급 입력 시 stale carryOver가 올바른 값으로 업데이트됨', () {
    test(
      '일요일 지출 5000, 월요일 carryOver=20000(stale) → 15000으로 업데이트',
      () async {
        if (!_isTuesdayOrLater) {
          // ignore: avoid_print
          print('[SKIP] T-SYNC-1: 오늘이 화요일 이상이어야 검증 가능');
          return;
        }

        // given
        _skipGapFill(mockBudgetRepo);
        _stubGetOrCreateToday(mockBudgetRepo);
        _stubUpdateCarryOver(mockBudgetRepo);

        when(() => mockSettingsRepo.getCarryoverEnabled())
            .thenAnswer((_) async => true);

        _stubBudgetByDateMap(mockBudgetRepo, {
          _thisSunday: DailyBudgetEntity(
            id: 1,
            date: _thisSunday,
            baseAmount: 20000,
            carryOver: 0,
          ),
          _thisMonday: DailyBudgetEntity(
            id: 2,
            date: _thisMonday,
            baseAmount: 20000,
            carryOver: 20000, // stale — 일요일 지출 없을 때 생성됨
          ),
        });

        _stubExpensesByDateMap(mockBudgetRepo, {
          _thisSunday: 5000, // 일요일 소급 지출
          _thisMonday: 0, // 어제(월요일) 지출
        });

        final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

        // when
        await useCase.getOrCreateTodayBudget();

        // then: 월요일 carryOver가 15,000으로 업데이트되어야 한다
        // prevEffective = baseAmount(20000) + runningCarryOver(0) = 20000
        // prevSpent = 5000
        // newCarryOver = 20000 - 5000 = 15000
        final allCaptured = verify(
          () => mockBudgetRepo.updateCarryOverForDate(
            captureAny(),
            captureAny(),
          ),
        ).captured;
        // captured는 [date0, value0, date1, value1, ...] 순서로 flat하게 저장됨
        expect(allCaptured.length, equals(2),
            reason: 'updateCarryOverForDate가 정확히 1회 호출되어야 한다 (인수 2개)');
        expect(
          _dateOnly(allCaptured[0] as DateTime),
          equals(_thisMonday),
          reason: '업데이트 대상은 월요일이어야 한다',
        );
        expect(allCaptured[1], equals(15000),
            reason: 'newCarryOver = 20000 - 5000 = 15000');
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-SYNC-2: 음수 carryOver 전파 (clamp 없음)
  // 일요일 지출 25,000 (예산 초과) → 월요일 carryOver = -5,000
  // ──────────────────────────────────────────────────────────────────────────

  group('T-SYNC-2: 초과 지출 시 음수 carryOver 전파 (clamp 없음)', () {
    test(
      '일요일 지출 25000 (예산 20000 초과) → 월요일 carryOver = -5000',
      () async {
        if (!_isTuesdayOrLater) {
          // ignore: avoid_print
          print('[SKIP] T-SYNC-2: 오늘이 화요일 이상이어야 검증 가능');
          return;
        }

        // given
        _skipGapFill(mockBudgetRepo);
        _stubGetOrCreateToday(mockBudgetRepo);
        _stubUpdateCarryOver(mockBudgetRepo);

        when(() => mockSettingsRepo.getCarryoverEnabled())
            .thenAnswer((_) async => true);

        _stubBudgetByDateMap(mockBudgetRepo, {
          _thisSunday: DailyBudgetEntity(
            id: 1,
            date: _thisSunday,
            baseAmount: 20000,
            carryOver: 0,
          ),
          _thisMonday: DailyBudgetEntity(
            id: 2,
            date: _thisMonday,
            baseAmount: 20000,
            carryOver: 20000, // stale
          ),
        });

        _stubExpensesByDateMap(mockBudgetRepo, {
          _thisSunday: 25000, // 초과 지출
          _thisMonday: 0,
        });

        final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

        // when
        await useCase.getOrCreateTodayBudget();

        // then: 월요일 carryOver = 20000 - 25000 = -5000 (음수 그대로)
        final allCaptured2 = verify(
          () => mockBudgetRepo.updateCarryOverForDate(
            captureAny(),
            captureAny(),
          ),
        ).captured;
        // captured는 [date0, value0, date1, value1, ...] 순서로 flat하게 저장됨
        expect(allCaptured2.length, equals(2),
            reason: 'updateCarryOverForDate가 정확히 1회 호출되어야 한다 (인수 2개)');
        expect(
          _dateOnly(allCaptured2[0] as DateTime),
          equals(_thisMonday),
          reason: '업데이트 대상은 월요일이어야 한다',
        );
        expect(allCaptured2[1], equals(-5000),
            reason: '음수 carryOver: 20000 - 25000 = -5000');
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-SYNC-3: carryoverEnabled=false 시 skip
  // ──────────────────────────────────────────────────────────────────────────

  group('T-SYNC-3: 이월 비활성화 시 updateCarryOverForDate 미호출', () {
    test('carryoverEnabled=false이면 sync를 실행하지 않는다', () async {
      // given
      _skipGapFill(mockBudgetRepo);
      _stubGetOrCreateToday(mockBudgetRepo);

      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => false);

      final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then: carryoverEnabled=false이므로 sync skip → updateCarryOverForDate 미호출
      verifyNever(() => mockBudgetRepo.updateCarryOverForDate(any(), any()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-SYNC-4: 오늘이 일요일이면 sync 자체를 skip
  // ──────────────────────────────────────────────────────────────────────────

  group('T-SYNC-4: 오늘이 일요일이면 sync skip', () {
    test('오늘이 일요일이면 updateCarryOverForDate가 호출되지 않는다', () async {
      if (!_isSunday) {
        // ignore: avoid_print
        print('[SKIP] T-SYNC-4: 오늘이 일요일이어야 직접 검증 가능');
        return;
      }

      // given: 오늘이 일요일인 경우에만 아래 검증 수행
      _skipGapFill(mockBudgetRepo);
      _stubGetOrCreateToday(mockBudgetRepo);

      when(() => mockSettingsRepo.getCarryoverEnabled())
          .thenAnswer((_) async => true);

      when(() => mockBudgetRepo.getBudgetByDate(any()))
          .thenAnswer((_) async => null);

      final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

      // when
      await useCase.getOrCreateTodayBudget();

      // then: 일요일이면 sync 없음
      verifyNever(() => mockBudgetRepo.updateCarryOverForDate(any(), any()));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // T-SYNC-5: 이미 정확한 값이면 update 미호출
  // ──────────────────────────────────────────────────────────────────────────

  group('T-SYNC-5: carryOver가 이미 정확한 값이면 updateCarryOverForDate 미호출', () {
    test(
      '월요일 carryOver가 이미 15000(정확) → update 미호출',
      () async {
        if (!_isTuesdayOrLater) {
          // ignore: avoid_print
          print('[SKIP] T-SYNC-5: 오늘이 화요일 이상이어야 검증 가능');
          return;
        }

        // given
        _skipGapFill(mockBudgetRepo);
        _stubGetOrCreateToday(mockBudgetRepo);

        when(() => mockSettingsRepo.getCarryoverEnabled())
            .thenAnswer((_) async => true);

        _stubBudgetByDateMap(mockBudgetRepo, {
          _thisSunday: DailyBudgetEntity(
            id: 1,
            date: _thisSunday,
            baseAmount: 20000,
            carryOver: 0,
          ),
          _thisMonday: DailyBudgetEntity(
            id: 2,
            date: _thisMonday,
            baseAmount: 20000,
            carryOver: 15000, // 이미 정확한 값
          ),
        });

        _stubExpensesByDateMap(mockBudgetRepo, {
          _thisSunday: 5000, // 20000 - 5000 = 15000 → 이미 일치
          _thisMonday: 0,
        });

        final useCase = GetTodayBudgetUseCase(mockBudgetRepo, mockSettingsRepo);

        // when
        await useCase.getOrCreateTodayBudget();

        // then: 이미 정확한 값이므로 update 미호출
        verifyNever(() => mockBudgetRepo.updateCarryOverForDate(any(), any()));
      },
    );
  });
}
