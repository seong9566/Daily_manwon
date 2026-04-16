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

  testWidgets('수동 즐겨찾기(isAuto=false) 칩 1개 표시', (tester) async {
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
                    isAuto: false,
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

  testWidgets('자동 즐겨찾기(isAuto=true) 칩 — 2줄 라벨(카테고리+금액) 표시',
      (tester) async {
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
                    isAuto: true,
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

  testWidgets('수동+자동 동일 조합 공존 시 칩 2개 표시', (tester) async {
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
                    isAuto: false,
                    createdAt: DateTime.utc(2026, 4, 1),
                  ),
                  FavoriteExpenseEntity(
                    id: 2,
                    amount: 1000,
                    category: 2,
                    usageCount: 0,
                    isAuto: true,
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
