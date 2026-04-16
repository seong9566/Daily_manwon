import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import '../../domain/entities/expense.dart';

/// 수동 즐겨찾기 + 자동학습 추천 칩 및 최근 내역 목록을 제공하는 섹션
class FavoriteTemplatesSection extends ConsumerStatefulWidget {
  /// 템플릿/내역 탭 시 호출 — amount, category, memo 전달
  final void Function(({int amount, int category, String memo})) onTemplateTap;

  const FavoriteTemplatesSection({super.key, required this.onTemplateTap});

  @override
  ConsumerState<FavoriteTemplatesSection> createState() =>
      _FavoriteTemplatesSectionState();
}

class _FavoriteTemplatesSectionState
    extends ConsumerState<FavoriteTemplatesSection> {
  int _selectedTabIndex = 0; // 0: 자주 쓰는, 1: 최근 내역

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    if (homeState.isLoading) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    // 자주 쓰는 데이터
    final favorites = homeState.favorites;
    final frequent = homeState.frequentTemplates;
    final dismissedFreqKeys = homeState.dismissedFreqKeys;

    final favoriteKeys = favorites
        .map((f) => '${f.amount}_${f.category}')
        .toSet();
    final deduped = frequent
        .where(
          (t) =>
              !favoriteKeys.contains('${t['amount']}_${t['category']}') &&
              !dismissedFreqKeys.contains('${t['amount']}_${t['category']}'),
        )
        .toList();

    // 최근 내역 데이터
    final recentExpenses = homeState.expenses;

    // 만약 둘 다 비어있다면 아예 보이지 않게 처리할지 고민.
    // 최소한 탭 자체는 보이게 놔두고 '내역 없음'을 표시하는 편이 낫다.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 탭 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildTab('자주 쓰는', 0, textMainColor, textSubColor),
              const SizedBox(width: 16),
              _buildTab('최근 내역', 1, textMainColor, textSubColor),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 내용 영역
        SizedBox(
          height: 70, // 카드가 들어갈 정도의 높이 제한 (가로 스크롤)
          child: _selectedTabIndex == 0
              ? _buildFrequentSpace(favorites, deduped, isDark)
              : _buildRecentSpace(recentExpenses, isDark),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTab(String title, int index, Color mainColor, Color subColor) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected ? mainColor : subColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 32,
            color: isSelected ? mainColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentSpace(
    List<dynamic> favorites,
    List<Map<String, int>> deduped,
    bool isDark,
  ) {
    if (favorites.isEmpty && deduped.isEmpty) {
      return Center(
        child: Text(
          '자주 쓰는 내역이 없습니다.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSub),
        ),
      );
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ...favorites.map(
          (fav) => _buildCard(
            title: fav.memo?.isNotEmpty == true
                ? fav.memo!
                : ExpenseCategory.values[fav.category].label,
            amount: fav.amount,
            isDark: isDark,
            onTap: () async {
              try {
                await ref
                    .read(homeViewModelProvider.notifier)
                    .incrementFavoriteUsage(fav.id);
              } catch (_) {}
              widget.onTemplateTap((
                amount: fav.amount,
                category: fav.category,
                memo: fav.memo ?? '',
              ));
            },
            onLongPress: () async {
              // 기존 onDeleted 로직 등 삭제 플로우 추가 가능
              try {
                await ref
                    .read(homeViewModelProvider.notifier)
                    .deleteFavorite(fav.id);
              } catch (_) {}
            },
          ),
        ),
        ...deduped.map((t) {
          final cat = ExpenseCategory.values[t['category']!];
          return _buildCard(
            title: cat.label,
            amount: t['amount']!,
            isDark: isDark,
            onTap: () {
              widget.onTemplateTap((
                amount: t['amount']!,
                category: t['category']!,
                memo: '',
              ));
            },
            onLongPress: () {
              ref
                  .read(homeViewModelProvider.notifier)
                  .dismissAutoSuggestion('${t['amount']}_${t['category']}');
            },
          );
        }),
      ],
    );
  }

  Widget _buildRecentSpace(List<ExpenseEntity> recentExpenses, bool isDark) {
    if (recentExpenses.isEmpty) {
      return Center(
        child: Text(
          '최근 내역이 없습니다.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSub),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recentExpenses.length,
      itemBuilder: (context, index) {
        final expense = recentExpenses[index];
        final cat = ExpenseCategory.values[expense.category];
        final title = (expense.memo.isNotEmpty) ? expense.memo : cat.label;

        return _buildCard(
          title: title,
          amount: expense.amount,
          isDark: isDark,
          onTap: () {
            widget.onTemplateTap((
              amount: expense.amount,
              category: expense.category,
              memo: expense.memo,
            ));
          },
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required int amount,
    required bool isDark,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextMain : AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${CurrencyFormatter.formatNumberOnly(amount)}원',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSub : AppColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
