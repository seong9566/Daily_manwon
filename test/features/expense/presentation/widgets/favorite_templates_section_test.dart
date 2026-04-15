import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/presentation/widgets/favorite_templates_section.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// GetIt 없이 지정된 HomeState를 반환하는 테스트용 스텁
class _StubHomeViewModel extends HomeViewModel {
  final HomeState _stubState;
  _StubHomeViewModel(this._stubState);

  @override
  HomeState build() => _stubState;
}

void main() {
  testWidgets('즐겨찾기가 없으면 칩 미표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              const HomeState(
                isLoading: false,
                favorites: [],
                frequentTemplates: [],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(onTemplateTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
  });

  testWidgets('수동 즐겨찾기 칩 표시', (tester) async {
    final favorites = [
      FavoriteExpenseEntity(
        id: 1,
        amount: 3500,
        category: 2,
        usageCount: 3,
        createdAt: DateTime.utc(2026, 4, 1),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeViewModelProvider.overrideWith(
            () => _StubHomeViewModel(
              HomeState(
                isLoading: false,
                favorites: favorites,
                frequentTemplates: const [],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(onTemplateTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsOneWidget);
  });
}
