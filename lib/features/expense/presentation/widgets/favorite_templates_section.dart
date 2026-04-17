import 'package:daily_manwon/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/favorite_expense.dart';

/// 수동·자동학습 칩(자주 쓰는 탭) 및 최근 내역 탭을 제공하는 섹션
class FavoriteTemplatesSection extends ConsumerStatefulWidget {
  /// 템플릿·내역 탭 시 호출 — amount, category, memo 전달
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

    final favorites = homeState.favorites;
    final recentExpenses = homeState.recentExpenses;

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
          height: 70,
          child: _selectedTabIndex == 0
              ? _buildFavoritesSpace(favorites, isDark)
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

  // ── "자주 쓰는" 탭 ────────────────────────────────────────────────────────

  Widget _buildFavoritesSpace(
    List<FavoriteExpenseEntity> favorites,
    bool isDark,
  ) {
    if (favorites.isEmpty) {
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
      children: favorites.map((fav) {
        final cat = ExpenseCategory.values[fav.category];
        final title = fav.memo.isNotEmpty ? fav.memo : cat.label;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: _TemplateChip(
              title: title,
              amount: fav.amount,
              cat: cat,
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
                  memo: fav.memo,
                ));
              },
              onDelete: () => ref
                  .read(homeViewModelProvider.notifier)
                  .deleteFavorite(fav.id),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── "최근 내역" 탭 ────────────────────────────────────────────────────────

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
        final title = expense.memo.isNotEmpty ? expense.memo : cat.label;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: _TemplateChip(
              title: title,
              amount: expense.amount,
              cat: cat,
              isDark: isDark,
              onTap: () => widget.onTemplateTap((
                amount: expense.amount,
                category: expense.category,
                memo: expense.memo,
              )),
            ),
          ),
        );
      },
    );
  }
}

// ── 공통 템플릿 칩 ─────────────────────────────────────────────────────────

/// 템플릿/내역 공용 칩 디자인
class _TemplateChip extends StatelessWidget {
  final String title;
  final int amount;
  final ExpenseCategory cat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TemplateChip({
    required this.title,
    required this.amount,
    required this.cat,
    required this.isDark,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5);
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              cat.assetPath,
              width: 18,
              height: 18,
              color: isDark ? AppColors.darkTextMain : null,
              colorBlendMode: isDark ? BlendMode.srcIn : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: textSubColor,
                    height: 1.2,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatWithWon(amount),
                  style: AppTypography.bodyMedium.copyWith(
                    color: textMainColor,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close_rounded, size: 14, color: textSubColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
