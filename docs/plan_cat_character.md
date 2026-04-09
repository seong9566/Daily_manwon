# 낙서 고양이 캐릭터 통합 계획

> 하루 만원 앱에 손그림 낙서체 고양이 4종을 활용한 감성 UX 구현 계획

## 고양이 자산 현황

| 상태 | 조건 | 이미지 경로 |
|------|------|------------|
| 여유 | 잔액 > 70% | `assets/images/character/여유_clean.png` |
| 보통 | 잔액 30~70% | `assets/images/character/보통_clean.png` |
| 위험 | 잔액 0~30% | `assets/images/character/위험_clean.png` |
| 초과 | 잔액 < 0 | `assets/images/character/초과_clean.png` |

모든 이미지: RGBA 투명 PNG, 배경 제거 완료

---

## Plan 1. 홈 화면 실시간 고양이 인디케이터

### 개요
홈 화면 상단에 고양이 이미지를 배치하여 예산 잔액 비율에 따라 실시간으로 고양이 상태가 전환됨. 숫자보다 감정으로 먼저 인식.

### 목표
- 앱 진입 즉시 오늘의 예산 상태를 감각적으로 파악
- 지출 기록 후 고양이 상태 변화를 통한 행동 피드백 제공

### 구현 범위

```
lib/features/home/presentation/
├── widgets/
│   └── budget_cat_indicator.dart   # 고양이 상태 위젯
└── screens/
    └── home_screen.dart            # 기존 화면에 위젯 삽입
```

**BudgetCatIndicator 로직**
```dart
CharacterMood _moodFromRatio(double ratio) {
  if (ratio > 0.7) return CharacterMood.comfortable;
  if (ratio > 0.3) return CharacterMood.normal;
  if (ratio >= 0.0) return CharacterMood.danger;
  return CharacterMood.over;
}
```

**상태 전환 애니메이션**
- `AnimatedSwitcher` + `FadeTransition` (duration: 400ms)
- 이미지 크기: 120×120dp 기준 (홈 카드 내 배치)

### 완료 조건
- [ ] `CharacterMood` enum이 `core/constants/`에 정의됨
- [ ] 고양이 이미지가 `pubspec.yaml` assets에 등록됨
- [ ] 잔액 비율 변경 시 고양이 자동 전환
- [ ] Light / Dark 테마 모두 대응 (투명 PNG이므로 별도 처리 불필요)

### 예상 공수
- 0.5일 (이미지 자산 완성, 로직 단순)

---

## Plan 2. iOS / Android 홈 위젯

### 개요
앱을 열지 않아도 홈화면·잠금화면에서 고양이 상태 확인 가능. `home_widget` 패키지 활용.

### 목표
- 앱 차별화 포인트 (타 가계부 앱 대비 감성 위젯)
- 잠금화면 고양이만으로도 오늘 예산 의식 유도

### 구현 범위

**패키지 추가**
```yaml
dependencies:
  home_widget: ^0.7.0
```

**Flutter 측 데이터 전송**
```dart
// 지출 저장 후 위젯 갱신
await HomeWidget.saveWidgetData<String>('cat_mood', mood.name);
await HomeWidget.updateWidget(
  androidName: 'BudgetCatWidget',
  iOSName: 'BudgetCatWidget',
);
```

**플랫폼별 구현**

| 플랫폼 | 파일 위치 | 구현 방식 |
|--------|----------|----------|
| Android | `android/app/src/main/res/layout/budget_cat_widget.xml` | AppWidgetProvider |
| iOS | `ios/BudgetCatWidget/` | WidgetKit (Swift, Timeline Provider) |

**위젯 크기 지원**
- Small (2×2): 고양이 이미지 + 감정 텍스트 (여유/보통/위험/초과)
- Medium (4×2): 고양이 + 잔액 금액 + 날짜

**오프라인 캐싱**: 마지막 상태를 SharedPreferences에 저장 → 앱 미실행 중에도 위젯 표시

### 완료 조건
- [ ] Android 위젯 홈화면 추가 및 상태 반영 확인
- [ ] iOS 위젯 (WidgetKit) 잠금화면 / 홈화면 동작 확인
- [ ] 앱 내 지출 기록 → 위젯 5초 내 갱신
- [ ] 위젯 탭 시 앱 홈화면으로 딥링크

### 예상 공수
- 2~3일 (플랫폼 네이티브 코드 포함)

---

## Plan 3. 캘린더 감정 스탬프

### 개요
월별 캘린더 각 날짜 셀에 그날의 고양이 상태(mood)를 미니 아이콘으로 표시. 한 달이 지나면 나만의 감정 달력 완성.

### 목표
- 장기 리텐션: 달력이 채워지는 재미 → 앱 지속 사용 동기
- 소비 패턴을 감정 스탬프로 시각적으로 파악

### 구현 범위

**DB 변경** (`core/database/`)
```dart
// DailyBudgets 테이블에 mood 컬럼 추가
TextColumn get mood => text().nullable()();
```

**mood 산출 로직** (`core/utils/budget_mood_calculator.dart`)
```dart
CharacterMood calculateMood(int budget, int spent) {
  final ratio = (budget - spent) / budget;
  if (ratio > 0.7) return CharacterMood.comfortable;
  if (ratio > 0.3) return CharacterMood.normal;
  if (ratio >= 0.0) return CharacterMood.danger;
  return CharacterMood.over;
}
```

**캘린더 셀 위젯** (`features/calendar/presentation/widgets/`)
```
calendar_day_cell.dart   # 기존 셀에 고양이 미니 이미지 오버레이 추가
```

- 미니 고양이 크기: 20×20dp (날짜 숫자 하단)
- 당일 이전 날짜에만 표시 (미래는 빈 상태)
- 지출 없는 날(무지출)은 여유 고양이 + 특별 표시 ★

### 완료 조건
- [ ] `DailyBudgets` 테이블 마이그레이션 완료 (schemaVersion 증가)
- [ ] 하루 마감 시 mood 자동 저장 (자정 또는 다음날 첫 진입 시)
- [ ] 캘린더 셀에 미니 고양이 아이콘 표시
- [ ] 월간 뷰 + 주간 뷰 모두 대응

### 예상 공수
- 1~1.5일

---

## Plan 4. 지출 입력 마이크로 애니메이션

### 개요
지출 저장 완료 순간, 고양이가 짧게 반응하는 마이크로 애니메이션 재생. 기록 행위에 즉각적 보상감 부여.

### 목표
- 지출 기록 습관 형성 (행동 → 즉각 피드백 → 강화)
- 앱 사용의 즐거움 증대

### 상태별 애니메이션 정의

| 고양이 상태 | 저장 후 반응 | 연출 |
|-----------|------------|------|
| 여유 | 느긋하게 기지개 | scale 1.0 → 1.1 → 1.0 (bounce) |
| 보통 | 고개 끄덕 | translateY 0 → -8 → 0 |
| 위험 | 귀 쫑긋 (긴장) | shake (±4px horizontal) |
| 초과 | 발 동동 (스트레스) | rapid shake + red tint overlay |

### 구현

```dart
// flutter_animate 활용
BudgetCatIndicator(mood: currentMood)
  .animate(key: ValueKey(lastExpenseId))  // 새 지출마다 트리거
    .fadeIn(duration: 200.ms)
    .scale(begin: Offset(0.9, 0.9), curve: Curves.elasticOut)
```

**트리거 조건**: 지출 저장 성공 시 `lastExpenseId` 변경 → `AnimationController` 재실행

**지속 시간**: 최대 600ms (사용자 흐름 방해 최소화)

### 완료 조건
- [ ] 지출 저장 → 홈 화면 고양이 애니메이션 재생 확인
- [ ] 상태 전환 시 (여유→위험 등) 이미지 교체 + 애니메이션 동시 동작
- [ ] 애니메이션 설정에서 끄기 옵션 (접근성 고려, `reduce motion` 대응)

### 예상 공수
- 0.5일

---

## Plan 5. 월별 감정 무드 리포트

### 개요
매월 말, 그달의 고양이 상태 분포를 시각적으로 리포트. "이번 달 당신의 고양이는 주로 어땠나요?" → 소비 습관 인식 + 공유 콘텐츠.

### 목표
- 장기 사용자 리텐션 (월말 리포트 기대감)
- SNS 공유를 통한 바이럴 획득

### 화면 구성

```
┌─────────────────────────────┐
│  🐱 4월의 나의 고양이         │
│                              │
│  여유 ████████░░  12일 (40%) │
│  보통 ██████░░░░   9일 (30%) │
│  위험 ████░░░░░░   6일 (20%) │
│  초과 ██░░░░░░░░   3일 (10%) │
│                              │
│  "이번 달은 꽤 여유로웠어요!" │
│         [공유하기]            │
└─────────────────────────────┘
```

### 구현 범위

**데이터 집계** (`features/report/domain/usecases/`)
```dart
class GetMonthlyMoodReport {
  Future<MoodReport> execute(int year, int month);
  // DailyBudgets 테이블에서 해당 월 mood 집계
}
```

**공유 카드 생성** (`features/report/presentation/`)
- `RepaintBoundary` + `RenderRepaintBoundary.toImage()` → PNG 저장
- `share_plus` 패키지로 공유

**자동 진입 트리거**
- 월 마지막 날 앱 진입 시 바텀시트로 리포트 미리보기
- 또는 캘린더 화면 상단 "4월 리포트 보기" 버튼

**코멘트 문구 (mood 분포별)**
```dart
String generateComment(MoodReport report) {
  if (report.comfortableRatio > 0.5) return "이번 달은 꽤 여유로웠어요! 🐱";
  if (report.overRatio > 0.3) return "이번 달은 조금 힘들었죠... 다음 달엔 같이 힘내봐요!";
  return "균형 잡힌 한 달이었어요. 잘 하고 있어요!";
}
```

### 완료 조건
- [ ] Plan 3 (캘린더 스탬프) 완료 후 mood 데이터 충분히 누적된 상태에서 진행
- [ ] 월별 mood 분포 집계 및 화면 표시
- [ ] 리포트 카드 이미지 저장 / 공유 기능
- [ ] 월말 자동 노출 트리거

### 예상 공수
- 1.5~2일 (Plan 3 완료 전제)

---

## 구현 순서 (권장)

```
Week 1
├── Plan 1: 홈 화면 고양이 인디케이터    (0.5일)  ← 즉시 시작 가능
└── Plan 4: 지출 입력 마이크로 애니메이션 (0.5일)

Week 2
└── Plan 3: 캘린더 감정 스탬프           (1.5일)

Week 3~4
└── Plan 2: 홈 위젯 (iOS + Android)     (2~3일)

데이터 누적 후 (1개월+)
└── Plan 5: 월별 감정 무드 리포트        (1.5~2일)
```

## 공통 전제 조건

- [ ] `pubspec.yaml`에 모든 고양이 이미지 assets 등록
- [ ] `CharacterMood` enum 정의 (`core/constants/character_mood.dart`)
- [ ] `flutter_animate` 패키지 의존성 확인
- [ ] 모든 이미지: RGBA 투명 PNG (완료)
