import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/presentation/widgets/favorite_templates_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('즐겨찾기가 없으면 칩 미표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((_) async => []),
          frequentTemplatesProvider.overrideWith((_) async => []),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(onTemplateTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('수동 즐겨찾기 칩 표시', (tester) async {
    final favorites = [
      FavoriteExpenseEntity(
        id: 1, amount: 3500, category: 2, usageCount: 3,
        createdAt: DateTime.utc(2026, 4, 1),
      ),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesProvider.overrideWith((_) async => favorites),
          frequentTemplatesProvider.overrideWith((_) async => []),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FavoriteTemplatesSection(onTemplateTap: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ActionChip), findsOneWidget);
  });
}
