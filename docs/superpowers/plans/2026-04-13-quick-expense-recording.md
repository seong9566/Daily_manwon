# 빠른 지출 기록 시스템 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 지출 기록 마찰을 최소화하는 4가지 진입점 구현 — 자동 학습 템플릿, 홈 위젯 프리셋 버튼, App Intents + Spotlight 검색, Control Center 컨트롤

**Architecture:** 자동 학습 템플릿은 기존 Expenses 테이블에서 GROUP BY 집계로 도출(새 테이블 없음). 위젯 프리셋은 WidgetService → App Group UserDefaults → Swift AppIntent → Flutter backgroundCallback 흐름으로 앱 진입 없이 기록 완결. App Intents는 DailyHomeWidget Extension 내에 정의하여 App Group 접근 권한을 재사용.

**Tech Stack:** Drift (customSelect), flutter_riverpod 3.x, home_widget 0.6.0, Swift WidgetKit + AppIntents (iOS 16+), ControlWidget API (iOS 18+), mocktail (테스트)

---

## 범위 검토

이 계획은 독립적으로 완결되는 4개 서브시스템으로 구성됩니다. 각 태스크는 이전 태스크 없이도 동작하지만, **태스크 2(위젯 프리셋)는 태스크 1(자동 학습)의 데이터를 소비하므로 순서대로 구현하세요.**

---

## 파일 맵

### 신규 생성 파일

```
lib/
├── features/expense/
│   ├── domain/entities/frequent_template.dart           # FrequentTemplate 데이터 클래스
│   └── domain/usecases/get_frequent_templates_use_case.dart
├── features/expense/presentation/widgets/
│   └── frequent_templates_bar.dart                      # 퀵 탭 UI 바
└── core/utils/
    └── background_callback_handler.dart                  # 위젯 backgroundCallback 로직

test/features/expense/
├── domain/usecases/get_frequent_templates_use_case_test.dart
└── presentation/widgets/frequent_templates_bar_test.dart

ios/DailyHomeWidget/
├── Intents/
│   ├── AddPresetExpenseIntent.swift                      # 위젯 버튼 AppIntent
│   └── AddExpenseSpotlightIntent.swift                   # Spotlight/Siri AppIntent
└── Models/
    └── TemplateItem.swift                                # 프리셋 데이터 모델
```

### 수정 파일

```
lib/
├── core/database/app_database.dart                       # getFrequentTemplates() 추가
├── core/services/widget_service.dart                     # templatesKey 추가
├── main.dart                                             # backgroundCallback 등록
└── features/expense/presentation/screens/expense_add_screen.dart  # FrequentTemplatesBar 삽입

ios/DailyHomeWidget/
├── Models/SimpleEntry.swift                              # templates 필드 추가
├── Views/MediumWidgetView.swift                          # 프리셋 버튼 영역 추가
├── DailyHomeWidget.swift                                 # AppShortcutsProvider 추가
└── DailyHomeWidgetControl.swift                          # 실제 구현으로 교체 (iOS 18+)
```

---

## Task 1: 자동 학습 템플릿 — Flutter

**Files:**
- Create: `lib/features/expense/domain/entities/frequent_template.dart`
- Create: `lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart`
- Modify: `lib/core/database/app_database.dart`
- Create: `lib/features/expense/presentation/widgets/frequent_templates_bar.dart`
- Modify: `lib/features/expense/presentation/screens/expense_add_screen.dart`
- Test: `test/features/expense/domain/usecases/get_frequent_templates_use_case_test.dart`
- Test: `test/features/expense/presentation/widgets/frequent_templates_bar_test.dart`

---

- [ ] **Step 1-1: FrequentTemplate 엔티티 생성**

`lib/features/expense/domain/entities/frequent_template.dart`:
```dart
import '../../../../core/constants/app_constants.dart';

/// 지난 30일 지출 기록에서 자동 학습된 자주 쓰는 지출 패턴
class FrequentTemplate {
  const FrequentTemplate({
    required this.amount,
    required this.category,
    required this.frequency,
  });

  final int amount;
  final int category;

  /// 지난 30일 내 동일 (금액+카테고리) 조합 등장 횟수
  final int frequency;

  ExpenseCategory get expenseCategory => ExpenseCategory.values[category];
}
```

- [ ] **Step 1-2: AppDatabase에 getFrequentTemplates() 추가**

`lib/core/database/app_database.dart` 끝 부분 (클래스 `}` 닫기 전에) 추가:
```dart
  /// 최근 30일 지출을 (금액, 카테고리) 기준으로 집계하여 자주 쓰는 패턴 상위 [limit]개 반환
  Future<List<Map<String, int>>> getFrequentTemplates({int limit = 3}) async {
    final thirtyDaysAgo =
        DateTime.now().subtract(const Duration(days: 30));
    final query = customSelect(
      'SELECT amount, category, COUNT(*) AS frequency '
      'FROM expenses '
      'WHERE created_at >= ? '
      'GROUP BY amount, category '
      'ORDER BY frequency DESC '
      'LIMIT ?',
      variables: [
        Variable.withDateTime(thirtyDaysAgo),
        Variable.withInt(limit),
      ],
      readsFrom: {expenses},
    );
    final rows = await query.get();
    return rows
        .map((row) => {
              'amount': row.read<int>('amount'),
              'category': row.read<int>('category'),
              'frequency': row.read<int>('frequency'),
            })
        .toList();
  }
```

- [ ] **Step 1-3: GetFrequentTemplatesUseCase 생성**

`lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart`:
```dart
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../entities/frequent_template.dart';

@lazySingleton
class GetFrequentTemplatesUseCase {
  const GetFrequentTemplatesUseCase(this._database);

  final AppDatabase _database;

  Future<List<FrequentTemplate>> execute({int limit = 3}) async {
    final rows = await _database.getFrequentTemplates(limit: limit);
    return rows
        .map((row) => FrequentTemplate(
              amount: row['amount']!,
              category: row['category']!,
              frequency: row['frequency']!,
            ))
        .toList();
  }
}
```

- [ ] **Step 1-4: UseCase 테스트 파일 생성 후 실행 (실패 확인)**

`test/features/expense/domain/usecases/get_frequent_templates_use_case_test.dart`:
```dart
import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/expense/domain/usecases/get_frequent_templates_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase db;
  late GetFrequentTemplatesUseCase useCase;

  setUp(() {
    db = MockAppDatabase();
    useCase = GetFrequentTemplatesUseCase(db);
  });

  test('returns top templates sorted by frequency', () async {
    when(() => db.getFrequentTemplates(limit: 3)).thenAnswer((_) async => [
          {'amount': 4500, 'category': 2, 'frequency': 8},
          {'amount': 1250, 'category': 1, 'frequency': 5},
          {'amount': 8000, 'category': 0, 'frequency': 2},
        ]);

    final result = await useCase.execute(limit: 3);

    expect(result.length, 3);
    expect(result[0].amount, 4500);
    expect(result[0].frequency, 8);
    expect(result[1].amount, 1250);
  });

  test('returns empty list when no expenses', () async {
    when(() => db.getFrequentTemplates(limit: 3)).thenAnswer((_) async => []);

    final result = await useCase.execute();

    expect(result, isEmpty);
  });
}
```

Run: `flutter test test/features/expense/domain/usecases/get_frequent_templates_use_case_test.dart`
Expected: FAIL (class not found)

- [ ] **Step 1-5: 코드 생성 실행**

```bash
cd /Users/stecdev/Desktop/workspace/flutter_project/daily_manwon
dart run build_runner build --delete-conflicting-outputs
```

Expected: `injection.config.dart` 재생성 (GetFrequentTemplatesUseCase 포함)

- [ ] **Step 1-6: UseCase 테스트 재실행 (통과 확인)**

```bash
flutter test test/features/expense/domain/usecases/get_frequent_templates_use_case_test.dart
```
Expected: PASS (2 tests)

- [ ] **Step 1-7: FrequentTemplatesBar 위젯 생성**

`lib/features/expense/presentation/widgets/frequent_templates_bar.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/frequent_template.dart';

/// 자주 쓰는 지출 패턴을 1탭으로 빠르게 입력하는 가로 스크롤 바
///
/// 템플릿이 없으면 아무것도 렌더링하지 않는다 (SizedBox.shrink).
class FrequentTemplatesBar extends StatelessWidget {
  const FrequentTemplatesBar({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
  });

  final List<FrequentTemplate> templates;

  /// 탭 시 해당 템플릿의 (amount, category)를 전달
  final void Function(FrequentTemplate template) onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final subColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '자주 쓰는 지출',
            style: AppTypography.caption.copyWith(color: subColor),
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: templates
                .map((t) => _TemplateChip(
                      template: t,
                      chipBg: chipBg,
                      textColor: textColor,
                      subColor: subColor,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTemplateSelected(t);
                      },
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.template,
    required this.chipBg,
    required this.textColor,
    required this.subColor,
    required this.onTap,
  });

  final FrequentTemplate template;
  final Color chipBg;
  final Color textColor;
  final Color subColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = template.expenseCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: category.chipColor.withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CurrencyFormatter.formatWithWon(template.amount),
                    style: AppTypography.bodySmall.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    category.label,
                    style: AppTypography.caption.copyWith(
                      color: subColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **주의:** `ExpenseCategory`에 `emoji` getter가 없으면 `app_constants.dart`에 추가:
> ```dart
> String get emoji {
>   switch (this) {
>     case food: return '🍚';
>     case transport: return '🚌';
>     case cafe: return '☕';
>     case shopping: return '🛍️';
>     case etc: return '📦';
>   }
> }
> ```

- [ ] **Step 1-8: expense_add_screen.dart에 FrequentTemplatesBar 삽입**

`lib/features/expense/presentation/screens/expense_add_screen.dart` 상단 import 추가:
```dart
import 'package:get_it/get_it.dart';
import '../../domain/entities/frequent_template.dart';
import '../../domain/usecases/get_frequent_templates_use_case.dart';
import '../widgets/frequent_templates_bar.dart';
```

`_ExpenseAddBottomSheetState`에 상태 필드 추가:
```dart
List<FrequentTemplate> _templates = [];
```

`initState()`에 템플릿 로드 추가 (기존 initState 끝에):
```dart
@override
void initState() {
  super.initState();
  // ... 기존 코드 ...
  _loadTemplates();
}

Future<void> _loadTemplates() async {
  // 편집 모드에서는 템플릿 불필요
  if (widget.expense != null) return;
  try {
    final useCase = GetIt.instance<GetFrequentTemplatesUseCase>();
    final templates = await useCase.execute(limit: 3);
    if (mounted) setState(() => _templates = templates);
  } catch (_) {
    // 템플릿 로드 실패는 무시 (핵심 기능이 아님)
  }
}
```

템플릿 선택 핸들러 추가:
```dart
void _onTemplateSelected(FrequentTemplate template) {
  setState(() {
    _amountString = template.amount.toString();
    _selectedCategory = template.expenseCategory;
  });
}
```

`build()` 내 카테고리 선택자 위에 FrequentTemplatesBar 삽입 (기존 `const SizedBox(height: 12),` 금액 표시 영역 다음):
```dart
// ── 자주 쓰는 지출 (편집 모드 제외) ─────────────────
if (widget.expense == null && _templates.isNotEmpty)
  FrequentTemplatesBar(
    templates: _templates,
    onTemplateSelected: _onTemplateSelected,
  ),
```

위치: `const SizedBox(height: 24),` (금액 표시 영역 이후) 다음 줄, 카테고리 선택자 `Padding` 이전.

- [ ] **Step 1-9: 앱 실행 및 동작 확인**

```bash
flutter run
```

확인 사항:
- 지출 기록이 3건 이상 있을 때 바텀시트 열면 '자주 쓰는 지출' 칩 표시
- 칩 탭 시 금액 + 카테고리 자동 입력
- 편집 모드에서는 칩 미표시
- 지출 0건일 때 칩 없이 기존 UI 그대로

- [ ] **Step 1-10: 커밋**

```bash
git add \
  lib/features/expense/domain/entities/frequent_template.dart \
  lib/features/expense/domain/usecases/get_frequent_templates_use_case.dart \
  lib/features/expense/presentation/widgets/frequent_templates_bar.dart \
  lib/features/expense/presentation/screens/expense_add_screen.dart \
  lib/core/database/app_database.dart \
  lib/core/di/injection.config.dart \
  lib/core/constants/app_constants.dart \
  test/features/expense/domain/usecases/get_frequent_templates_use_case_test.dart
git commit -m "feat(expense): 자동 학습 템플릿 1탭 입력 기능 추가"
```

---

## Task 2: 홈 위젯 프리셋 버튼 — Flutter + Swift

자동 학습 템플릿 Top 3를 위젯 버튼으로 노출. Medium 위젯에 프리셋 탭 영역 추가. 탭 → AppIntent → backgroundCallback → DB 저장 → 위젯 갱신.

**Files:**
- Create: `lib/core/utils/background_callback_handler.dart`
- Create: `ios/DailyHomeWidget/Intents/AddPresetExpenseIntent.swift`
- Create: `ios/DailyHomeWidget/Models/TemplateItem.swift`
- Modify: `lib/core/services/widget_service.dart`
- Modify: `lib/main.dart`
- Modify: `ios/DailyHomeWidget/Models/SimpleEntry.swift`
- Modify: `ios/DailyHomeWidget/Views/MediumWidgetView.swift`
- Modify: `ios/DailyHomeWidget/DailyHomeWidget.swift`

---

- [ ] **Step 2-1: WidgetService에 템플릿 데이터 전달 추가**

`lib/core/services/widget_service.dart` — `updateWidget()` 시그니처 확장:
```dart
Future<void> updateWidget({
  required int total,
  required int used,
  required int remaining,
  required int streak,
  required List<Map<String, dynamic>> expenses,
  required String catMood,
  List<Map<String, dynamic>> templates = const [],  // 추가
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
    await HomeWidget.saveWidgetData<String>('templatesKey', jsonEncode(templates));  // 추가
    await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
    debugPrint('WidgetService: 위젯 갱신 완료');
  } catch (e) {
    debugPrint('WidgetService: 위젯 갱신 실패 — $e');
  }
}
```

- [ ] **Step 2-2: HomeViewModel에서 templates 전달**

`lib/features/home/presentation/viewmodels/home_view_model.dart`에서 `_watchExpenses()` 또는 위젯 갱신 호출부를 찾아 templates 인수 추가:

기존 `widgetService.updateWidget(...)` 호출에 templates 파라미터 추가:
```dart
// GetFrequentTemplatesUseCase를 주입받아 호출
final templates = await _getFrequentTemplates.execute(limit: 3);
await _widgetService.updateWidget(
  total: ...,
  used: ...,
  remaining: ...,
  streak: ...,
  expenses: ...,
  catMood: ...,
  templates: templates
      .map((t) => {'amount': t.amount, 'category': t.category})
      .toList(),
);
```

> HomeViewModel 생성자에 `GetFrequentTemplatesUseCase` 주입 추가 필요 (Injectable 코드젠 재실행 후 자동 반영)

- [ ] **Step 2-3: backgroundCallback 핸들러 모듈 생성**

`lib/core/utils/background_callback_handler.dart`:
```dart
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/domain/usecases/add_expense_use_case.dart';
import '../../features/home/domain/usecases/get_today_budget_use_case.dart';
import '../../features/home/domain/usecases/get_today_expenses_use_case.dart';
import '../di/injection.dart';
import '../services/widget_service.dart';
import '../utils/app_date_utils.dart';
import '../constants/app_constants.dart';

/// 홈 위젯 버튼 탭 시 호출되는 백그라운드 콜백
///
/// Flutter 엔진이 백그라운드 격리(isolate)에서 이 함수를 실행한다.
/// `main()` 이전에 등록되어야 하므로 @pragma vm:entry-point가 필수.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (uri == null) return;

  if (uri.host == 'addPreset') {
    await _handleAddPreset(uri);
  }
}

Future<void> _handleAddPreset(Uri uri) async {
  final amount = int.tryParse(uri.queryParameters['amount'] ?? '') ?? 0;
  final categoryIndex =
      int.tryParse(uri.queryParameters['category'] ?? '') ?? 0;

  if (amount <= 0) return;

  // 백그라운드 isolate에서 DI 초기화
  if (!GetIt.instance.isRegistered<AddExpenseUseCase>()) {
    await configureDependencies();
  }

  final addExpense = GetIt.instance<AddExpenseUseCase>();
  final getTodayBudget = GetIt.instance<GetTodayBudgetUseCase>();
  final getTodayExpenses = GetIt.instance<GetTodayExpensesUseCase>();
  final widgetService = GetIt.instance<WidgetService>();

  await widgetService.init();

  // 지출 저장
  await addExpense.execute(ExpenseEntity(
    id: 0,
    amount: amount,
    category: categoryIndex,
    createdAt: DateTime.now(),
  ));

  // 위젯 데이터 재계산 후 갱신
  final today = AppDateUtils.today();
  final budget = await getTodayBudget.execute(today);
  final expenses = await getTodayExpenses.execute(today);

  if (budget == null) return;

  final totalSpent = expenses.fold(0, (sum, e) => sum + e.amount);
  final totalBudget = budget.baseAmount + budget.carryOver;
  final remaining = totalBudget - totalSpent;

  await widgetService.updateWidget(
    total: totalBudget,
    used: totalSpent,
    remaining: remaining,
    streak: 0, // 백그라운드에서 streak 계산은 생략 (다음 앱 포어그라운드에서 갱신)
    expenses: expenses
        .take(3)
        .map((e) => {
              'category': ExpenseCategory.values[e.category].label,
              'time': '${e.createdAt.hour.toString().padLeft(2, '0')}:'
                  '${e.createdAt.minute.toString().padLeft(2, '0')}',
              'amount': e.amount,
            })
        .toList(),
    catMood: remaining >= 5000
        ? 'comfortable'
        : remaining >= 1000
            ? 'normal'
            : remaining >= 0
                ? 'danger'
                : 'over',
  );
}
```

- [ ] **Step 2-4: main.dart에 backgroundCallback 등록**

`lib/main.dart`에 import 추가:
```dart
import 'package:home_widget/home_widget.dart';
import 'core/utils/background_callback_handler.dart';
```

`main()` 내 `WidgetsFlutterBinding.ensureInitialized();` 바로 다음에 추가:
```dart
// 홈 위젯 백그라운드 인터랙션 콜백 등록
HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
```

- [ ] **Step 2-5: Swift TemplateItem 모델 생성**

`ios/DailyHomeWidget/Models/TemplateItem.swift`:
```swift
import Foundation

/// 자동 학습된 자주 쓰는 지출 패턴 (위젯 프리셋 버튼용)
struct TemplateItem: Codable, Identifiable {
    let amount: Int
    let category: Int   // ExpenseCategory enum index (0=food, 1=transport, 2=cafe, 3=shopping, 4=etc)

    var id: String { "\(amount)_\(category)" }

    /// 카테고리 이모지 표시
    var categoryEmoji: String {
        switch category {
        case 0: return "🍚"
        case 1: return "🚌"
        case 2: return "☕"
        case 3: return "🛍️"
        default: return "📦"
        }
    }

    /// 카테고리 한글 레이블
    var categoryLabel: String {
        switch category {
        case 0: return "식비"
        case 1: return "교통"
        case 2: return "카페"
        case 3: return "쇼핑"
        default: return "기타"
        }
    }

    /// 금액 포맷 (₩4,500)
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "₩\(number)"
    }
}
```

- [ ] **Step 2-6: SimpleEntry에 templates 필드 추가**

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
    let templates: [TemplateItem]   // 추가

    var progressRatio: Double {
        guard total > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(remaining) / Double(total)))
    }
}
```

- [ ] **Step 2-7: DailyHomeWidget.swift의 Provider에서 templates 파싱**

`ios/DailyHomeWidget/DailyHomeWidget.swift`의 `getTimeline()` 내부에서 기존 `expenses` 파싱 블록 다음에 추가:
```swift
// 자동 학습 템플릿 파싱
var templates: [TemplateItem] = []
if let jsonString = userDefault?.string(forKey: "templatesKey"),
   let data = jsonString.data(using: .utf8) {
    templates = (try? JSONDecoder().decode([TemplateItem].self, from: data)) ?? []
}
```

`SimpleEntry(...)` 초기화에 `templates: templates` 추가.

`placeholder()`, `getSnapshot()` 도 `templates: []` 추가.

- [ ] **Step 2-8: AddPresetExpenseIntent Swift 생성**

`ios/DailyHomeWidget/Intents/AddPresetExpenseIntent.swift`:
```swift
import AppIntents
import WidgetKit

/// 위젯 프리셋 버튼 탭 시 실행되는 AppIntent
/// home_widget의 backgroundCallback을 통해 Flutter에서 지출을 저장한다.
@available(iOS 16.0, *)
struct AddPresetExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "지출 기록"
    static var description = IntentDescription("자주 쓰는 지출을 바로 기록합니다")

    @Parameter(title: "금액")
    var amount: Int

    @Parameter(title: "카테고리")
    var category: Int

    init() {}
    init(amount: Int, category: Int) {
        self.amount = amount
        self.category = category
    }

    func perform() async throws -> some IntentResult {
        guard let url = URL(
            string: "dailymanwon://addPreset?amount=\(amount)&category=\(category)"
        ) else { return .result() }

        // home_widget의 interactivity callback 트리거
        // Flutter 백그라운드 엔진이 widgetBackgroundCallback(uri)을 실행
        HomeWidgetPlugin.triggerInteractivity(url: url)

        return .result()
    }
}
```

> **Xcode 설정 필요:** DailyHomeWidget Extension의 `Info.plist`에 `NSExtensionAttributes > NSExtensionActivationRule` 확인.

- [ ] **Step 2-9: MediumWidgetView에 프리셋 버튼 영역 추가**

`ios/DailyHomeWidget/Views/MediumWidgetView.swift`에서 `content` 하단 (프로그레스 바 아래) 교체:

기존:
```swift
WidgetProgressBar(ratio: entry.progressRatio, colors: colors)
Spacer().frame(height: 6)
Text(status.statusMessage)
```

교체:
```swift
// 프리셋 버튼 (템플릿이 있을 때만 표시, 최대 2개)
if !entry.templates.isEmpty {
    HStack(spacing: 8) {
        ForEach(entry.templates.prefix(2)) { template in
            Button(intent: AddPresetExpenseIntent(
                amount: template.amount,
                category: template.category
            )) {
                HStack(spacing: 4) {
                    Text(template.categoryEmoji)
                        .font(.system(size: 11))
                    Text(template.formattedAmount)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(colors.accent.opacity(0.6))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        Spacer()
    }
} else {
    WidgetProgressBar(ratio: entry.progressRatio, colors: colors)
    Spacer().frame(height: 6)
    Text(status.statusMessage)
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(colors.secondaryText)
        .lineLimit(1)
}
```

- [ ] **Step 2-10: Xcode 빌드 및 시뮬레이터 확인**

Xcode에서 DailyHomeWidget Extension 타겟 빌드:
```
Product → Build (⌘B)
```

예상 결과: 빌드 성공. 시뮬레이터에서 Medium 위젯에 자주 쓰는 지출 칩 표시.

- [ ] **Step 2-11: 커밋**

```bash
git add \
  lib/core/utils/background_callback_handler.dart \
  lib/core/services/widget_service.dart \
  lib/main.dart \
  ios/DailyHomeWidget/Models/TemplateItem.swift \
  ios/DailyHomeWidget/Models/SimpleEntry.swift \
  ios/DailyHomeWidget/Intents/AddPresetExpenseIntent.swift \
  ios/DailyHomeWidget/Views/MediumWidgetView.swift \
  ios/DailyHomeWidget/DailyHomeWidget.swift
git commit -m "feat(widget): 자동 학습 프리셋 버튼 위젯 추가 (옵션 1+3)"
```

---

## Task 3: App Intents + Spotlight 검색 — Swift

Spotlight에서 금액을 검색하면 "Daily만원에 기록" 액션이 노출된다. 앱을 열어 지출 입력 화면으로 딥링크.

**Files:**
- Create: `ios/DailyHomeWidget/Intents/AddExpenseSpotlightIntent.swift`
- Modify: `ios/DailyHomeWidget/DailyHomeWidget.swift` (AppShortcutsProvider 추가)
- Modify: `ios/Runner/AppDelegate.swift` (Spotlight donation 트리거)

---

- [ ] **Step 3-1: AddExpenseSpotlightIntent 생성**

`ios/DailyHomeWidget/Intents/AddExpenseSpotlightIntent.swift`:
```swift
import AppIntents

/// Spotlight 검색 및 Siri에서 노출되는 지출 기록 Intent
///
/// 사용자가 Spotlight에서 숫자를 검색하면 이 액션이 제안된다.
/// 실행 시 앱을 열어 지출 입력 화면으로 딥링크한다.
@available(iOS 16.0, *)
struct AddExpenseSpotlightIntent: AppIntent {
    static var title: LocalizedStringResource = "지출 기록하기"
    static var description = IntentDescription("하루 만원에 지출을 기록합니다")

    // Spotlight에서 앱 아이콘 옆에 표시
    static var openAppWhenRun: Bool = true

    @Parameter(title: "금액", description: "기록할 금액 (원)")
    var amount: Int?

    func perform() async throws -> some IntentResult {
        // openAppWhenRun = true이므로 앱이 열린다.
        // 앱은 onOpenURL로 딥링크를 처리해야 한다.
        return .result()
    }
}

/// Shortcuts 앱 및 Spotlight에 앱의 단축어를 등록
@available(iOS 16.0, *)
struct DailyManwonShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseSpotlightIntent(),
            phrases: [
                "하루 만원에 지출 기록",
                "만원 가계부 기록",
                "\(.applicationName)에 지출 추가",
            ],
            shortTitle: "지출 기록",
            systemImageName: "plus.circle.fill"
        )
    }
}
```

- [ ] **Step 3-2: DailyHomeWidget.swift에 ShortcutsProvider 연결**

`ios/DailyHomeWidget/DailyHomeWidgetBundle.swift` 파일을 열어 확인 후, `@main` Bundle 구조체에 추가:

`DailyHomeWidgetBundle.swift` 내용:
```swift
import WidgetKit
import SwiftUI

@main
struct DailyHomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyHomeWidget()
        if #available(iOSApplicationExtension 18.0, *) {
            DailyHomeWidgetControl()
        }
    }
}
```

Spotlight AppShortcuts는 Extension 내에서 자동으로 인식된다. 별도 등록 코드 불필요.

- [ ] **Step 3-3: 앱 실행 시 Shortcuts donation**

`ios/Runner/AppDelegate.swift`에 donation 추가:
```swift
import AppIntents  // 상단 추가

// didFinishLaunchingWithOptions 내부에 추가:
if #available(iOS 16.0, *) {
    DailyManwonShortcuts.updateAppShortcutParameters()
}
```

> **Xcode 타겟 설정:** `AddExpenseSpotlightIntent`가 Runner 타겟에도 포함되어야 AppDelegate에서 접근 가능. Xcode → 파일 선택 → Target Membership에 Runner 추가.

- [ ] **Step 3-4: Spotlight 동작 확인**

1. 기기(시뮬레이터 아닌 실기기 권장) 또는 시뮬레이터에서 앱 빌드·실행
2. 홈 화면에서 아래로 스와이프 → Spotlight 열기
3. "하루 만원에 지출" 또는 "지출 기록" 검색
4. "지출 기록하기" 액션 카드가 앱 아이콘과 함께 표시되는지 확인
5. 탭 시 앱이 열리는지 확인

> Spotlight에 인덱싱되기까지 수십 초 딜레이가 있을 수 있음.

- [ ] **Step 3-5: 커밋**

```bash
git add \
  ios/DailyHomeWidget/Intents/AddExpenseSpotlightIntent.swift \
  ios/DailyHomeWidget/DailyHomeWidgetBundle.swift \
  ios/Runner/AppDelegate.swift
git commit -m "feat(ios): App Intents + Spotlight 지출 기록 액션 추가"
```

---

## Task 4: Control Center ControlWidget — Swift (iOS 18+)

제어센터에 "지출 기록" 버튼 추가. 탭 → 앱 열림 → 지출 입력 화면 자동 표시.

**Files:**
- Modify: `ios/DailyHomeWidget/DailyHomeWidgetControl.swift` (전체 교체)

---

- [ ] **Step 4-1: DailyHomeWidgetControl.swift 완전 교체**

`ios/DailyHomeWidget/DailyHomeWidgetControl.swift`:
```swift
import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Control Center 버튼용 Intent

@available(iOS 18.0, *)
struct OpenExpenseInputIntent: AppIntent {
    static var title: LocalizedStringResource = "지출 기록"
    static var description = IntentDescription("하루 만원에서 지출을 기록합니다")

    // 앱을 열어서 지출 입력 화면으로 이동
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - ControlWidget 정의

@available(iOS 18.0, *)
struct DailyHomeWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.seong.dailyManwon.expenseControl",
            provider: ExpenseControlProvider()
        ) { _ in
            ControlWidgetButton(action: OpenExpenseInputIntent()) {
                Label("지출 기록", systemImage: "plus.circle.fill")
            }
            .tint(.green)
        }
        .displayName("지출 기록")
        .description("하루 만원에 지출을 빠르게 기록합니다")
    }
}

// MARK: - ControlValueProvider

@available(iOS 18.0, *)
struct ExpenseControlProvider: ControlValueProvider {
    typealias Value = Void

    var previewValue: Void { () }

    func currentValue() async throws -> Void { () }
}
```

- [ ] **Step 4-2: kind ID 변경 (기존 placeholder와 중복 방지)**

Xcode에서 DailyHomeWidgetBundle의 `kind` 중복 확인. `DailyHomeWidget`의 kind는 `"DailyHomeWidget"`, Control은 `"com.seong.dailyManwon.expenseControl"`으로 분리되어 있어야 함.

- [ ] **Step 4-3: Xcode 빌드 및 제어센터 확인**

```
Product → Build (⌘B)  
```

iOS 18 기기에서:
1. 앱 설치 후 실행
2. 설정 → 제어센터 → "제어 항목 추가"
3. 목록에 "하루 만원 — 지출 기록" 표시 확인
4. 추가 후 제어센터에서 버튼 탭 → 앱 열리며 지출 입력 가능 확인

- [ ] **Step 4-4: 커밋**

```bash
git add ios/DailyHomeWidget/DailyHomeWidgetControl.swift
git commit -m "feat(ios): Control Center 지출 기록 버튼 구현 (iOS 18+)"
```

---

## 셀프 리뷰

### 스펙 커버리지 체크

| 요구사항 | 구현 태스크 |
|---------|-----------|
| A. 자동 학습 템플릿 (30일 패턴 학습) | Task 1 |
| 위젯 옵션 1 (프리셋 버튼) | Task 2 |
| 위젯 옵션 3 (학습된 Top 3가 프리셋 자동 반영) | Task 1 + Task 2 |
| App Intents + Spotlight | Task 3 |
| Action Button / Back Tap | Task 3 (Shortcuts 등록으로 자동 지원) |
| Control Center (iOS 18+) | Task 4 |
| Focus 연동 → 시간대 알림 대체 | 기존 NotificationService 활용 (신규 구현 불필요) |

### 플레이스홀더 스캔

- Step 2-7의 HomeViewModel 연동: `GetFrequentTemplatesUseCase` 주입 구체적 위치가 HomeViewModel 소스 분석 필요. 구현 시 `home_view_model.dart`에서 `_widgetService.updateWidget()` 호출 지점을 직접 확인할 것.
- Step 2-8의 `HomeWidgetPlugin.triggerInteractivity(url:)`: home_widget 0.6.0 Swift 공개 API 이름 확인 필요. 버전에 따라 `HomeWidgetPlugin.sendBackground(url:)` 또는 `HomeWidgetPlugin.interactivity(url:)`일 수 있음. Xcode 자동완성으로 확인 후 맞게 수정.

### 타입 일관성

- `FrequentTemplate.category` (int) ↔ `TemplateItem.category` (Int) — 동일 인덱스 체계
- `templatesKey` UserDefaults 키 — WidgetService, DailyHomeWidget.swift getTimeline() 동일
- URI 스킴 `dailymanwon://addPreset` — backgroundCallback 핸들러, AddPresetExpenseIntent 동일

---

## 실행 순서 권장

```
Task 1 (자동 학습 템플릿)
  → Task 2 (위젯 프리셋) — Task 1 데이터 소비
  → Task 3 (Spotlight) — 독립적
  → Task 4 (Control Center) — 독립적
```

Task 3, 4는 병렬 실행 가능.
