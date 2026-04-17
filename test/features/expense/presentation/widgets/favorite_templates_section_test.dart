import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/presentation/widgets/favorite_templates_section.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubHomeViewModel extends HomeViewModel {
  final HomeState _stubState;
  _StubHomeViewModel(this._stubState);

  @override
  HomeState build() => _stubState;
}

void main() {
  testWidgets('즐겨찾기 없고 최근 내역 없으면 첫 탭에 빈 상태 문구 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('자주 쓰는 내역이 없습니다.'), findsOneWidget);
  });

  testWidgets('즐겨찾기 1개 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 1, amount: 3500, category: 2,
                    usageCount: 3,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3,500원'), findsOneWidget);
  });

  testWidgets('즐겨찾기 2개 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 1, amount: 1000, category: 2,
                    usageCount: 2,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                  FavoriteExpenseEntity(
                    id: 2, amount: 3000, category: 0,
                    usageCount: 1,
                    createdAt: DateTime.utc(2026, 4, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1,000원'), findsOneWidget);
    expect(find.text('3,000원'), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 전환 후 recentExpenses 칩 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [
                  ExpenseEntity(
                    id: 10, amount: 4500, category: 1,
                    memo: '점심',
                    createdAt: DateTime.utc(2026, 4, 16),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 기본 탭("자주 쓰는")에는 칩 없음
    expect(find.text('4,500원'), findsNothing);

    // "최근 내역" 탭 탭
    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    expect(find.text('4,500원'), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 빈 상태 — 안내 문구 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    expect(find.text('최근 내역이 없습니다.'), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 칩 탭 시 onTemplateTap 콜백 호출', (tester) async {
    ({int amount, int category, String memo})? captured;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [],
                recentExpenses: [
                  ExpenseEntity(
                    id: 10, amount: 4500, category: 1,
                    memo: '점심',
                    createdAt: DateTime.utc(2026, 4, 16),
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(
              onTemplateTap: (t) => captured = t,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // "최근 내역" 탭으로 전환
    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    // 칩 탭 (amount 텍스트로 식별)
    await tester.tap(find.text('4,500원'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.amount, 4500);
    expect(captured!.category, 1);
    expect(captured!.memo, '점심');
  });
}
