# Handoff: iOS 홈 위젯 로직 연동

**작성일**: 2026-04-01  
**담당**: stecdev  
**상태**: UI 완료 → 로직 연동 필요

---

## 현재 완료된 것 (UI)

| 위젯 사이즈 | 뷰 | 내용 |
|------------|-----|------|
| Small (2×2) | `DailyHomeSmallView` | 남은 예산 + 스트릭 배지 + 프로그레스 바 + 상태 메시지 |
| Medium (4×2) | `DailyHomeMediumView` | 총 예산/스트릭 헤더 + 남은예산/사용예산 좌우 분할 + 프로그레스 바 |
| Large (4×4) | `DailyHomeLargeView` | Medium + 오늘의 지출 목록 (최대 4건 + "외 N건") |

**파일 위치**: `ios/DailyHomeWidget/DailyHomeWidget.swift`

### 위젯이 읽는 데이터 구조

```swift
// UserDefaults suiteName
"group.dailyManWon.dailyHomeWidget"

// Keys
"totalKey"     → Int    // 하루 예산 (10000)
"usedKey"      → Int    // 오늘 사용 금액
"remainingKey" → Int    // 남은 금액 (음수 가능)
"streakKey"    → Int    // 연속 성공 일수
"expensesKey"  → String // JSON 배열 (아래 구조)
```

```json
// expensesKey JSON 형식
[
  { "category": "점심", "time": "12:30", "amount": 3500 },
  { "category": "카페", "time": "15:15", "amount": 1300 }
]
```

---

## 남은 작업

### 1. Xcode App Group 설정 (필수 선행 조건)

Xcode에서 두 타깃 모두 App Group을 활성화해야 Flutter ↔ Widget 간 UserDefaults 공유가 됩니다.

**설정 방법 (Xcode GUI)**:
1. `Runner` 타깃 선택 → `Signing & Capabilities` → `+ Capability` → `App Groups`
   - App Group ID: `group.dailyManWon.dailyHomeWidget`
2. `DailyHomeWidgetExtension` 타깃 선택 → 동일하게 App Group 추가
   - 같은 ID: `group.dailyManWon.dailyHomeWidget`

> ⚠️ 코드에서 이미 `suiteName: "group.dailyManWon.dailyHomeWidget"` 으로 읽고 있으므로 ID가 반드시 일치해야 함.

---

### 2. Flutter → UserDefaults 쓰기 (Dart 코드)

Flutter에서 지출/잔액 변경 시 위젯용 UserDefaults에 데이터를 저장해야 합니다.

**추가할 패키지**:
```yaml
# pubspec.yaml
home_widget: ^0.6.0   # 또는 shared_preferences + platform channel
```

**구현 위치**: `lib/features/home/presentation/viewmodels/home_view_model.dart`  
지출 저장/삭제/로드 후 아래 메서드를 호출합니다.

**Dart 구현 예시** (`lib/core/services/widget_service.dart` 신규 생성):

```dart
import 'package:home_widget/home_widget.dart';

@lazySingleton
class WidgetService {
  static const _appGroupId = 'group.dailyManWon.dailyHomeWidget';

  Future<void> updateWidget({
    required int total,
    required int used,
    required int remaining,
    required int streak,
    required List<Map<String, dynamic>> expenses,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);  // iOS only
    await HomeWidget.saveWidgetData('totalKey', total);
    await HomeWidget.saveWidgetData('usedKey', used);
    await HomeWidget.saveWidgetData('remainingKey', remaining);
    await HomeWidget.saveWidgetData('streakKey', streak);

    final expensesJson = jsonEncode(expenses);
    await HomeWidget.saveWidgetData('expensesKey', expensesJson);

    // 위젯 강제 새로고침
    await HomeWidget.updateWidget(
      iOSName: 'DailyHomeWidget',
      androidName: 'DailyHomeWidget',   // Android 위젯 추가 시 사용
    );
  }
}
```

**HomeViewModel에서 호출 위치**:
```dart
// _loadData() 완료 후
// deleteExpense() 완료 후
// DayChangeService 날짜 변경 후 정산 완료 후

await _widgetService.updateWidget(
  total: state.totalBudget,
  used: state.usedAmount,
  remaining: state.remainingAmount,
  streak: state.streakDays,
  expenses: state.todayExpenses.map((e) => {
    'category': e.categoryName,
    'time': DateFormat('HH:mm').format(e.createdAt),
    'amount': e.amount,
  }).toList(),
);
```

---

### 3. Xcode 빌드 사이클 수정 (이미 Podfile 수정됨)

`ios/Podfile` 에 아래가 이미 추가되어 있습니다:
- `DailyHomeWidgetExtension` 타깃 등록
- `post_install` 에서 `[CP] Embed Pods Frameworks` ↔ `DailyHomeWidgetExtension` 순환 의존성 해결 스크립트

**아직 실행 필요**:
```bash
cd ios && pod install
```

---

### 4. WidgetKit 타임라인 갱신 주기 검토

현재 코드: `policy: .atEnd` (데이터 소진 후 자동 갱신)

권장 변경:
```swift
// getTimeline 내부
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
```

또는 Flutter에서 `HomeWidget.updateWidget()` 호출 시 즉시 갱신되므로 `.atEnd` 유지해도 무방.

---

## 작업 순서 (권장)

```
1. Xcode App Group 설정 (Runner + DailyHomeWidgetExtension)
2. cd ios && pod install
3. flutter pub add home_widget
4. dart run build_runner build --delete-conflicting-outputs
5. lib/core/services/widget_service.dart 구현
6. lib/core/di/injection.dart 에 WidgetService 등록
7. HomeViewModel에 WidgetService 주입 + updateWidget() 호출 추가
8. 실기기에서 위젯 추가 후 데이터 반영 확인
```

---

## 주요 파일 경로

| 파일 | 역할 |
|------|------|
| `ios/DailyHomeWidget/DailyHomeWidget.swift` | 위젯 UI (Small/Medium/Large) + 데이터 읽기 |
| `ios/DailyHomeWidget/Info.plist` | App Group ID 확인 필요 |
| `ios/Podfile` | DailyHomeWidgetExtension 타깃 등록 완료 |
| `lib/core/services/widget_service.dart` | **신규 생성 필요** — Flutter → UserDefaults 쓰기 |
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | WidgetService 호출 위치 |

---

## 참고: 상태별 색상 (이미 Swift에 정의됨)

| 상태 | 조건 | 배경 | 텍스트 |
|------|------|------|--------|
| 여유 (comfortable) | remaining ≥ 5,000 | `#F1F5F9` (연회색) | `#0F172A` (진한 남색) |
| 빠듯 (tight) | 0 ~ 4,999 | `#FEF3C7` (연노랑) | `#78350F` (갈색) |
| 초과 (exceeded) | < 0 | `#FEE2E2` (연빨강) | `#B91C1C` (빨강) |
