import 'package:daily_manwon/core/constants/app_constants.dart';
import 'package:daily_manwon/features/expense/domain/entities/expense.dart';
import 'package:daily_manwon/features/expense/domain/entities/favorite_expense.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/favorite_templates_state.dart';
import 'package:daily_manwon/features/expense/presentation/viewmodels/favorite_templates_view_model.dart';
import 'package:daily_manwon/features/expense/presentation/widgets/favorite_templates_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubFavoriteTemplatesViewModel extends FavoriteTemplatesViewModel {
  final FavoriteTemplatesState _stubState;
  _StubFavoriteTemplatesViewModel(this._stubState);

  @override
  FavoriteTemplatesState build() => _stubState;
}

Widget _buildApp({
  required FavoriteTemplatesState stubState,
  void Function(({int amount, ExpenseCategory category, String memo}))? onTemplateTap,
}) {
  return ProviderScope(
    overrides: [
      favoriteTemplatesViewModelProvider.overrideWith(
        () => _StubFavoriteTemplatesViewModel(stubState),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: FavoriteTemplatesSection(onTemplateTap: onTemplateTap ?? (_) {}),
      ),
    ),
  );
}

void main() {
  testWidgets('즐겨찾기 없고 최근 내역 없으면 첫 탭에 빈 상태 문구 표시', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        stubState: const FavoriteTemplatesState(
          isLoading: false,
          favorites: [],
          recentExpenses: [],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('자주 쓰는 내역이 없습니다.'), findsOneWidget);
  });

  testWidgets('즐겨찾기 1개 표시', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        stubState: FavoriteTemplatesState(
          isLoading: false,
          favorites: [
            FavoriteExpenseEntity(
              id: 1,
              amount: 3500,
              category: ExpenseCategory.shopping,
              usageCount: 3,
              createdAt: DateTime.utc(2026, 4, 1),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3,500원'), findsOneWidget);
  });

  testWidgets('즐겨찾기 2개 표시', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        stubState: FavoriteTemplatesState(
          isLoading: false,
          favorites: [
            FavoriteExpenseEntity(
              id: 1,
              amount: 1000,
              category: ExpenseCategory.shopping,
              usageCount: 2,
              createdAt: DateTime.utc(2026, 4, 1),
            ),
            FavoriteExpenseEntity(
              id: 2,
              amount: 3000,
              category: ExpenseCategory.food,
              usageCount: 1,
              createdAt: DateTime.utc(2026, 4, 2),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1,000원'), findsOneWidget);
    expect(find.text('3,000원'), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 전환 후 recentExpenses 칩 표시', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        stubState: FavoriteTemplatesState(
          isLoading: false,
          favorites: [],
          recentExpenses: [
            ExpenseEntity(
              id: 10,
              amount: 4500,
              category: ExpenseCategory.transport,
              memo: '점심',
              createdAt: DateTime.utc(2026, 4, 16),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4,500원'), findsNothing);

    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    expect(find.text('4,500원'), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 빈 상태 — 안내 문구 표시', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        stubState: const FavoriteTemplatesState(
          isLoading: false,
          favorites: [],
          recentExpenses: [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    expect(find.text('최근 내역이 없습니다.'), findsOneWidget);
  });

  testWidgets('"최근 내역" 탭 칩 탭 시 onTemplateTap 콜백 호출', (tester) async {
    ({int amount, ExpenseCategory category, String memo})? captured;

    await tester.pumpWidget(
      _buildApp(
        stubState: FavoriteTemplatesState(
          isLoading: false,
          favorites: [],
          recentExpenses: [
            ExpenseEntity(
              id: 10,
              amount: 4500,
              category: ExpenseCategory.transport,
              memo: '점심',
              createdAt: DateTime.utc(2026, 4, 16),
            ),
          ],
        ),
        onTemplateTap: (t) => captured = t,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('최근 내역'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('4,500원'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.amount, 4500);
    expect(captured!.category, ExpenseCategory.transport);
    expect(captured!.memo, '점심');
  });
}
