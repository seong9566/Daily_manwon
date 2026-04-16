# Widget "+" Add Expense Button (Large) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Large 홈 위젯에 "+" 버튼을 추가하여 탭 시 앱이 열리고 `showExpenseAddBottomSheet`가 자동으로 표시되도록 한다.

**Architecture:**  
`OpenAddExpenseIntent` (`openAppWhenRun: true`)가 UserDefaults App Group에 `widget.pendingAction = "open_add_expense"` 플래그를 기록한다. 앱이 포어그라운드로 전환되면 `HomeScreen`이 플래그를 확인하고 `showExpenseAddBottomSheet`를 호출한다. 즐겨찾기 존재 여부와 관계없이 "빠른 입력" 헤더 우측에 항상 "+" 버튼이 표시된다.

**Widget Sync 보장:** 지출 추가/삭제/수정은 `HomeViewModel._watchExpenses()` 스트림이 DB 변경을 감지하여 `WidgetService.updateWidget()`을 자동 호출한다. dedupedFrequent 재계산도 스트림 콜백 내에서 매번 실행되므로 별도 코드 없이 동기화된다.

**Tech Stack:** SwiftUI WidgetKit, AppIntents (iOS 17+), home_widget Flutter plugin, Riverpod Notifier

**알려진 제한사항 (Known Limitation):**  
앱이 이미 포어그라운드(active 상태)일 때 위젯 "+" 버튼을 탭하면 `AppLifecycleState.resumed`가 발생하지 않아 bottom sheet가 자동으로 열리지 않는다. iOS에서 `openAppWhenRun: true`는 앱을 포어그라운드로 전환하지만, 이미 active 상태라면 라이프사이클 전이가 없다. 현재 사용 패턴상 발생 빈도가 낮고 홈 화면 FAB로 대체 가능하므로 이번 구현에서는 처리하지 않는다.

---

## File Map

| 파일 | 변경 |
|------|------|
| `ios/DailyHomeWidget/WidgetConstants.swift` | `pendingActionKey` 상수 추가 |
| `ios/DailyHomeWidget/Intents/OpenAddExpenseIntent.swift` | **신규** — 앱 열기 Intent |
| `ios/DailyHomeWidget/Views/LargeWidgetView.swift` | "빠른 입력" 헤더에 "+" 버튼 추가 |
| `lib/core/services/widget_service.dart` | `checkAndClearPendingOpenExpense()` 추가 |
| `lib/features/home/presentation/viewmodels/home_view_model.dart` | `checkPendingOpenExpense()` 추가 |
| `lib/features/home/presentation/screens/home_screen.dart` | `initState` + `didChangeAppLifecycleState`에서 pending action 처리 |

---

## Task 1: iOS — WidgetConstants + OpenAddExpenseIntent

**Files:**
- Modify: `ios/DailyHomeWidget/WidgetConstants.swift`
- Create: `ios/DailyHomeWidget/Intents/OpenAddExpenseIntent.swift`

> **iOS 17 배포 타겟 확인:** `OpenAddExpenseIntent`는 `@available(iOS 17.0, *)` 어노테이션을 사용한다. 기존 `AddFavoriteExpenseIntent`와 동일한 패턴으로, 위젯 익스텐션의 Minimum Deployment Target이 iOS 17.0인지 Xcode → DailyHomeWidget target → General → Minimum Deployments에서 확인 후 진행한다.

- [ ] **Step 1: `pendingActionKey` 상수 추가**

`ios/DailyHomeWidget/WidgetConstants.swift` 를 다음으로 교체:

```swift
import Foundation

/// DailyHomeWidget 확장 내 공유 상수
enum WidgetConstants {
    static let appGroup = "group.seong.dailyManwon.homeWidget"
    static let pendingExpenseKey = "widget.pendingExpenseUrl"
    static let pendingActionKey  = "widget.pendingAction"
}
```

- [ ] **Step 2: `OpenAddExpenseIntent.swift` 생성**

```swift
//
//  OpenAddExpenseIntent.swift
//  DailyHomeWidget
//

import AppIntents
import WidgetKit

/// 위젯 "+" 버튼 탭 시 앱을 열고 지출 입력 화면을 트리거하는 AppIntent.
/// openAppWhenRun = true → 앱이 포어그라운드로 전환된다.
/// UserDefaults(App Group)에 pendingAction 플래그를 기록하고,
/// 앱이 활성화되면 HomeScreen이 showExpenseAddBottomSheet를 호출한다.
@available(iOS 17.0, *)
struct OpenAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "지출 직접 입력"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroup)
        defaults?.set("open_add_expense", forKey: WidgetConstants.pendingActionKey)
        defaults?.synchronize()
        return .result()
    }
}
```

- [ ] **Step 3: Xcode에서 빌드 확인 (컴파일 에러 없어야 함)**

```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 커밋**

```bash
git add ios/DailyHomeWidget/WidgetConstants.swift \
        ios/DailyHomeWidget/Intents/OpenAddExpenseIntent.swift
git commit -m "feat(widget): OpenAddExpenseIntent 추가 — 위젯 직접 입력 진입점"
```

---

## Task 2: iOS — LargeWidgetView "+" 버튼 UI

**Files:**
- Modify: `ios/DailyHomeWidget/Views/LargeWidgetView.swift:114-172`

- [ ] **Step 1: "빠른 입력" 섹션 재구성**

`LargeWidgetView.swift`의 `// ── 즐겨찾기 빠른 입력 ───` 블록 (lines 114-172) 을 아래로 교체:

```swift
            // ── 빠른 입력 헤더 + "+" 버튼 (항상 표시) ─────────────────
            Spacer().frame(height: 12)

            HStack {
                Text("빠른 입력")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                Spacer()
                Button(intent: OpenAddExpenseIntent()) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                }
                .buttonStyle(.plain)
            }

            Spacer().frame(height: 8)

            if !entry.favorites.isEmpty {
                // 즐겨찾기 버튼 — 최대 4개, 2×2 그리드
                let displayFavs = Array(entry.favorites.prefix(4))
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                    ],
                    spacing: 8
                ) {
                    ForEach(displayFavs) { fav in
                        Button(intent: AddFavoriteExpenseIntent(
                            favoriteId: fav.id,
                            amount: fav.amount,
                            category: fav.category,
                            memo: fav.memo
                        )) {
                            VStack(spacing: 4) {
                                Image(fav.categoryAssetName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .foregroundColor(.black)
                                    .frame(width: 22, height: 22)
                                Text(fav.formattedAmount)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colors.accentBg)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                // 즐겨찾기 없을 때 안내 메시지
                HStack {
                    Spacer()
                    Text("즐겨찾기를 추가하면 빠르게 기록할 수 있어요")
                        .font(.system(size: 11))
                        .foregroundColor(colors.secondaryText.opacity(0.6))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }

            Spacer()
```

- [ ] **Step 2: Xcode 빌드 + Preview 확인**

```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -5
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: 커밋**

```bash
git add ios/DailyHomeWidget/Views/LargeWidgetView.swift
git commit -m "feat(widget): large 위젯 빠른 입력 헤더에 '+' 버튼 추가"
```

---

## Task 3: Flutter — WidgetService `checkAndClearPendingOpenExpense`

**Files:**
- Modify: `lib/core/services/widget_service.dart`

> **로깅 참고:** 프로젝트에 `logger` 패키지가 없고 기존 `WidgetService` 전체가 `debugPrint`를 사용한다. 신규 메서드도 일관성을 위해 `debugPrint`를 사용한다. Logger 도입은 별도 project-wide 작업으로 처리한다.

> **플래그 초기화 방식:** 확인 후 `''`(빈 문자열)로 덮어써 sentinel을 클리어한다. `HomeWidget.getWidgetData<String>` 은 키가 없으면 `null`을, 값이 `''`이면 `''`을 반환한다. 조건 `action == 'open_add_expense'`가 `''`를 차단하므로 기능적으로 안전하다.

> **Race Condition 없음:** `WidgetService.init()`은 `main.dart` line 39에서 `runApp` 이전에 `await`로 완료된다. `HomeScreen.initState()`가 실행될 때 이미 `_appGroupAvailable = true`가 보장된다.

- [ ] **Step 1: 테스트 파일 존재 여부 확인**

```bash
ls test/core/services/widget_service_test.dart 2>/dev/null || echo "없음"
```

위젯 서비스는 플랫폼 채널 의존이 커 단위 테스트 환경에서 HomeWidget 플러그인을 모킹하기 어려우므로 테스트는 통합 시나리오 (Task 5 수동 확인)로 대체한다.

- [ ] **Step 2: `checkAndClearPendingOpenExpense` 추가**

`lib/core/services/widget_service.dart` 의 `processPendingWidgetExpense` 메서드 **바로 뒤** (line 104 이후, `updateWidget` 전) 에 삽입:

```dart
  /// 위젯 "직접 입력(+)" 버튼 탭 여부를 확인하고 플래그를 초기화한다.
  ///
  /// `true` 반환 시 caller(HomeScreen)에서 showExpenseAddBottomSheet를 호출해야 한다.
  /// 플래그는 ''(빈 문자열)로 덮어써 초기화한다 — null과 ''를 모두 차단하는
  /// `action == 'open_add_expense'` 조건으로 중복 트리거를 방지한다.
  Future<bool> checkAndClearPendingOpenExpense() async {
    if (!_appGroupAvailable) return false;
    try {
      final action = await HomeWidget.getWidgetData<String>('widget.pendingAction');
      if (action == 'open_add_expense') {
        await HomeWidget.saveWidgetData<String>('widget.pendingAction', '');
        debugPrint('WidgetService: pending open_add_expense 감지 → 플래그 초기화');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('WidgetService: pending action 확인 실패 — $e');
      return false;
    }
  }
```

- [ ] **Step 3: Flutter analyze**

```bash
flutter analyze lib/core/services/widget_service.dart
```

Expected: `No issues found!`

- [ ] **Step 4: 커밋**

```bash
git add lib/core/services/widget_service.dart
git commit -m "feat(widget-service): '+' 버튼 탭 감지용 checkAndClearPendingOpenExpense 추가"
```

---

## Task 4: Flutter — HomeViewModel `checkPendingOpenExpense`

**Files:**
- Modify: `lib/features/home/presentation/viewmodels/home_view_model.dart`

- [ ] **Step 1: `checkPendingOpenExpense` 추가**

`home_view_model.dart` 의 `processPendingWidgetExpense` 메서드 (line 374) **바로 뒤** 에 추가:

```dart
  /// 위젯 "직접 입력(+)" 버튼 탭 여부를 확인하고 플래그를 초기화한다.
  ///
  /// HomeScreen의 initState 및 AppLifecycleState.resumed 콜백에서 호출한다.
  /// true 반환 시 HomeScreen에서 showExpenseAddBottomSheet를 호출해야 한다.
  ///
  /// 이 메서드는 도메인 로직이 없는 아키텍처 경계 위임자다.
  /// Screen → Service 직접 호출을 차단하기 위해 존재한다.
  Future<bool> checkPendingOpenExpense() async {
    return getIt<WidgetService>().checkAndClearPendingOpenExpense();
  }
```

- [ ] **Step 2: Flutter analyze**

```bash
flutter analyze lib/features/home/presentation/viewmodels/home_view_model.dart
```

Expected: `No issues found!`

- [ ] **Step 3: 커밋**

```bash
git add lib/features/home/presentation/viewmodels/home_view_model.dart
git commit -m "feat(home-vm): checkPendingOpenExpense 위임 메서드 추가"
```

---

## Task 5: Flutter — HomeScreen pending action 처리

**Files:**
- Modify: `lib/features/home/presentation/screens/home_screen.dart`

- [ ] **Step 1: `_checkAndOpenAddExpense` 메서드 추가**

`_HomeScreenState` 의 `_subscribeNotificationNavigation` 메서드 **바로 뒤** 에 추가:

```dart
  /// 위젯 "+" 버튼 탭으로 앱이 열린 경우 지출 입력 화면을 표시한다.
  ///
  /// initState(addPostFrameCallback) 및 AppLifecycleState.resumed 에서 호출한다.
  /// 앱이 이미 포어그라운드(active)일 때 탭 → resumed가 발생하지 않는 Known Limitation이 있다.
  Future<void> _checkAndOpenAddExpense() async {
    final shouldOpen = await ref
        .read(homeViewModelProvider.notifier)
        .checkPendingOpenExpense();
    if (shouldOpen && mounted) {
      showExpenseAddBottomSheet(context);
    }
  }
```

- [ ] **Step 2: `initState` 에 포스트프레임 콜백 추가**

`initState` 의 `_subscribeNotificationNavigation();` 호출 **바로 뒤** 에 추가:

```dart
    // 위젯 "+" 버튼 탭 후 콜드 스타트 경로: 프레임 렌더 후 확인
    // WidgetService.init()은 main.dart에서 runApp 이전에 완료되므로
    // 이 시점에 _appGroupAvailable = true가 보장된다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndOpenAddExpense();
    });
```

- [ ] **Step 3: `didChangeAppLifecycleState` 에 추가**

기존 `didChangeAppLifecycleState` 의 `_handlePendingNotification();` 호출 **바로 뒤** 에 추가:

```dart
      // 위젯 "+" 버튼 탭 후 백그라운드 → 포어그라운드 경로
      _checkAndOpenAddExpense();
```

완성된 `didChangeAppLifecycleState`:

```dart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeViewModelProvider.notifier).checkDateChange();
      // 위젯 버튼 탭 후 pending 지출이 있으면 처리 (백그라운드 복귀 경로)
      ref.read(homeViewModelProvider.notifier).processPendingWidgetExpense();
      // Background에서 알림 탭으로 재개된 경우 pending payload 소비
      _handlePendingNotification();
      // 위젯 "+" 버튼 탭 후 앱 열기 경로
      _checkAndOpenAddExpense();
    }
  }
```

- [ ] **Step 4: Flutter analyze**

```bash
flutter analyze lib/features/home/presentation/screens/home_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 5: 커밋**

```bash
git add lib/features/home/presentation/screens/home_screen.dart
git commit -m "feat(home-screen): 위젯 '+' 버튼 탭 시 지출 입력 시트 자동 표시"
```

---

## Task 6: 수동 E2E 검증 + Widget Sync 확인

**검증 시나리오**

- [ ] **Step 1: 앱 빌드 및 시뮬레이터/실기기 실행**

```bash
flutter run
```

- [ ] **Step 2: Large 위젯 추가 확인**

홈 화면에서 Large 위젯을 추가하고 "빠른 입력" 헤더 우측에 `plus.circle.fill` 아이콘 버튼이 표시되는지 확인.

- [ ] **Step 3: 콜드 스타트 경로 검증**

1. 앱을 완전히 종료 (홈 화면으로 이동 후 최근 앱에서 스와이프)
2. 위젯에서 "+" 버튼 탭
3. 앱이 열리고 `showExpenseAddBottomSheet`가 자동으로 표시되는지 확인

- [ ] **Step 4: 백그라운드 복귀 경로 검증**

1. 앱을 백그라운드로 이동 (홈 버튼)
2. 위젯에서 "+" 버튼 탭
3. 앱이 포어그라운드로 전환되고 bottom sheet가 표시되는지 확인

- [ ] **Step 5: Widget Sync 검증 (add/delete)**

1. bottom sheet에서 지출 추가 → 위젯의 남은 예산 및 사용 금액이 갱신되는지 확인
2. 홈 리스트에서 지출 탭 → 삭제 → 위젯 수치가 복원되는지 확인

> Widget sync는 `HomeViewModel._watchExpenses()` 스트림이 DB 변경 시 자동으로 `WidgetService.updateWidget()`을 호출하므로 별도 코드 없이 동작한다. 갱신 미반영 시 `WidgetService.updateWidget()` 호출 경로를 `debugPrint`로 추적할 것.

- [ ] **Step 6: 즐겨찾기 없는 Large 위젯 확인**

즐겨찾기가 0개인 상태에서 "빠른 입력" 헤더 + "+" 버튼 + 안내 문구가 함께 표시되는지 확인.

- [ ] **Step 7: Known Limitation 확인**

앱이 이미 포어그라운드 상태에서 위젯 "+" 탭 시 bottom sheet가 열리지 않음을 확인하고 이슈로 기록한다 (이번 구현 범위 외).
