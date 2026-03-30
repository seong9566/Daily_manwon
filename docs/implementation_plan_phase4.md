# Phase 4: 핵심 비즈니스 로직 상세 구현 계획

> **작성일**: 2026-03-30
> **대상 스토리**: S-15, S-17, S-18, S-20a, S-25g, S-28g
> **목표**: 자정 리셋, 이월, 도토리 수집, 스트릭 시스템의 실제 비즈니스 로직 완성

---

## 구현 순서 (의존성 기준)

```
S-15 (자정 리셋) ─┐
                   ├─→ S-17 (이월 로직) ─→ S-18 (이월 UI)
S-25g (스트릭)  ───┤
                   ├─→ S-20a (도토리 수집)
                   └─→ S-28g (실데이터 연결)
```

**순서**: S-15 → S-25g → S-17 → S-20a → S-18 → S-28g

---

## S-15: 자정 리셋 로직

### 개요
앱이 자정을 넘겨 사용될 때 "오늘"이 바뀐 것을 감지하고, 새 날짜의 예산을 자동 생성하며, 홈 화면 데이터를 갱신한다.

### 수정/생성 파일

| 파일 | 작업 |
|------|------|
| `lib/core/utils/app_date_utils.dart` | `dayDifference()` public화, `yesterday` getter 추가 |
| `lib/core/services/day_change_service.dart` | **신규** — 날짜 변경 감지 서비스 |
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | `DayChangeService` 구독, 날짜 변경 시 refresh 호출 |
| `lib/main.dart` | `DayChangeService` DI 등록 확인 |

### 핵심 로직 설계

#### DayChangeService (신규)

```dart
/// lib/core/services/day_change_service.dart
@lazySingleton
class DayChangeService {
  DateTime _currentDate;
  final _controller = StreamController<DateTime>.broadcast();

  DayChangeService() : _currentDate = AppDateUtils.todayStart {
    _startMidnightTimer();
  }

  /// 날짜 변경 이벤트 스트림
  Stream<DateTime> get onDayChanged => _controller.stream;

  /// 앱이 포그라운드로 복귀 시 호출 — WidgetsBindingObserver에서 사용
  void checkDayChange() {
    final today = AppDateUtils.todayStart;
    if (!AppDateUtils.isSameDay(today, _currentDate)) {
      _currentDate = today;
      _controller.add(today);
    }
  }

  /// 자정까지 남은 시간을 계산하여 Timer 설정
  void _startMidnightTimer() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);

    Timer(duration, () {
      checkDayChange();
      _startMidnightTimer(); // 다음 자정 타이머 재설정
    });
  }
}
```

#### HomeViewModel 변경

```dart
// build() 내에 추가
void _watchDayChange() {
  final dayChangeService = getIt<DayChangeService>();
  dayChangeService.onDayChanged.listen((_) => refresh());
}
```

#### AppDateUtils 확장

```dart
/// 어제 날짜의 시작 시각 (00:00:00.000)
static DateTime get yesterdayStart =>
    startOfDay(DateTime.now().subtract(const Duration(days: 1)));
```

### 엣지 케이스

- 앱이 백그라운드에서 며칠간 방치 후 포그라운드 진입 → `checkDayChange()` 정상 동작 확인
- 자정 직전/직후 빠른 전환 시 이중 refresh 방지 (isSameDay 체크로 보장)
- 타임존 변경 시에도 로컬 DateTime 기반이므로 일관성 유지
- Timer 정밀도 — `Duration` 차이가 음수가 되지 않도록 방어 코드

### 테스트 포인트

- [ ] `DayChangeService`: 날짜가 바뀌면 스트림에 이벤트 발행되는지
- [ ] `DayChangeService`: 같은 날 여러 번 `checkDayChange()` 호출 시 이벤트 중복 미발생
- [ ] `HomeViewModel`: `onDayChanged` 이벤트 수신 시 `refresh()` 호출 확인
- [ ] `AppDateUtils.yesterdayStart`: 자정 경계에서 정확한 값 반환

---

## S-17: 남은 돈 이월 로직

### 개요
전날 만원 이내로 사용한 경우, 남은 금액을 오늘 예산에 `carryOver`로 추가한다. 마이너스 한도는 -5,000원 (초과 지출 페널티 제한).

### 수정/생성 파일

| 파일 | 작업 |
|------|------|
| `lib/core/constants/app_constants.dart` | `maxCarryOverDebt` 상수 추가 (-5000) |
| `lib/core/services/carryover_service.dart` | **신규** — 이월 계산 + 적용 서비스 |
| `lib/features/home/domain/repositories/daily_budget_repository.dart` | `updateCarryOver()` 메서드 추가 |
| `lib/features/home/data/repositories/daily_budget_repository_impl.dart` | `updateCarryOver()` 구현 |
| `lib/features/home/data/datasources/daily_budget_local_datasource.dart` | `updateCarryOver()` DB 업데이트 메서드 |
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | 날짜 변경 시 이월 로직 트리거 |

### 핵심 로직 설계

#### AppConstants 추가

```dart
/// 이월 마이너스 한도 (원) — 전날 초과 지출 시 최대 페널티
static const int maxCarryOverDebt = -5000;
```

#### CarryOverService (신규)

```dart
/// lib/core/services/carryover_service.dart
@lazySingleton
class CarryOverService {
  final DailyBudgetRepository _budgetRepo;
  final ExpenseRepository _expenseRepo;

  CarryOverService(this._budgetRepo, this._expenseRepo);

  /// 어제의 남은 금액을 계산하여 오늘 예산에 이월 적용
  /// 반환값: 적용된 carryOver 금액
  Future<int> applyCarryOver() async {
    final yesterday = AppDateUtils.yesterdayStart;
    final yesterdayBudget = await _budgetRepo.getBudgetByDate(yesterday);

    // 어제 예산이 없으면 이월 없음 (앱 미사용일)
    if (yesterdayBudget == null) return 0;

    // 어제 남은 금액 계산
    final yesterdayRemaining = await _budgetRepo.getRemainingBudget(yesterday);

    // 이월 금액 결정: 마이너스일 경우 -5000원 한도 적용
    final carryOver = yesterdayRemaining.clamp(
      AppConstants.maxCarryOverDebt,  // -5000
      yesterdayBudget.baseAmount,     // 최대 10000 (하루 예산 전액)
    );

    // 오늘 예산에 이월 적용
    if (carryOver != 0) {
      final todayBudget = await _budgetRepo.getOrCreateTodayBudget();
      // 이미 이월이 적용된 경우 중복 방지
      if (todayBudget.carryOver == 0) {
        await _budgetRepo.updateCarryOver(todayBudget.id, carryOver);
      }
    }

    return carryOver;
  }
}
```

#### DailyBudgetRepository 인터페이스 추가

```dart
/// 특정 예산의 이월 금액을 업데이트한다
Future<void> updateCarryOver(int budgetId, int carryOver);
```

#### DailyBudgetLocalDatasource 추가

```dart
/// 이월 금액 업데이트
Future<void> updateCarryOver(int budgetId, int carryOver) async {
  await (_db.update(_db.dailyBudgets)
        ..where((t) => t.id.equals(budgetId)))
      .write(DailyBudgetsCompanion(carryOver: Value(carryOver)));
}
```

### 엣지 케이스

- 어제 예산 레코드가 없는 경우 (앱 첫 사용 또는 어제 미사용) → carryOver = 0
- 어제 초과 지출(-3000원 남음) → carryOver = -3000 (한도 내)
- 어제 대폭 초과 지출(-8000원 남음) → carryOver = -5000 (한도 적용)
- 어제 전혀 안 씀(10000원 남음) → carryOver = 10000
- 앱을 2일 이상 안 열었다가 복귀 → 직전 사용일 기준이 아닌 **어제 기준**만 이월 (중간 날짜 누적 없음)
- 이월 중복 방지: `todayBudget.carryOver == 0` 체크로 1회만 적용

### 테스트 포인트

- [ ] 어제 5000원 사용 → carryOver = 5000 정상 적용
- [ ] 어제 15000원 사용 → carryOver = -5000 (한도 클램핑)
- [ ] 어제 예산 없음 → carryOver = 0
- [ ] 이미 이월 적용된 상태에서 재호출 시 중복 미적용
- [ ] `getRemainingBudget()`: carryOver 반영 후 잔액 = baseAmount + carryOver - 지출합계

---

## S-18: 이월 내역 표시 UI

### 개요
홈 화면 히어로 금액 아래에 이월 금액을 `+ 어제 이월 ₩X,XXX` 형식으로 표시한다. 마이너스 이월은 `- 초과분 ₩X,XXX` 형식.

### 수정/생성 파일

| 파일 | 작업 |
|------|------|
| `lib/features/home/presentation/widgets/home_budget_header.dart` | 이월 표시 로직 개선 (마이너스 이월 대응) |

### 핵심 로직 설계

#### HomeBudgetHeader 수정

현재 코드 (`home_budget_header.dart:51-58`):
```dart
if (carryOver > 0)
  Text('+ 어제 이월 ₩${NumberFormat('#,###').format(carryOver)}', ...)
```

변경 후:
```dart
if (carryOver != 0)
  Text(
    carryOver > 0
        ? '+ 어제 이월 ₩${NumberFormat('#,###').format(carryOver)}'
        : '- 초과분 ₩${NumberFormat('#,###').format(carryOver.abs())}',
    style: AppTypography.bodySmall.copyWith(
      color: carryOver > 0 ? AppColors.budgetComfortable : AppColors.budgetDanger,
    ),
  ).animate()
   .fadeIn(duration: 300.ms, delay: 200.ms)
   .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut),
```

### 엣지 케이스

- carryOver = 0 → 이월 라벨 미표시 (현재 동작 유지)
- carryOver > 0 → 녹색 `+ 어제 이월` 표시
- carryOver < 0 → 빨간색 `- 초과분` 표시
- 다크모드에서 색상 대비 확인 (budgetComfortable/budgetDanger는 양 테마 공통 색상)

### 테스트 포인트

- [ ] carryOver > 0 시 녹색 이월 텍스트 렌더링
- [ ] carryOver < 0 시 빨간색 초과분 텍스트 렌더링
- [ ] carryOver = 0 시 텍스트 미렌더링
- [ ] 금액 포맷팅: 1000 단위 콤마 정상 표시

---

## S-25g: 스트릭 시스템

### 개요
현재 `AcornLocalDatasource.getStreakDays()`와 `CalendarLocalDatasource.getStreakDays()`에 스트릭 계산 로직이 중복되어 있다. 이를 도메인 서비스로 통합하고, 스트릭 끊김/갱신 처리를 추가한다.

### 수정/생성 파일

| 파일 | 작업 |
|------|------|
| `lib/core/services/streak_service.dart` | **신규** — 스트릭 계산 통합 서비스 |
| `lib/features/home/data/datasources/acorn_local_datasource.dart` | `getStreakDays()` → `StreakService` 위임 |
| `lib/features/calendar/data/datasources/calendar_local_datasource.dart` | `getStreakDays()` → `StreakService` 위임 |
| `lib/features/home/domain/repositories/acorn_repository.dart` | `getStreakDays()` 반환 타입 유지 (int) |

### 핵심 로직 설계

#### StreakService (신규)

```dart
/// lib/core/services/streak_service.dart
@lazySingleton
class StreakService {
  final AppDatabase _db;

  StreakService(this._db);

  /// 오늘부터 과거로 역추적하여 연속 성공 일수를 계산한다
  ///
  /// 성공 기준:
  /// - 해당 날짜에 지출 기록이 있어야 함 (기록 없는 날 = 미참여, 연속 끊김)
  /// - 해당 날짜의 총 지출 ≤ dailyBudget(10,000원)
  ///
  /// 오늘은 아직 진행 중이므로 스트릭 계산에서 제외하고,
  /// 어제부터 역추적한다. 단, 오늘 지출 기록이 있고 예산 이내이면
  /// "+1"로 오늘도 포함 가능 (옵션).
  Future<int> calculateStreak({bool includeToday = true}) async {
    final allExpenses = await _db.expenses.all().get();
    if (allExpenses.isEmpty) return 0;

    // 날짜별 지출 합계 맵 구성
    final Map<String, int> dailyTotals = {};
    for (final expense in allExpenses) {
      final key = _dateKey(expense.createdAt);
      dailyTotals[key] = (dailyTotals[key] ?? 0) + expense.amount;
    }

    int streak = 0;
    final now = DateTime.now();
    DateTime cursor = DateTime(now.year, now.month, now.day);

    while (true) {
      final key = _dateKey(cursor);
      final total = dailyTotals[key];

      if (total == null) break;                          // 기록 없음 → 끊김
      if (total > AppConstants.dailyBudget) break;       // 초과 → 끊김

      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 어제의 성공 여부 판정 (이월/도토리 트리거용)
  Future<bool> wasYesterdaySuccessful() async {
    final yesterday = AppDateUtils.yesterdayStart;
    final key = _dateKey(yesterday);

    final expenses = await (_db.select(_db.expenses)
          ..where((e) {
            final start = yesterday;
            final end = yesterday.add(const Duration(days: 1));
            return e.createdAt.isBiggerOrEqualValue(start) &
                e.createdAt.isSmallerThanValue(end);
          }))
        .get();

    if (expenses.isEmpty) return false;
    final total = expenses.fold<int>(0, (sum, e) => sum + e.amount);
    return total <= AppConstants.dailyBudget;
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
```

#### AcornLocalDatasource 변경

```dart
// 기존 getStreakDays() 내부 로직 제거, StreakService 위임
final StreakService _streakService;

AcornLocalDatasource(this._db, this._streakService);

Future<int> getStreakDays() => _streakService.calculateStreak();
```

### 엣지 케이스

- 앱 첫 사용 (지출 0건) → streak = 0
- 오늘만 지출 있음 (예산 이내) → streak = 1
- 어제 초과, 오늘 이내 → streak = 1 (어제에서 끊김)
- 3일 연속 성공 후 하루 미사용 → streak = 0 (빈 날에서 끊김)
- 연속 30일 성공 → streak = 30 (상한 없음)

### 테스트 포인트

- [ ] 연속 3일 성공 데이터 → streak = 3
- [ ] 중간에 초과일 포함 → 해당 날짜에서 끊김
- [ ] 중간에 빈 날 포함 → 해당 날짜에서 끊김
- [ ] `wasYesterdaySuccessful()`: 어제 예산 이내 → true
- [ ] `wasYesterdaySuccessful()`: 어제 기록 없음 → false
- [ ] 중복 로직 제거 후 AcornLocalDatasource / CalendarLocalDatasource 동일 결과

---

## S-20a: 도토리 수집 로직

### 개요
하루 마감 시 (날짜 변경 감지) 어제의 지출 결과를 판정하여 도토리를 자동 지급한다.

**지급 규칙**:
- 만원 이내 성공 → 도토리 1개 (`하루 만원 달성`)
- 5,000원 이하 사용 → 보너스 도토리 1개 추가 (`절약 보너스`)

### 수정/생성 파일

| 파일 | 작업 |
|------|------|
| `lib/core/services/daily_settlement_service.dart` | **신규** — 일일 정산 서비스 (이월 + 도토리 통합) |
| `lib/core/constants/app_constants.dart` | 보너스 임계값 상수 추가 |
| `lib/features/home/domain/repositories/acorn_repository.dart` | `getAcornsByDate()` 메서드 추가 (중복 지급 방지) |
| `lib/features/home/data/repositories/acorn_repository_impl.dart` | `getAcornsByDate()` 구현 |
| `lib/features/home/data/datasources/acorn_local_datasource.dart` | `getAcornsByDate()` public 노출 |

### 핵심 로직 설계

#### AppConstants 추가

```dart
/// 절약 보너스 도토리 기준 (원) — 이 금액 이하로 사용하면 보너스 1개
static const int bonusThreshold = 5000;
```

#### DailySettlementService (신규)

```dart
/// lib/core/services/daily_settlement_service.dart
/// 날짜가 바뀔 때 호출되어 어제의 실적을 정산한다
/// - 이월 금액 계산 + 적용
/// - 도토리 지급 판정
@lazySingleton
class DailySettlementService {
  final CarryOverService _carryOverService;
  final AcornRepository _acornRepo;
  final DailyBudgetRepository _budgetRepo;
  final StreakService _streakService;

  DailySettlementService(
    this._carryOverService,
    this._acornRepo,
    this._budgetRepo,
    this._streakService,
  );

  /// 일일 정산 실행 (날짜 변경 시 1회 호출)
  Future<SettlementResult> settle() async {
    // 1. 이월 적용
    final carryOver = await _carryOverService.applyCarryOver();

    // 2. 어제 성공 여부 판정
    final wasSuccessful = await _streakService.wasYesterdaySuccessful();

    int acornsEarned = 0;

    if (wasSuccessful) {
      // 중복 지급 방지: 어제 날짜에 이미 도토리가 있는지 확인
      final existingAcorns = await _acornRepo.getAcornsByDate(
        AppDateUtils.yesterdayStart,
      );
      if (existingAcorns.isEmpty) {
        // 기본 도토리 1개
        await _acornRepo.addAcorn(1, '하루 만원 달성');
        acornsEarned++;

        // 보너스 판정: 어제 남은 금액이 5000원 이상이면 보너스
        final yesterdayRemaining = await _budgetRepo.getRemainingBudget(
          AppDateUtils.yesterdayStart,
        );
        if (yesterdayRemaining >= AppConstants.bonusThreshold) {
          await _acornRepo.addAcorn(1, '절약 보너스');
          acornsEarned++;
        }
      }
    }

    return SettlementResult(
      carryOver: carryOver,
      acornsEarned: acornsEarned,
      wasSuccessful: wasSuccessful,
    );
  }
}

/// 정산 결과 데이터
class SettlementResult {
  final int carryOver;
  final int acornsEarned;
  final bool wasSuccessful;

  const SettlementResult({
    required this.carryOver,
    required this.acornsEarned,
    required this.wasSuccessful,
  });
}
```

#### AcornRepository 인터페이스 추가

```dart
/// 특정 날짜의 도토리 목록을 조회한다 (중복 지급 방지용)
Future<List<AcornEntity>> getAcornsByDate(DateTime date);
```

### 엣지 케이스

- 어제 미사용 (기록 없음) → 도토리 미지급
- 어제 3000원 사용 (남은 7000원) → 기본 1개 + 보너스 1개 = 2개
- 어제 8000원 사용 (남은 2000원) → 기본 1개만
- 어제 12000원 사용 (초과) → 미지급
- 앱을 2일 안 열었다 복귀 → 어제만 정산 (그 전날은 이미 지나간 것으로 처리)
- settle() 중복 호출 → `getAcornsByDate()` 체크로 중복 지급 방지

### 테스트 포인트

- [ ] 어제 5000원 이하 사용 → 도토리 2개 지급
- [ ] 어제 5001~10000원 사용 → 도토리 1개 지급
- [ ] 어제 10001원 이상 사용 → 도토리 0개
- [ ] 어제 미사용 → 도토리 0개
- [ ] 중복 settle() 호출 → 도토리 추가 미지급
- [ ] SettlementResult 값 정확성

---

## S-28g: 메인 화면 도토리/스트릭 실데이터 연결

### 개요
현재 `HomeViewModel`이 이미 도토리/스트릭 데이터를 로드하고 있으나, 날짜 변경 정산 후 자동 갱신과 실시간 반영이 필요하다.

### 수정/생성 파일

| 파일 | 작업 |
|------|------|
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | DayChangeService 연동, 정산 후 상태 갱신 |
| `lib/main.dart` | WidgetsBindingObserver로 앱 포그라운드 복귀 감지 |
| `lib/features/home/presentation/widgets/acorn_streak_badge.dart` | 스트릭 0일 시 표시 분기 (선택) |

### 핵심 로직 설계

#### HomeViewModel 최종 형태

```dart
class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    _loadData();
    _watchExpenses();
    _watchDayChange();
    return const HomeState();
  }

  /// 날짜 변경 감지 → 정산 → 새 데이터 로드
  void _watchDayChange() {
    final dayChangeService = getIt<DayChangeService>();
    dayChangeService.onDayChanged.listen((_) async {
      // 일일 정산 (이월 + 도토리)
      final settlementService = getIt<DailySettlementService>();
      await settlementService.settle();

      // 새 날짜 데이터로 전체 갱신
      await refresh();
    });
  }

  // ... _loadData(), _watchExpenses(), refresh(), deleteExpense() 기존 유지
}
```

#### main.dart — 앱 라이프사이클 감지

```dart
class _DailyManwonAppState extends ConsumerState<DailyManwonApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ... 기존 코드
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 포그라운드 복귀 시 날짜 변경 체크
      getIt<DayChangeService>().checkDayChange();
    }
  }
}
```

### 엣지 케이스

- 앱 첫 실행 (정산 대상 없음) → 기본값 표시 (도토리 0, 스트릭 0)
- 자정 넘김 → 자동 정산 + UI 갱신
- 백그라운드 장시간 방치 후 복귀 → `checkDayChange()` 트리거 → 정산 + 갱신
- 정산 중 에러 → UI 깨지지 않도록 try-catch 유지
- 지출 추가/삭제 시 → `_watchExpenses()` 기존 로직으로 잔액 실시간 반영 (기존 동작 유지)

### 테스트 포인트

- [ ] 앱 시작 시 도토리/스트릭이 DB 실데이터로 표시
- [ ] 자정 넘김 후 정산 → 이월 반영 + 도토리 증가 + 스트릭 갱신
- [ ] 포그라운드 복귀 시 날짜 변경 감지 동작
- [ ] `AcornStreakBadge`: 실데이터 기반 렌더링

---

## 파일 생성/수정 총 정리

### 신규 생성 (4개)

| 파일 | 설명 |
|------|------|
| `lib/core/services/day_change_service.dart` | 날짜 변경 감지 (Timer + 포그라운드 체크) |
| `lib/core/services/carryover_service.dart` | 이월 금액 계산 + DB 적용 |
| `lib/core/services/streak_service.dart` | 스트릭 계산 통합 (중복 로직 제거) |
| `lib/core/services/daily_settlement_service.dart` | 일일 정산 오케스트레이터 |

### 수정 (9개)

| 파일 | 변경 내용 |
|------|-----------|
| `lib/core/constants/app_constants.dart` | `maxCarryOverDebt`, `bonusThreshold` 상수 추가 |
| `lib/core/utils/app_date_utils.dart` | `yesterdayStart` getter 추가 |
| `lib/features/home/domain/repositories/daily_budget_repository.dart` | `updateCarryOver()` 추가 |
| `lib/features/home/data/repositories/daily_budget_repository_impl.dart` | `updateCarryOver()` 구현 |
| `lib/features/home/data/datasources/daily_budget_local_datasource.dart` | `updateCarryOver()` 추가 |
| `lib/features/home/domain/repositories/acorn_repository.dart` | `getAcornsByDate()` 추가 |
| `lib/features/home/data/repositories/acorn_repository_impl.dart` | `getAcornsByDate()` 구현 |
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | 날짜 변경 구독 + 정산 트리거 |
| `lib/features/home/presentation/widgets/home_budget_header.dart` | 마이너스 이월 UI 대응 |
| `lib/main.dart` | `WidgetsBindingObserver` 추가 |

---

## 성공 기준 (Phase 4 완료 조건)

1. 자정을 넘기면 새 날짜 예산이 자동 생성된다
2. 전날 만원 이내 사용 시 남은 금액이 오늘 예산에 이월된다
3. 전날 초과 사용 시 마이너스 이월(-5000원 한도)이 적용된다
4. 이월 금액이 홈 화면에 색상 구분되어 표시된다
5. 만원 이내 성공 시 도토리 1개, 5000원 이하 사용 시 보너스 1개가 자동 지급된다
6. 연속 성공 일수가 정확히 계산되고 홈 화면에 실시간 반영된다
7. 중복 정산/지급이 발생하지 않는다
8. 앱 백그라운드 복귀 시 날짜 변경이 감지된다
