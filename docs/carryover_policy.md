# 이월 정책 구현 설계 (Carryover Policy)

## 작성일: 2026-04-10
## 상태: v5 — ACCEPT-WITH-RESERVATIONS (Codex 3차 리뷰 통과, 구현 준비 완료)
## 변경이력
- v1: 초안 작성
- v2: Codex 리뷰 반영 — 아키텍처 수정, DB 버전 정정, 캘린더 수정 지점 명세, 누락 날짜 알고리즘 추가, 도토리 정책 제거 반영
- v3: new_week_clean.png 활용 — 월요일 새 주 인터스티셜 UI, CharacterMood.newWeek, HomeViewModel isNewWeek 플래그, iOS 위젯 new_week catMood 통합
- v4: Codex 2차 리뷰 반영 — exhaustive switch 전체 명세, SharedPreferences→Repository, getOrCreateTodayBudget 시그니처 전파, isNewWeek false positive 수정, getStreakDays/getWeeklySummary effectiveBudget, _currentWeekKey 수정
- v5: Codex 3차 리뷰 반영 — _fillMissingDays 메서드명 수정, DailyBudgetEntity sealed→class(방법A 확정), setCarryoverEnabled ref.invalidate 추가, _loadMonth/_prefetchAdjacentMonths effectiveBudgetCache 추가, _ensureRow() 추가

---

## 요구사항 요약

- 설정에서 이월 정책 ON/OFF 토글
- **이월 ON**: 오늘 잔액(±)이 내일 예산에 반영
- **이월 OFF**: 매일 기본예산으로 고정 리셋
- **주간 경계**: 매주 월요일 무조건 기본예산으로 리셋 (전주 이월 소멸)
- 초과 지출도 이월 적용 (마이너스 이월)
- 정책 변경 → 다음날부터 적용

### 정책 예시 (기본예산 10,000원, 이월 ON)

| 요일 | 기본예산 | carryOver | 실질예산 | 지출 | 내일 carryOver |
|------|---------|----------|---------|------|--------------|
| 월   | 10,000  | 0        | 10,000  | 3,000 | +7,000 |
| 화   | 10,000  | +7,000   | 17,000  | 12,000 | +5,000 |
| 수   | 10,000  | +5,000   | 15,000  | 16,000 | -1,000 |
| 목   | 10,000  | -1,000   | 9,000   | 2,000 | +7,000 |
| 금   | 10,000  | +7,000   | 17,000  | 5,000 | +12,000 |
| **다음 월** | 10,000 | **0** | 10,000 | — | — |

---

## 수락 기준 (Acceptance Criteria)

1. [ ] 설정 화면에 이월 정책 토글이 존재하며, ON/OFF 상태가 DB에 영구 저장된다
2. [ ] 이월 ON 상태에서 오늘 앱 최초 접근 시 전날 잔액이 정확히 계산되어 오늘 DailyBudget.carryOver에 저장된다
3. [ ] 이월 ON + 월요일 진입 시 carryOver = 0으로 강제 리셋된다 (주간 경계)
4. [ ] 이월 OFF 상태에서 carryOver = 0으로 오늘 예산이 생성된다
5. [ ] 홈 화면의 totalBudget = baseAmount + carryOver 로 표시된다
6. [ ] 홈 화면의 remainingBudget = effectiveBudget - 지출 로 계산된다 (carryOver 반영)
7. [ ] 홈 화면에 이월 금액 배지(+7,000 이월 / -1,000 초과이월)가 표시된다 (carryOver ≠ 0일 때만)
8. [ ] 캘린더의 날짜별 성공 판단이 effectiveBudget(baseAmount + carryOver) 기준으로 동작한다
9. [ ] 정책 변경(토글) 시 당일 예산은 유지, 다음날부터 새 정책 적용된다
10. [ ] 이월 정책 변경 후 홈/캘린더 UI가 자동으로 갱신된다
11. [ ] 앱을 며칠 연속 미실행 시, 접근 시점에 누락된 날짜들의 DailyBudget이 순서대로 생성된다
12. [ ] **이월 ON** 사용자가 월요일 첫 접근 시 `new_week_clean.png` 인터스티셜이 표시되고, "시작하기" 탭 후 같은 주 내 재표시되지 않는다 (이월 OFF 사용자에게는 미표시)
13. [ ] 인터스티셜 표시 중 iOS 홈 위젯의 catMood가 `new_week`로 전달되어 `CatNewWeek` 이미지가 렌더링된다
14. [ ] `CharacterMood.newWeek`의 `assetPath`가 `assets/images/character/new_week_clean.png`를 반환한다

---

## 구현 단계

### Phase 1: DB 스키마 확장

**파일**: `lib/core/database/app_database.dart`

#### 1-1. UserPreferences 테이블에 carryoverEnabled 컬럼 추가

```dart
BoolColumn get carryoverEnabled => boolean().withDefault(const Constant(false))();
```

#### 1-2. 마이그레이션 — schemaVersion 6 → 7

> ⚠️ 현재 `app_database.dart:96`에서 `schemaVersion => 6`. 반드시 7로 올릴 것.

```dart
@override
int get schemaVersion => 7;

@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    // 기존 migration 블록 유지 (from < 6 등)
    if (from < 7) {
      await m.addColumn(userPreferences, userPreferences.carryoverEnabled);
    }
  },
);
```

**코드젠 실행 필수**: `dart run build_runner build --delete-conflicting-outputs`

---

### Phase 2: DataSource 계층 수정

#### 2-1. SettingsLocalDatasource — carryover 설정 CRUD

**파일**: `lib/features/settings/data/datasources/settings_local_datasource.dart`

```dart
Future<bool> getCarryoverEnabled() async {
  final row = await (_db.select(_db.userPreferences)
        ..where((t) => t.id.equals(1)))
      .getSingleOrNull();
  return row?.carryoverEnabled ?? false;
}

Future<void> setCarryoverEnabled(bool enabled) async {
  await _ensureRow();  // 기존 setDailyBudget/setIsDarkMode와 동일 패턴 — row 없으면 생성
  await (_db.update(_db.userPreferences)..where((t) => t.id.equals(1)))
      .write(UserPreferencesCompanion(carryoverEnabled: Value(enabled)));
}
```

#### 2-2. DailyBudgetLocalDatasource — getRemainingBudget carryOver 반영

**파일**: `lib/features/home/data/datasources/daily_budget_local_datasource.dart`

**수정 대상**: `getRemainingBudget()` (line 63)

```dart
// 기존 (line 65):
// final total = budget?.baseAmount ?? AppConstants.dailyBudget;

// 수정:
Future<int> getRemainingBudget(DateTime date) async {
  final budget = await getBudgetByDate(date);
  final effectiveBudget = (budget?.baseAmount ?? AppConstants.dailyBudget)
      + (budget?.carryOver ?? 0);  // carryOver 반영

  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  final expenses = await (_db.select(_db.expenses)
        ..where((e) =>
            e.createdAt.isBiggerOrEqualValue(start) &
            e.createdAt.isSmallerThanValue(end)))
      .get();

  final spent = expenses.fold(0, (sum, e) => sum + e.amount);
  return effectiveBudget - spent;
}
```

> `watchRemainingBudget()`(line 82)은 `getRemainingBudget()`을 asyncMap으로 호출하므로 자동 반영됨.

#### 2-3. DailyBudgetLocalDatasource — 오늘 예산 생성 (carryOver 파라미터 수신)

`getOrCreateTodayBudget()`은 carryOver 값을 **외부(UseCase)에서 받아** 저장만 담당.
DataSource는 설정 조회/비즈니스 판단을 직접 하지 않음 (Clean Architecture 원칙).

```dart
/// carryOver는 UseCase가 계산하여 전달
Future<DailyBudgetEntity> getOrCreateTodayBudget({required int carryOver}) async {
  final today = DateTime.now();
  final existing = await getBudgetByDate(today);
  if (existing != null) return existing;

  final prefRow = await (_db.select(_db.userPreferences)
        ..where((t) => t.id.equals(1)))
      .getSingleOrNull();
  final budgetAmount = prefRow?.dailyBudget ?? AppConstants.dailyBudget;

  final id = await _db.into(_db.dailyBudgets).insert(
    DailyBudgetsCompanion.insert(
      date: DateTime(today.year, today.month, today.day),
      baseAmount: Value(budgetAmount),
      carryOver: Value(carryOver),  // UseCase에서 전달된 값
    ),
  );

  final row = await (_db.select(_db.dailyBudgets)
        ..where((t) => t.id.equals(id)))
      .getSingle();
  return row.toEntity();
}
```

#### 2-4. 누락 날짜 갭 처리 (앱 다일 미실행 대응)

**파일**: `lib/features/home/data/datasources/daily_budget_local_datasource.dart`

`getOrCreateTodayBudget()` 호출 이전 단계. **UseCase에서 처리** (Phase 3 참고).

마지막 DailyBudget row 날짜 조회 메서드 추가:

```dart
Future<DateTime?> getLastBudgetDate() async {
  final row = await (_db.select(_db.dailyBudgets)
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(1))
      .getSingleOrNull();
  return row?.date;
}

/// 특정 날짜의 총 지출 합계 조회
Future<int> getTotalExpensesByDate(DateTime date) async {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  final expenses = await (_db.select(_db.expenses)
        ..where((e) =>
            e.createdAt.isBiggerOrEqualValue(start) &
            e.createdAt.isSmallerThanValue(end)))
      .get();
  return expenses.fold(0, (sum, e) => sum + e.amount);
}
```

---

### Phase 3: Domain / UseCase 계층

#### 3-1. SettingsRepository 인터페이스 및 구현

**파일**: `lib/features/settings/domain/repositories/settings_repository.dart`
```dart
Future<bool> getCarryoverEnabled();
Future<Result<void>> setCarryoverEnabled(bool enabled);

// 새 주 확인 플래그 (SharedPreferences 직접 접근 금지 — Repository 경유)
Future<bool> hasSeenNewWeekThisWeek(String weekKey);
Future<void> markNewWeekSeen(String weekKey);
```

**파일**: `lib/features/settings/data/datasources/settings_local_datasource.dart`
```dart
Future<bool> hasSeenNewWeekThisWeek(String weekKey) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('new_week_seen_$weekKey') ?? false;
}

Future<void> markNewWeekSeen(String weekKey) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('new_week_seen_$weekKey', true);
}
```

**파일**: `lib/features/settings/data/repositories/settings_repository_impl.dart`
- carryover + newWeekFlag 4개 메서드를 `SettingsLocalDatasource`에 위임

#### 3-2. DailyBudgetRepository 인터페이스 시그니처 변경 전파

**파일**: `lib/features/home/domain/repositories/daily_budget_repository.dart`

기존 파라미터 없는 `getOrCreateTodayBudget()`을 아래 두 메서드로 교체:
```dart
abstract class DailyBudgetRepository {
  // 기존 메서드 유지
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date);

  // 시그니처 변경 — UseCase에서 carryOver 계산 후 전달
  Future<DailyBudgetEntity> getOrCreateTodayBudget({required int carryOver});

  // 갭 처리용 신규 메서드 (날짜 명시)
  Future<DailyBudgetEntity> getOrCreateBudgetForDate({
    required DateTime date,
    required int carryOver,
  });

  // UseCase용 조회 메서드 신규 추가
  Future<DateTime?> getLastBudgetDate();
  Future<int> getTotalExpensesByDate(DateTime date);
}
```

**파일**: `lib/features/home/data/repositories/daily_budget_repository_impl.dart`

위 4개 메서드를 `DailyBudgetLocalDatasource`에 위임.

**DI 등록 변경**:

`GetTodayBudgetUseCase`에 `SettingsRepository` 파라미터가 추가되므로 Injectable이 자동 처리.
단, `@lazySingleton` 어노테이션이 있는 경우 생성자에 두 파라미터가 모두 등록된 타입임을 확인:
```dart
@lazySingleton
class GetTodayBudgetUseCase {
  GetTodayBudgetUseCase(this._repository, this._settingsRepository);
  // GetIt + Injectable이 자동 주입 (두 타입 모두 @lazySingleton 등록 전제)
}
```

---

#### 3-3. GetTodayBudgetUseCase — 이월 계산 로직 (아키텍처 핵심)

**파일**: `lib/features/home/domain/usecases/get_today_budget_use_case.dart`

> ⚠️ carryOver 판단 로직은 DataSource가 아닌 UseCase에서 담당 (Clean Architecture)

```dart
/// SettingsRepository를 주입받아 carryover 정책 판단
class GetTodayBudgetUseCase {
  GetTodayBudgetUseCase(this._repository, this._settingsRepository);

  final DailyBudgetRepository _repository;
  final SettingsRepository _settingsRepository;

  Future<DailyBudgetEntity> getOrCreateTodayBudget() async {
    // 1. 누락 날짜 갭 처리
    await _fillMissingDays();

    // 2. 오늘 예산 생성 (carryOver 계산 후 전달)
    final carryOver = await _computeTodayCarryOver();
    return _repository.getOrCreateTodayBudget(carryOver: carryOver);
  }

  /// 마지막 예산 날짜 ~ 오늘 사이 누락 날짜 순서대로 채우기
  Future<void> _fillMissingDays() async {
    final lastDate = await _repository.getLastBudgetDate();
    if (lastDate == null) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var cursor = DateTime(lastDate.year, lastDate.month, lastDate.day)
        .add(const Duration(days: 1));

    while (cursor.isBefore(todayDate)) {
      final isMonday = cursor.weekday == DateTime.monday;
      final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();

      int carryOver = 0;
      if (carryoverEnabled && !isMonday) {
        final prev = cursor.subtract(const Duration(days: 1));
        final prevBudget = await _repository.getBudgetByDate(prev);
        if (prevBudget != null) {
          final prevSpent = await _repository.getTotalExpensesByDate(prev);
          carryOver = prevBudget.effectiveBudget - prevSpent;
        }
      }

      // ⚠️ 날짜 지정 버전 사용 — getOrCreateTodayBudget은 date 파라미터 없음
      await _repository.getOrCreateBudgetForDate(
        date: cursor,
        carryOver: carryOver,
      );
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  Future<int> _computeTodayCarryOver() async {
    final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
    final today = DateTime.now();
    final isMonday = today.weekday == DateTime.monday;

    if (!carryoverEnabled || isMonday) return 0;

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayBudget = await _repository.getBudgetByDate(yesterday);
    if (yesterdayBudget == null) return 0;

    final yesterdaySpent = await _repository.getTotalExpensesByDate(yesterday);
    return yesterdayBudget.effectiveBudget - yesterdaySpent;
  }
}
```

#### 3-3. CharacterMood — newWeek 케이스 추가

**파일**: `lib/core/constants/app_constants.dart`

```dart
enum CharacterMood {
  comfortable,
  normal,
  danger,
  over,
  newWeek,  // 월요일 첫 접근 전용 — 새로운 한주 시작 연출
}
```

> `fromRatio()`는 변경하지 않음. `newWeek`는 ratio 기반이 아니라 HomeViewModel이 직접 세팅.

**exhaustive switch 전체 수정 목록** — `newWeek` 추가 시 아래 모든 switch에 케이스를 추가해야 컴파일 에러가 발생하지 않음:

| switch 위치 | 반환값 |
|-------------|--------|
| `assetPath` | `'assets/images/character/new_week_clean.png'` |
| `comment` | `'새로운 한주가 시작됐어!'` |
| `statusColor` | `AppColors.budgetComfortable` (comfortable과 동일) |
| `label` | `'새 주'` |
| `BudgetCatIndicator._buildIdleLoop()` | comfortable idle 애니메이션 재사용 |
| `BudgetCatIndicator._buildMicroAnimation()` | comfortable micro 애니메이션 재사용 |

**파일**: `lib/features/home/presentation/widgets/budget_cat_indicator.dart`

`_buildIdleLoop()` switch (line 59-91) 와 `_buildMicroAnimation()` switch (line 95-158) 양쪽에 추가:
```dart
case CharacterMood.newWeek:
  // 새 주 연출은 인터스티셜에서 담당 — BudgetCatIndicator는 comfortable 동작과 동일하게 처리
  return _buildComfortableIdleLoop();  // 기존 comfortable 분기 로직 재사용
```

---

#### 3-4. DailyBudgetEntity — effectiveBudget getter

**파일**: `lib/features/home/domain/entities/daily_budget.dart`

> ⚠️ 현재 `sealed class DailyBudgetEntity`로 선언됨. freezed + sealed class에서는 private constructor 패턴이 불가. 두 가지 방법 중 하나 선택:

**방법 A (권장)**: `sealed` 제거 후 private constructor 패턴 사용
```dart
@freezed
class DailyBudgetEntity with _$DailyBudgetEntity {  // sealed 제거
  const DailyBudgetEntity._(); // private constructor

  const factory DailyBudgetEntity({
    required int id,
    required DateTime date,
    required int baseAmount,
    required int carryOver,
    String? mood,
  }) = _DailyBudgetEntity;

  int get effectiveBudget => baseAmount + carryOver;
}
```

**방법 B (sealed 유지 시)**: extension으로 분리
```dart
// daily_budget.dart 하단 또는 별도 파일
extension DailyBudgetEntityX on DailyBudgetEntity {
  int get effectiveBudget => baseAmount + carryOver;
}
```

> 코드베이스 전체에서 `DailyBudgetEntity`에 대한 `switch` 패턴 매칭이 없음 확인 → **방법 A 사용** (`sealed` 제거).

---

### Phase 4: ViewModel 수정

#### 4-1. SettingsViewModel

**파일**: `lib/features/settings/presentation/viewmodels/settings_view_model.dart`

`SettingsState`에 추가:
```dart
final bool carryoverEnabled;
```

메서드 추가:
```dart
Future<void> setCarryoverEnabled(bool enabled) async {
  await _settingsRepository.setCarryoverEnabled(enabled);
  state = state.copyWith(carryoverEnabled: enabled);
  // 예산 값 자체는 다음날부터 변경되지만, isNewWeek/배지 등 UI 상태 반영을 위해 즉시 invalidate
  // 기존 setDailyBudget()과 동일한 패턴 (settings_view_model.dart:207-208 참조)
  ref.invalidate(homeViewModelProvider);
  ref.invalidate(calendarViewModelProvider);
}
```

`_loadSettings()`에서 초기 로드:
```dart
final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
state = state.copyWith(carryoverEnabled: carryoverEnabled);
```

#### 4-2. HomeViewModel

**파일**: `lib/features/home/presentation/viewmodels/home_view_model.dart`

`HomeState`에 추가:
```dart
final int carryOver;      // 배지 표시용
final bool isNewWeek;     // 월요일 첫 접근 인터스티셜 트리거
```

`HomeViewModel` 생성자에 `SettingsRepository` 주입 추가:
```dart
// @injectable DI — SettingsRepository 파라미터 추가
HomeViewModel(this._getTodayBudgetUseCase, this._settingsRepository, ...);
```

`_loadData()` 수정:
```dart
// line 113 — 기존:
// final totalBudget = budget.baseAmount;
// 수정:
final totalBudget = budget.effectiveBudget;  // baseAmount + carryOver
final carryOver = budget.carryOver;

// 새 주 감지: 월요일 + 이월 ON + SharedPreferences 미확인
// ⚠️ carryoverEnabled 체크 필수 — OFF 사용자 오탐 방지
final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
final weekKey = _currentWeekKey();
final isNewWeek = DateTime.now().weekday == DateTime.monday
    && carryoverEnabled
    && !await _settingsRepository.hasSeenNewWeekThisWeek(weekKey);

// line 119 — getRemainingBudget은 이미 Phase 2에서 effectiveBudget 기준으로 수정됨
```

`state = state.copyWith(...)` 에 `carryOver: carryOver, isNewWeek: isNewWeek` 추가.

**새 주 확인 플래그 — SettingsRepository 경유** (SharedPreferences 직접 접근 금지):
```dart
void markNewWeekSeen() async {
  // SharedPreferences 직접 사용 금지 — SettingsRepository 경유
  await _settingsRepository.markNewWeekSeen(_currentWeekKey());
  state = state.copyWith(isNewWeek: false);
}

String _currentWeekKey() {
  // 해당 주의 월요일 날짜를 키로 사용 (ISO 주차 연산 오류 회피)
  // 예: 2026-04-06 (그 주 월요일)
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
  final d = DateTime(monday.year, monday.month, monday.day);
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
```

홈 위젯 갱신 (line 139-152):
```dart
unawaited(getIt<WidgetService>().updateWidget(
  total: totalBudget,  // effectiveBudget 전달
  catMood: isNewWeek ? 'new_week'
      : CharacterMood.fromRatio(...).name,  // 새 주이면 new_week 전달
  ...
));
```

#### 4-3. CalendarViewModel — 4개 수정 지점

**파일**: `lib/features/calendar/presentation/viewmodels/calendar_view_model.dart`

**수정 지점 1** — `monthlySuccessCount` getter (line 79):
```dart
// 기존:
// final budget = monthlyBaseAmounts[date] ?? AppConstants.dailyBudget;
// 수정: (monthlyEffectiveBudgets 맵 사용, 아래 참조)
final budget = monthlyEffectiveBudgets[date] ?? AppConstants.dailyBudget;
```

**수정 지점 2** — `CalendarState`에 필드 추가:
```dart
final Map<DateTime, int> monthlyEffectiveBudgets; // baseAmount + carryOver
```

**수정 지점 3** — `loadMonthData()`에서 effectiveBudget 로드:
```dart
// calendar_local_datasource에 getMonthlyEffectiveBudgets() 추가 후 사용
monthlyEffectiveBudgets: await _useCase.getMonthlyEffectiveBudgets(year, month),
```

**수정 지점 3-a** — `_loadMonth()` (line 370) 동일하게 적용:
```dart
// 기존: _baseAmountCache[key] = baseAmounts;
// 추가: _effectiveBudgetCache[key] = effectiveBudgets;
// getMonthlyEffectiveBudgets()를 병렬로 호출하여 _effectiveBudgetCache에 저장
final effectiveBudgets = await _useCase.getMonthlyEffectiveBudgets(year, month);
_effectiveBudgetCache[key] = effectiveBudgets;
```

**수정 지점 3-b** — `_prefetchAdjacentMonths()` (line 393) Future.wait에 추가:
```dart
// 기존 Future.wait 2개에 getMonthlyEffectiveBudgets 2개 추가
final results = await Future.wait([
  _useCase.getMonthlyBaseAmounts(prevYear, prevMonth),
  _useCase.getMonthlyBaseAmounts(nextYear, nextMonth),
  _useCase.getMonthlyEffectiveBudgets(prevYear, prevMonth),  // 추가
  _useCase.getMonthlyEffectiveBudgets(nextYear, nextMonth),  // 추가
]);
_effectiveBudgetCache[prevKey] = results[2] as Map<DateTime, int>;
_effectiveBudgetCache[nextKey] = results[3] as Map<DateTime, int>;
```

> `_effectiveBudgetCache`는 `_baseAmountCache`와 동일한 `Map<String, Map<DateTime, int>>` 타입으로 `CalendarViewModel`에 추가.

**파일**: `lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart`

**수정 지점 4** — `calculateMood` 호출부 (line 280, 294):
```dart
// 기존 (line 280):
// final baseAmount = state.monthlyBaseAmounts[cellDate] ?? ...
// 수정:
final effectiveBudget = state.monthlyEffectiveBudgets[cellDate]
    ?? AppConstants.dailyBudget;
mood = calculateMood(effectiveBudget, totalSpent);  // line 294
```

**파일**: `lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart`

**수정 지점 5** — `calculateMood` 호출부 (line 167):
```dart
// dayBudget을 effectiveBudget 기준으로 변경
mood = calculateMood(dayEffectiveBudget, totalAmount);
```

**파일**: `lib/features/calendar/data/datasources/calendar_local_datasource.dart`

**`getMonthlyEffectiveBudgets()` 신규 메서드** — carryOver 포함 예산 맵 반환:
```dart
Future<Map<DateTime, int>> getMonthlyEffectiveBudgets(int year, int month) async {
  final rows = await (_db.select(_db.dailyBudgets)
        ..where((t) =>
            t.date.isBiggerOrEqualValue(DateTime(year, month, 1)) &
            t.date.isSmallerThanValue(DateTime(year, month + 1, 1))))
      .get();
  return {
    for (final r in rows)
      DateTime(r.date.year, r.date.month, r.date.day):
          r.baseAmount + r.carryOver,
  };
}
```

**`getStreakDays()` 수정** (line 62 — 현재 `baseAmounts` 기준):
```dart
// 기존:
// final budget = baseAmounts[cursor] ?? AppConstants.dailyBudget;
// 수정: DailyBudgets에서 effectiveBudget(baseAmount + carryOver) 조회
final budgetRow = await getBudgetByDate(cursor);
final budget = budgetRow != null
    ? budgetRow.baseAmount + budgetRow.carryOver
    : AppConstants.dailyBudget;
```

**`getTotalSuccessCount()` 수정** (line 116 — 현재 `baseAmounts` 기준):
```dart
// 기존:
// final budget = baseAmounts[e.key] ?? AppConstants.dailyBudget;
// 수정: effectiveBudget 맵 사용 (getMonthlyEffectiveBudgets 결과 활용)
final budget = effectiveBudgets[e.key] ?? AppConstants.dailyBudget;
```

**`getWeeklySummary()` 수정** (`calendar_view_model.dart` line 328 — `_baseAmountCache` 기준):
```dart
// 기존:
// final dayBudget = _baseAmountCache[...] ?? AppConstants.dailyBudget;
// 수정: effectiveBudget 캐시 사용 (_effectiveBudgetCache 별도 보관 또는 getMonthlyEffectiveBudgets 재사용)
final dayBudget = _effectiveBudgetCache[day] ?? AppConstants.dailyBudget;
```
> `_effectiveBudgetCache`는 `loadMonthData()` 시 `monthlyEffectiveBudgets`와 동일한 맵을 저장해 재사용.

---

### Phase 5: UI 구현

#### 5-1. 설정 화면 — 이월 정책 섹션

**새 파일**: `lib/features/settings/presentation/widgets/carryover_toggle_section.dart`

```
예산 정책 섹션
├─ 일일 기본예산 (기존)
└─ 이월 정책 토글
   ├─ 라벨: "남은 예산 이월"
   ├─ 서브텍스트: "매주 월요일 초기화됩니다"
   └─ [ON일 때] 인라인 시뮬레이션 카드
      예) 오늘 3,000원 사용 시 → 내일 17,000원
```

- Light/Dark 모두 `AppColors` 토큰 사용 필수
- 시뮬레이션 카드: 기본예산 기준 3,000원 예시 고정 표시

#### 5-2. 홈 화면 — 이월 배지

**새 파일**: `lib/features/home/presentation/widgets/carryover_badge_widget.dart`

```dart
// carryOver > 0: '+7,000 이월' (AppColors.comfortable)
// carryOver < 0: '-1,000 초과이월' (AppColors.danger)
// carryOver == 0: SizedBox.shrink()
```

- 다크모드: `AppColors.darkComfortable`, `AppColors.darkDanger` 사용

#### 5-3. 새 주 인터스티셜 — NewWeekInterstitialWidget

**새 파일**: `lib/features/home/presentation/widgets/new_week_interstitial_widget.dart`

**트리거 조건**: `HomeState.isNewWeek == true` (월요일 + SharedPreferences 미확인)

**레이아웃**:
```
[반투명 오버레이 — 탭하면 닫힘]
┌─────────────────────────────┐
│                             │
│   new_week_clean.png        │  ← assets/images/character/new_week_clean.png
│   (w: 180, fit: contain)    │
│                             │
│   새로운 한 주가 시작됐어!     │  ← AppTypography.titleMedium
│   오늘부터 다시 10,000원 🐾   │  ← AppTypography.bodySmall, subTextColor
│                             │
│   [시작하기]                 │  ← FilledButton, AppColors.budgetComfortable
└─────────────────────────────┘
```

**동작**:
- 등장: `flutter_animate` `.fadeIn(duration: 400ms).slideY(begin: 0.15)`
- "시작하기" 탭 → `homeViewModel.markNewWeekSeen()` → 오버레이 제거
- 오버레이 외부 탭으로도 닫힘 (`GestureDetector` wrap)
- 다크모드: 오버레이 `Colors.black.withValues(alpha: 0.6)`, 카드 `AppColors.darkSurface`

**HomeScreen 통합**:
```dart
// home_screen.dart — Stack 최상단에 조건부 표시
if (state.isNewWeek)
  NewWeekInterstitialWidget(
    onDismiss: () => ref.read(homeViewModelProvider.notifier).markNewWeekSeen(),
  ),
```

---

#### 5-4. 정책 변경 다이얼로그

이월 토글 변경 시:
```
"내일부터 적용됩니다.
오늘 예산은 유지됩니다."
[확인]
```

---

### Phase 6: iOS 위젯 new_week catMood 연동

**파일**: `ios/DailyHomeWidget/Utils/WidgetHelpers.swift`

`catImageName()` 함수에 `new_week` 케이스 추가:

```swift
func catImageName(for mood: String) -> String {
    switch mood {
    case "comfortable": return "CatComfortable"
    case "normal":      return "CatNormal"
    case "danger":      return "CatDanger"
    case "over":        return "CatOver"
    case "new_week":    return "CatNewWeek"   // new_week_clean.png → iOS 에셋 "CatNewWeek"
    default:            return "CatComfortable"
    }
}
```

> **에셋 등록 필수**: `new_week_clean.png`를 Xcode에서 `DailyHomeWidget/Assets.xcassets`에
> `CatNewWeek` 이름으로 Image Set 등록 필요. Flutter 에셋과 별도로 iOS 타겟에 복사.

**Flutter → iOS 위젯 전달** (`lib/features/home/presentation/viewmodels/home_view_model.dart`):
```dart
catMood: isNewWeek ? 'new_week' : CharacterMood.fromRatio(ratio).name,
```
(Phase 4-2에서 이미 명세됨 — 위젯 서비스 `updateWidget()` 호출부)

---

## 파일 변경 목록

| 파일 | 변경 유형 | 내용 |
|------|---------|------|
| `lib/core/database/app_database.dart` | 수정 | schemaVersion **6→7**, migration, carryoverEnabled 컬럼 |
| `lib/features/settings/data/datasources/settings_local_datasource.dart` | 수정 | carryover CRUD 메서드 추가 |
| `lib/features/home/data/datasources/daily_budget_local_datasource.dart` | 수정 | `getRemainingBudget` effectiveBudget 반영, `getOrCreateTodayBudget` 파라미터 변경, `getLastBudgetDate`/`getTotalExpensesByDate` 추가 |
| `lib/features/settings/domain/repositories/settings_repository.dart` | 수정 | carryover 인터페이스 추가 |
| `lib/features/settings/data/repositories/settings_repository_impl.dart` | 수정 | carryover 구현 추가 |
| `lib/features/home/domain/entities/daily_budget.dart` | 수정 | `const _()` private constructor + `effectiveBudget` getter |
| `lib/features/home/domain/repositories/daily_budget_repository.dart` | 수정 | `getOrCreateTodayBudget({carryOver})`, `getOrCreateBudgetForDate({date, carryOver})`, `getLastBudgetDate`, `getTotalExpensesByDate` 인터페이스 추가 |
| `lib/features/home/data/repositories/daily_budget_repository_impl.dart` | 수정 | 신규 메서드 4개 DataSource 위임 구현 |
| `lib/features/home/domain/usecases/get_today_budget_use_case.dart` | 수정 | `SettingsRepository` 주입, 이월 계산 + 갭 처리 로직 |
| `lib/features/settings/presentation/viewmodels/settings_view_model.dart` | 수정 | `carryoverEnabled` 상태 + `setCarryoverEnabled()` |
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | 수정 | `carryOver`/`isNewWeek` 상태, `totalBudget = effectiveBudget` (line 113), `SettingsRepository` 주입, `markNewWeekSeen()` |
| `lib/features/calendar/presentation/viewmodels/calendar_view_model.dart` | 수정 | `monthlyEffectiveBudgets` 필드, `monthlySuccessCount` 수정 |
| `lib/features/calendar/presentation/widgets/sliding_calendar_grid.dart` | 수정 | `calculateMood` effectiveBudget 기준 (line 280, 294) |
| `lib/features/calendar/presentation/widgets/sliding_weekly_grid.dart` | 수정 | `calculateMood` effectiveBudget 기준 (line 167) |
| `lib/features/calendar/data/datasources/calendar_local_datasource.dart` | 수정 | `getMonthlyEffectiveBudgets()` 추가, `getStreakDays`/`getTotalSuccessCount` effectiveBudget 반영 |
| `lib/features/calendar/domain/usecases/get_monthly_calendar_data_use_case.dart` | 수정 | `getMonthlyEffectiveBudgets()` 위임 메서드 추가 |
| `lib/features/settings/presentation/widgets/carryover_toggle_section.dart` | 신규 | 이월 토글 + 시뮬레이션 카드 위젯 (Light/Dark) |
| `lib/features/home/presentation/widgets/carryover_badge_widget.dart` | 신규 | 이월 금액 배지 위젯 (Light/Dark) |
| `lib/features/home/presentation/widgets/new_week_interstitial_widget.dart` | 신규 | 월요일 새 주 인터스티셜 오버레이 (new_week_clean.png 활용) |
| `lib/core/constants/app_constants.dart` | 수정 | `CharacterMood.newWeek` 케이스 + assetPath/comment/statusColor/label 추가 |
| `lib/features/home/presentation/widgets/budget_cat_indicator.dart` | 수정 | `_buildIdleLoop()`, `_buildMicroAnimation()` switch에 `newWeek` 케이스 추가 |
| `ios/DailyHomeWidget/Utils/WidgetHelpers.swift` | 수정 | `catImageName()` — `"new_week": "CatNewWeek"` 추가 |

---

## 리스크 및 완화

| 리스크 | 완화 방법 |
|--------|---------|
| 장기 미접속 시 갭 처리 주간 경계 복수 통과 | `_fillMissingDays()`가 날짜별 월요일 체크를 개별로 수행 — 주 수에 무관하게 정확히 처리 |
| DB 마이그레이션 실패 | `withDefault(false)` + `addColumn`만 사용, 기존 데이터 무결성 보장 |
| carryOver 계산 중 어제 예산 미존재 | null 체크 → carryOver = 0 폴백 |
| 정책 중간 변경 시 당일 예산 변경 | 변경은 다음날 적용이므로 당일 DailyBudget 건드리지 않음 |
| `checkDateChange()` 자정 통과 시 이월 미처리 | `home_view_model.dart`의 `checkDateChange()`가 `_loadData()`를 호출 → `getOrCreateTodayBudget()`이 재실행되므로 자동 처리됨 |
| 마이너스 이월 극단적 누적 | 현재 버전은 하한 제한 없음 (정책 결정 보류). 추후 `-baseAmount` 이하 클램핑 고려 가능 |
| `CharacterMood.newWeek` 추가 시 exhaustive switch 컴파일 에러 | `app_constants.dart` + `budget_cat_indicator.dart` 6개 switch 사이트 모두 케이스 추가 필수 (Phase 3-3 목록 참조) |
| 이월 OFF 사용자 월요일 인터스티셜 오탐 | `isNewWeek` 조건에 `carryoverEnabled` 체크 포함 (Phase 4-2) |
| `_currentWeekKey()` 연도 경계 오류 | 주차 번호 대신 해당 주 월요일 날짜(`yyyy-MM-dd`)를 키로 사용 |
| SharedPreferences ViewModel 직접 접근 | `SettingsRepository.hasSeenNewWeekThisWeek()` / `markNewWeekSeen()`으로 경유 (Phase 3-1) |

---

## 검증 단계

1. 이월 OFF → 매일 기본예산으로 고정 (carryOver = 0)
2. 이월 ON + 절약 → 다음날 예산 증가
3. 이월 ON + 초과 → 다음날 예산 감소 (remainingBudget도 carryOver 반영)
4. 이월 ON + 월요일 접근 → carryOver = 0 강제 리셋
5. 앱 3일 미실행 후 접근 → 누락 날짜 순서대로 생성, 월요일 경계 정확히 처리
6. 이월 ON → OFF 변경 → 다음날 기본예산으로 리셋
7. 홈 배지 표시/미표시 조건 (carryOver = 0이면 숨김)
8. 캘린더 성공 판단이 effectiveBudget 기준인지 확인
9. 홈 위젯 서비스에 effectiveBudget 전달 확인
10. 자정 앱 활성 상태에서 날짜 변경 시 이월 정상 처리
11. 월요일 첫 실행 → 인터스티셜 표시 → "시작하기" → 재진입 시 미표시 확인
12. 같은 주 화요일~일요일 접근 → 인터스티셜 미표시 확인
13. iOS 위젯 — 월요일 첫 접근 시 catMood='new_week' 전달, CatNewWeek 이미지 표시 확인

---

## 커밋 계획

```
feat(database): 이월 정책 — carryoverEnabled 컬럼 추가 및 schemaVersion 7 마이그레이션
feat(settings): 이월 정책 설정 — DataSource/Repository/ViewModel 구현
feat(home): 이월 계산 — getRemainingBudget effectiveBudget 반영 및 UseCase 리팩토링
feat(calendar): 이월 정책 — effectiveBudget 기준 성공 판단 적용
feat(home): 이월 배지 위젯 추가
feat(settings): 이월 정책 토글 UI — 설정 화면 섹션 추가
feat(home): 새 주 인터스티셜 — new_week_clean.png 활용 월요일 첫 접근 연출
feat(constants): CharacterMood.newWeek 케이스 추가
feat(widget): iOS 위젯 new_week catMood 연동 — CatNewWeek 에셋 추가
```
