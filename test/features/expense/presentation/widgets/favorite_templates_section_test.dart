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
  testWidgets('즐겨찾기 없으면 칩 미표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(isLoading: false, favorites: []),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteTemplatesSection(onTemplateTap: (_) {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('즐겨찾기 1개 — 칩 1개 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 1,
                    amount: 3500,
                    category: 2,
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
    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets('즐겨찾기 칩 — 카테고리+금액 라벨 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 2,
                    amount: 1000,
                    category: 2,
                    usageCount: 0,
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
    expect(find.byType(InputChip), findsOneWidget);
    // 카테고리 라벨('카페')과 금액('1,000원') 모두 렌더됨
    expect(find.text('카페'), findsOneWidget);
    expect(find.text('1,000원'), findsOneWidget);
  });

  testWidgets('즐겨찾기 2개 — 칩 2개 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: [
                  FavoriteExpenseEntity(
                    id: 1,
                    amount: 1000,
                    category: 2,
                    usageCount: 2,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                  FavoriteExpenseEntity(
                    id: 2,
                    amount: 2000,
                    category: 3,
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
    expect(find.byType(InputChip), findsNWidgets(2));
  });
}
