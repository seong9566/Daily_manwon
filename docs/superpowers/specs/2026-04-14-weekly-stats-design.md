# 주간 통계 화면 설계

**날짜:** 2026-04-14  
**범위:** StatsScreen에 월간/주간 토글 추가, 주간 통계 뷰 구현

---

## 목표

통계 화면에 월간/주간 토글을 추가해 **주간 통계**를 볼 수 있게 한다.  
주간 통계는 레이어 1(핵심 수치) + 레이어 2(인사이트)로 구성된다.

---

## 표시 데이터

### 레이어 1 — 핵심 수치
- **일별 지출 bar chart** (일~토 7개 막대 + 예산선 점선)
- **총 지출** (해당 주 합산)
- **성공일 수** (예산 이하 달성 일수 / 집계 가능 일수, 예: 4/5일)
- **일평균 지출**

### 레이어 2 — 인사이트
- **전주 대비 증감** (예: ↓ 전주보다 3,200원 적게 씀 / 데이터 없으면 미표시)
- **최다 지출 카테고리** (이번 주 카테고리 중 1위)

---

## 주 시작 기준

**일요일 (0=일, 6=토)** — SQLite `strftime('%w')` 0=일 기준과 동일.  
`selectedWeekStart`는 항상 해당 주 일요일 00:00:00.

---

## 날짜 선택기 표시

- 월간 모드: `< 4월 >`
- 주간 모드: `< 4/6(일) ~ 4/12(토) >`  
  (같은 해일 때 연도 생략, 다른 해면 `2025/12/29 ~ 2026/1/4` 형식)

---

## 아키텍처 — 데이터 레이어

### 신규 엔티티

```dart
// lib/features/stats/domain/entities/daily_stat.dart
@freezed
sealed class DailyStat with _$DailyStat {
  const factory DailyStat({
    required DateTime date,    // 해당 날짜 00:00:00
    required int amount,       // 당일 총 지출 (원)
  }) = _DailyStat;
}
```

### StatsLocalDatasource 변경

**추가 메서드:**

```dart
// 일~토 7일의 일별 지출 반환 (지출 없는 날은 amount=0으로 채움)
Future<List<DailyStat>> getDailyAmountsForWeek(DateTime weekStart)

// 날짜 범위 기반 카테고리 통계 (주간 최다 카테고리용)
Future<List<CategoryStat>> getCategoryStatsForRange(DateTime from, DateTime to)
```

**리팩토링:**  
기존 `getCategoryStats(year, month)`는 `getCategoryStatsForRange`를 내부 호출하도록 변경.

---

## 아키텍처 — 상태 & ViewModel

### StatsViewMode

```dart
enum StatsViewMode { monthly, weekly }
```

### StatsState 변경

기존 필드 유지, 아래 추가:

```dart
// 공통
final StatsViewMode viewMode;         // 기본값: monthly
final DateTime selectedWeekStart;     // 이번 주 일요일

// 주간 전용
final List<DailyStat> dailyStats;     // 7일 bar chart용
final int weeklyTotalSpent;
final int weeklyBudget;               // 7 × dailyBudget
final int weeklySuccessDays;
final int weeklyTotalDays;
final int? weeklyTopCategoryIndex;    // null = 지출 없음
final int? prevWeekTotalSpent;        // null = 전주 데이터 없음
```

### StatsViewModel 변경

| 메서드 | 설명 |
|---|---|
| `build()` | 현재 월 + 이번 주 데이터 **동시 fetch** |
| `toggleViewMode()` | 모드 전환 — 재fetch 없음 (데이터 이미 있음) |
| `changeMonth(delta)` | 기존 유지 |
| `changeWeek(delta)` | 선택 주 이동 + 해당 주 데이터 fetch |
| `_fetchStats(month, weekStart)` | 월간 + 주간 동시 로드, `Future.wait` 사용 |

`toggleViewMode()`에서 재fetch가 불필요한 이유: 초기 로드와 주/월 변경 시 항상 두 모드 데이터를 함께 가져오기 때문.

---

## 아키텍처 — UI

### 상단 컨트롤

```
[< 4월 >  or  < 4/6(일) ~ 4/12(토) >]     [월간 | 주간]
```

토글은 기존 월 선택기 행 우측에 배치.

### 주간 콘텐츠 레이아웃 (스크롤)

```
─ WeeklyDailyBarChart ────────────────────
  일  월  화  수  목  금  토
  ▌  ▌▌  ▌  ▌▌  ▌  ▌  ▌
  (예산선 점선 — dailyBudget 기준)

─ WeeklyStatsSummaryRow ──────────────────
  [총 지출]    [성공일]    [일평균]
  45,200원     4/5일      9,040원

─ WeeklyInsightRow ───────────────────────
  ↓ 전주보다 3,200원 적게 씀
  🍚 최다 지출: 식비
  (prevWeekTotalSpent == null 이면 전주 비교 미표시)
```

### 신규 위젯

| 위젯 | 파일 | 역할 |
|---|---|---|
| `StatsViewModeToggle` | `widgets/stats_view_mode_toggle.dart` | 월간/주간 전환 버튼 |
| `WeeklyDailyBarChart` | `widgets/weekly_daily_bar_chart.dart` | 7일 bar + 예산선 |
| `WeeklyStatsSummaryRow` | `widgets/weekly_stats_summary_row.dart` | 총지출·성공일·일평균 카드 |
| `WeeklyInsightRow` | `widgets/weekly_insight_row.dart` | 전주 비교 + 최다 카테고리 |

월간 콘텐츠(`CategoryDonutChart`, `WeekdayBarChart`, 요약 버튼)는 변경 없음.

---

## 에러 처리

- `getDailyAmountsForWeek` 결과가 없는 날은 `amount=0`으로 채워 항상 7개 반환
- `prevWeekTotalSpent == null` → 전주 비교 행 미표시
- `weeklyTopCategoryIndex == null` → 최다 카테고리 행 미표시
- 오류 상태는 기존 `AsyncValue.when(error:)` 처리 그대로

---

## 테스트 기준

1. `getDailyAmountsForWeek`이 항상 7개 `DailyStat`을 반환한다 (지출 없는 날 포함)
2. `getCategoryStatsForRange`가 날짜 범위 내 지출만 집계한다
3. 토글 시 `StatsViewMode`가 전환되고 UI가 올바른 콘텐츠를 표시한다
4. 이전 주 이동 시 `selectedWeekStart`가 7일 이전으로 변경된다
5. `prevWeekTotalSpent == null`이면 전주 비교 행이 표시되지 않는다
