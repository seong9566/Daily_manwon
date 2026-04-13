# Large 위젯 즐겨찾기 버튼 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Large 위젯(4×4)의 지출 목록 섹션을 즐겨찾기 빠른 입력 버튼 4개로 교체하고, 버튼 탭 시 앱을 열지 않고 백그라운드에서 지출을 저장한다.

**Architecture:** Flutter WidgetService → App Group UserDefaults로 즐겨찾기 데이터 전달 → Swift `SimpleEntry`에 `FavoriteItem[]` 추가 → `LargeWidgetView` 버튼 렌더링. 버튼 탭 시 `AppIntent` → `HomeWidgetBackgroundWorker` → Flutter backgroundCallback → Drift DB 저장. **Plan A(Favorite Template)가 완료된 후 실행하는 것을 권장** (즐겨찾기 데이터 존재를 전제).

**Tech Stack:** home_widget 0.6.0, Swift WidgetKit + AppIntents (iOS 17+), Flutter backgroundCallback, App Group UserDefaults (`group.seong.dailyManwon.homeWidget`)

**전제:** `ios/DailyHomeWidget/` 구조 기존 존재. Cat PNG 4종 이미 Asset에 등록 (`CatComfortable/Normal/Danger/Over`). Large 위젯 뷰(`DailyHomeLargeView`) 기존 존재 (지출 목록 표시 중 → 즐겨찾기 버튼으로 교체).

---

## 파일 맵

### iOS Swift — 신규 생성
```
ios/DailyHomeWidget/
├── Models/FavoriteItem.swift          # 위젯용 즐겨찾기 모델
└── Intents/AddFavoriteExpenseIntent.swift  # AppIntent (백그라운드 저장)
```

### iOS Swift — 수정
```
ios/DailyHomeWidget/
├── Models/SimpleEntry.swift           # favorites: [FavoriteItem] 필드 추가
├── Views/LargeWidgetView.swift        # 지출 목록 → 즐겨찾기 버튼으로 교체
└── DailyHomeWidget.swift              # StaticConfiguration → AppIntentConfiguration
```

### Flutter — 수정
```
lib/
├── core/services/widget_service.dart  # favorites 데이터 전달 파라미터 추가
├── features/home/presentation/viewmodels/home_view_model.dart  # favorites 전달
└── main.dart                          # backgroundCallback 등록
```

### Flutter — 신규 생성
```
lib/core/services/widget_background_callback.dart  # 백그라운드 저장 로직
```

---

## Task 1: FavoriteItem Swift 모델 + SimpleEntry 확장

**Files:**
- Create: `ios/DailyHomeWidget/Models/FavoriteItem.swift`
- Modify: `ios/DailyHomeWidget/Models/SimpleEntry.swift`

- [ ] **Step 1-1: FavoriteItem 모델 생성**

`ios/DailyHomeWidget/Models/FavoriteItem.swift`:

```swift
import Foundation

/// 위젯 즐겨찾기 빠른 입력 버튼 데이터 모델
struct FavoriteItem: Codable, Identifiable {
    let id: Int
    let amount: Int
    let category: Int   // ExpenseCategory enum index (0=식비,1=교통,2=카페,3=쇼핑,4=기타)
    let memo: String

    /// 카테고리 index → 이모지
    var emoji: String {
        switch category {
        case 0: return "🍱"
        case 1: return "🚌"
        case 2: return "☕"
        case 3: return "🛍️"
        default: return "💳"
        }
    }

    /// 금액 포맷 — 1만 이상이면 "1.2만", 미만이면 "3,500"
    var formattedAmount: String {
        if amount >= 10000 {
            let manwon = Double(amount) / 10000
            let truncated = manwon.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(manwon)) : String(format: "%.1f", manwon)
            return "\(truncated)만"
        }
        return formatNumber(amount)
    }
}
```

- [ ] **Step 1-2: SimpleEntry에 favorites 필드 추가**

`ios/DailyHomeWidget/Models/SimpleEntry.swift` 전체 교체:

```swift
import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let total: Int
    let used: Int
    let remaining: Int
    let streak: Int
    let expenses: [ExpenseItem]
    let catMood: String
    let favorites: [FavoriteItem]  // 추가 (최대 4개)

    var progressRatio: Double {
        guard total > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(remaining) / Double(total)))
    }
}
```

- [ ] **Step 1-3: DailyHomeWidget.swift의 placeholder/getSnapshot/getTimeline에 favorites 파싱 추가**

`DailyHomeWidget.swift` 의 `placeholder()` 수정:
```swift
func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(
        date: Date(), total: 10000, used: 0,
        remaining: 10000, streak: 0, expenses: [], catMood: "comfortable",
        favorites: []
    )
}
```

`getSnapshot()` 수정:
```swift
SimpleEntry(
    date: Date(), total: 10000, used: 2800,
    remaining: 7200, streak: 12,
    expenses: [...],
    catMood: "comfortable",
    favorites: [
        FavoriteItem(id: 1, amount: 3500, category: 2, memo: ""),
        FavoriteItem(id: 2, amount: 1500, category: 1, memo: ""),
    ]
)
```

`getTimeline()` 에 즐겨찾기 파싱 추가 (기존 expenses 파싱 아래):
```swift
var favorites: [FavoriteItem] = []
if let favJson = userDefault?.string(forKey: "favoritesKey"),
   let data = favJson.data(using: .utf8) {
    favorites = (try? JSONDecoder().decode([FavoriteItem].self, from: data)) ?? []
}

let entry = SimpleEntry(
    date: Date(),
    total: total, used: used, remaining: remaining, streak: streak,
    expenses: expenses, catMood: catMood,
    favorites: favorites
)
```

- [ ] **Step 1-4: Xcode 빌드 확인 (컴파일 에러 없음)**

Xcode 또는:
```bash
cd /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme DailyHomeWidget \
  -destination 'generic/platform=iOS Simulator' \
  build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: `Build succeeded`

- [ ] **Step 1-5: 커밋**

```bash
git add ios/DailyHomeWidget/Models/FavoriteItem.swift \
        ios/DailyHomeWidget/Models/SimpleEntry.swift \
        ios/DailyHomeWidget/DailyHomeWidget.swift
git commit -m "feat(widget): FavoriteItem 모델 추가 및 SimpleEntry에 favorites 필드 확장"
```

---

## Task 2: LargeWidgetView — 즐겨찾기 버튼으로 교체

**Files:**
- Modify: `ios/DailyHomeWidget/Views/LargeWidgetView.swift`

- [ ] **Step 2-1: LargeWidgetView 하단부 교체**

`ios/DailyHomeWidget/Views/LargeWidgetView.swift` 의 `Spacer().frame(height: 12)` 아래 전체 ("오늘의 지출" 헤더부터 끝까지)를 다음으로 교체:

```swift
// ── 즐겨찾기 빠른 입력 ───────────────────────────────
if !entry.favorites.isEmpty {
    Spacer().frame(height: 12)

    Text("빠른 입력")
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(colors.secondaryText)

    Spacer().frame(height: 8)

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
                    Text(fav.emoji)
                        .font(.system(size: 18))
                    Text(fav.formattedAmount)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(colors.primaryText)
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
    Spacer()
    HStack {
        Spacer()
        Text("앱에서 즐겨찾기를 추가해보세요")
            .font(.system(size: 12))
            .foregroundColor(colors.secondaryText.opacity(0.6))
        Spacer()
    }
}

Spacer()
```

- [ ] **Step 2-2: Xcode 빌드 확인**

```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme DailyHomeWidget \
  -destination 'generic/platform=iOS Simulator' \
  build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: `Build succeeded` (AppIntent 미정의로 에러 날 수 있음 — Task 3 후 재확인)

- [ ] **Step 2-3: 커밋**

```bash
git add ios/DailyHomeWidget/Views/LargeWidgetView.swift
git commit -m "feat(widget): Large 위젯 지출 목록 → 즐겨찾기 빠른 입력 버튼으로 교체"
```

---

## Task 3: AppIntent 구현 (백그라운드 저장)

**Files:**
- Create: `ios/DailyHomeWidget/Intents/AddFavoriteExpenseIntent.swift`
- Modify: `ios/DailyHomeWidget/DailyHomeWidget.swift`

- [ ] **Step 3-1: AddFavoriteExpenseIntent 생성**

먼저 디렉토리 생성:
```bash
mkdir -p /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon/ios/DailyHomeWidget/Intents
```

`ios/DailyHomeWidget/Intents/AddFavoriteExpenseIntent.swift`:

```swift
import AppIntents
import WidgetKit

/// 위젯 즐겨찾기 버튼 탭 시 호출되는 AppIntent
/// openAppWhenRun = false → 앱 포그라운드 전환 없이 백그라운드에서 실행
@available(iOS 17.0, *)
struct AddFavoriteExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "즐겨찾기 지출 추가"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "즐겨찾기 ID")
    var favoriteId: Int

    @Parameter(title: "금액")
    var amount: Int

    @Parameter(title: "카테고리")
    var category: Int

    @Parameter(title: "메모")
    var memo: String

    init() {
        self.favoriteId = 0
        self.amount = 0
        self.category = 0
        self.memo = ""
    }

    init(favoriteId: Int, amount: Int, category: Int, memo: String) {
        self.favoriteId = favoriteId
        self.amount = amount
        self.category = category
        self.memo = memo
    }

    func perform() async throws -> some IntentResult {
        // URL scheme으로 Flutter backgroundCallback에 데이터 전달
        // home_widget의 HomeWidgetBackgroundWorker를 통해 Dart 코드 실행
        let urlString = "addFavoriteExpense://add?amount=\(amount)&category=\(category)&favoriteId=\(favoriteId)&memo=\(memo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: urlString) {
            await HomeWidgetBackgroundWorker.run(
                url: url,
                appGroup: "group.seong.dailyManwon.homeWidget"
            )
        }

        // 위젯 타임라인 갱신
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
```

- [ ] **Step 3-2: home_widget의 HomeWidgetBackgroundWorker import 확인**

`ios/Podfile` 에서 home_widget 설치 여부 확인:
```bash
grep "home_widget" /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon/ios/Podfile
```

없으면 Flutter 패키지 재설치:
```bash
cd /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon
flutter pub get
```

- [ ] **Step 3-3: DailyHomeWidget.swift를 AppIntentConfiguration으로 전환**

`DailyHomeWidget.swift` 의 `StaticConfiguration` 블록 전체를 교체:

```swift
struct DailyHomeWidget: Widget {
    let kind: String = "DailyHomeWidget"

    var body: some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(
                kind: kind,
                intent: AddFavoriteExpenseIntent.self,
                provider: Provider()
            ) { entry in
                DailyHomeWidgetRouter(entry: entry)
            }
            .configurationDisplayName("하루 만원")
            .description("오늘의 잔여 예산을 확인하세요")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        } else {
            return StaticConfiguration(kind: kind, provider: Provider()) { entry in
                DailyHomeWidgetRouter(entry: entry)
            }
            .configurationDisplayName("하루 만원")
            .description("오늘의 잔여 예산을 확인하세요")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        }
    }
}
```

- [ ] **Step 3-4: Xcode 빌드 확인**

```bash
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme DailyHomeWidget \
  -destination 'generic/platform=iOS Simulator' \
  build 2>&1 | grep -E "error:|Build succeeded"
```
Expected: `Build succeeded`

- [ ] **Step 3-5: 커밋**

```bash
git add ios/DailyHomeWidget/Intents/AddFavoriteExpenseIntent.swift \
        ios/DailyHomeWidget/DailyHomeWidget.swift
git commit -m "feat(widget): AddFavoriteExpenseIntent AppIntent 추가 (백그라운드 저장)"
```

---

## Task 4: Flutter backgroundCallback 등록

**Files:**
- Create: `lib/core/services/widget_background_callback.dart`
- Modify: `lib/main.dart`

- [ ] **Step 4-1: backgroundCallback 함수 작성**

`lib/core/services/widget_background_callback.dart`:

```dart
import 'dart:async';

import 'package:home_widget/home_widget.dart';

import '../di/injection.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/domain/usecases/add_expense_use_case.dart';
import '../../features/expense/domain/usecases/increment_favorite_usage_use_case.dart';

/// 위젯 버튼 탭 시 앱 없이 백그라운드에서 실행되는 콜백
///
/// @pragma('vm:entry-point') 필수 — 릴리즈 빌드에서 tree shaking 방지
@pragma('vm:entry-point')
FutureOr<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.scheme != 'addFavoriteExpense') return;

  final amount = int.tryParse(uri.queryParameters['amount'] ?? '');
  final category = int.tryParse(uri.queryParameters['category'] ?? '');
  final favoriteId = int.tryParse(uri.queryParameters['favoriteId'] ?? '');

  if (amount == null || category == null) return;

  // DI 초기화 (백그라운드 isolate에서는 별도 초기화 필요)
  await configureDependencies();

  // 지출 저장
  await getIt<AddExpenseUseCase>().execute(
    ExpenseEntity(
      id: 0,
      amount: amount,
      category: category,
      createdAt: DateTime.now(),
    ),
  );

  // 즐겨찾기 사용 횟수 증가
  if (favoriteId != null && favoriteId > 0) {
    await getIt<IncrementFavoriteUsageUseCase>().execute(favoriteId);
  }
}
```

- [ ] **Step 4-2: main.dart에 backgroundCallback 등록**

`lib/main.dart` 에서 `HomeWidget.setAppGroupId` 또는 앱 초기화 부분을 찾아 추가:

```dart
import 'package:home_widget/home_widget.dart';
import 'core/services/widget_background_callback.dart';

// main() 함수 상단 또는 WidgetsFlutterBinding.ensureInitialized() 직후:
HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
```

- [ ] **Step 4-3: flutter analyze 실행**

```bash
cd /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon
flutter analyze lib/core/services/widget_background_callback.dart
```
Expected: No issues

- [ ] **Step 4-4: 커밋**

```bash
git add lib/core/services/widget_background_callback.dart lib/main.dart
git commit -m "feat(widget): Flutter widgetBackgroundCallback 등록 (백그라운드 지출 저장)"
```

---

## Task 5: WidgetService에 favorites 데이터 전달 추가

**Files:**
- Modify: `lib/core/services/widget_service.dart`
- Modify: `lib/features/home/presentation/viewmodels/home_view_model.dart`

- [ ] **Step 5-1: WidgetService.updateWidget에 favorites 파라미터 추가**

`lib/core/services/widget_service.dart` 의 `updateWidget` 시그니처 수정:

```dart
Future<void> updateWidget({
  required int total,
  required int used,
  required int remaining,
  required int streak,
  required List<Map<String, dynamic>> expenses,
  required String catMood,
  List<Map<String, dynamic>> favorites = const [],  // 추가
}) async {
  if (!_appGroupAvailable) {
    debugPrint('WidgetService: updateWidget 스킵 — App Group 미초기화');
    return;
  }
  try {
    await HomeWidget.saveWidgetData<int>('totalKey', total);
    await HomeWidget.saveWidgetData<int>('usedKey', used);
    await HomeWidget.saveWidgetData<int>('remainingKey', remaining);
    await HomeWidget.saveWidgetData<int>('streakKey', streak);
    await HomeWidget.saveWidgetData<String>('expensesKey', jsonEncode(expenses));
    await HomeWidget.saveWidgetData<String>('cat_mood', catMood);
    await HomeWidget.saveWidgetData<String>('favoritesKey', jsonEncode(favorites));  // 추가
    await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
  } catch (e) {
    debugPrint('WidgetService: 위젯 갱신 실패 — $e');
  }
}
```

- [ ] **Step 5-2: HomeViewModel에서 favorites 데이터 전달**

`lib/features/home/presentation/viewmodels/home_view_model.dart` 의 `_loadData()` 내 `updateWidget` 호출 부분에 favorites 추가:

```dart
// _loadData 내 기존 unawaited(getIt<WidgetService>().updateWidget(...)) 호출에 추가
final favoritesList = await getIt<GetFavoritesUseCase>().execute();

unawaited(getIt<WidgetService>().updateWidget(
  total: totalBudget,
  used: totalBudget - remaining,
  remaining: remaining,
  streak: streak,
  expenses: expenses
      .map((e) => {
            'category': ExpenseCategory.values[e.category].label,
            'time': DateFormat('HH:mm').format(e.createdAt),
            'amount': e.amount,
          })
      .toList(),
  catMood: catMood,
  favorites: favoritesList  // 추가
      .map((f) => {
            'id': f.id,
            'amount': f.amount,
            'category': f.category,
            'memo': f.memo,
          })
      .toList(),
));
```

import 추가:
```dart
import '../../features/expense/domain/usecases/get_favorites_use_case.dart';
```

- [ ] **Step 5-3: _watchExpenses 내 updateWidget 호출도 동일하게 수정**

`_watchExpenses` 메서드의 `updateWidget` 호출에도 favorites 전달 추가 (동일 패턴):

```dart
final favoritesList = await getIt<GetFavoritesUseCase>().execute();

unawaited(getIt<WidgetService>().updateWidget(
  total: state.totalBudget,
  used: state.totalBudget - remaining,
  remaining: remaining,
  streak: state.streakDays,
  expenses: expenses.map((e) => { ... }).toList(),
  catMood: ...,
  favorites: favoritesList.map((f) => {
    'id': f.id,
    'amount': f.amount,
    'category': f.category,
    'memo': f.memo,
  }).toList(),
));
```

- [ ] **Step 5-4: flutter analyze**

```bash
flutter analyze lib/core/services/widget_service.dart \
               lib/features/home/presentation/viewmodels/home_view_model.dart
```
Expected: No issues

- [ ] **Step 5-5: 앱 실행 후 Large 위젯 동작 확인**

```bash
flutter run
```

확인 항목:
- Large 위젯에 즐겨찾기 버튼 표시 (즐겨찾기가 있을 때)
- 즐겨찾기 없을 때 "앱에서 즐겨찾기를 추가해보세요" 표시
- 버튼 탭 → 앱 열지 않고 지출 저장 → 홈 화면 잔액 갱신 확인

- [ ] **Step 5-6: 전체 테스트**

```bash
flutter test
```
Expected: All PASS

- [ ] **Step 5-7: 최종 커밋**

```bash
git add lib/core/services/widget_service.dart \
        lib/features/home/presentation/viewmodels/home_view_model.dart
git commit -m "feat(widget): WidgetService에 favorites 데이터 전달 추가"
```
