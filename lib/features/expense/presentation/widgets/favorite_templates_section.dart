import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import '../../domain/entities/expense.dart';

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
    final recentExpenses = homeState.expenses;

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

  Widget _buildFavoritesSpace(List<dynamic> favorites, bool isDark) {
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
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: fav.isAuto
                ? _AutoChip(
                    fav: fav,
                    cat: cat,
                    isDark: isDark,
                    onTap: () => widget.onTemplateTap((
                          amount: fav.amount,
                          category: fav.category,
                          memo: fav.memo,
                        )),
                    onDelete: () => ref
                        .read(homeViewModelProvider.notifier)
                        .deleteFavorite(fav.id),
                  )
                : _ManualChip(
                    fav: fav,
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

        return _RecentCard(
          title: title,
          amount: expense.amount,
          isDark: isDark,
          onTap: () => widget.onTemplateTap((
                amount: expense.amount,
                category: expense.category,
                memo: expense.memo,
              )),
        );
      },
    );
  }
}

// ── 수동 즐겨찾기 칩 ─────────────────────────────────────────────────────────

/// 수동 즐겨찾기 칩 — 금액 단일 라벨, 카테고리 색상 배경
class _ManualChip extends StatelessWidget {
  final dynamic fav;
  final ExpenseCategory cat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ManualChip({
    required this.fav,
    required this.cat,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Image.asset(cat.assetPath, width: 18, height: 18),
      label: Text(
        _formatAmount(fav.amount),
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.darkTextMain : AppColors.textMain,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkCard : cat.chipColor,
      deleteIconColor: isDark ? AppColors.darkTextSub : AppColors.textSub,
      onPressed: onTap,
      onDeleted: onDelete,
    );
  }
}

// ── 자동학습 칩 ──────────────────────────────────────────────────────────────

/// 자동학습 칩 — 카테고리명 + 금액 2줄 라벨, primaryLight 배경
class _AutoChip extends StatelessWidget {
  final dynamic fav;
  final ExpenseCategory cat;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AutoChip({
    required this.fav,
    required this.cat,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Image.asset(
        cat.assetPath,
        width: 32,
        height: 32,
        color: isDark ? AppColors.darkTextMain : AppColors.textMain,
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(cat.label),
          Text(
            _formatAmount(fav.amount),
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryLight,
      deleteIconColor: isDark ? AppColors.darkTextSub : AppColors.textSub,
      onPressed: onTap,
      onDeleted: onDelete,
    );
  }
}

// ── 최근 내역 카드 ────────────────────────────────────────────────────────────

class _RecentCard extends StatelessWidget {
  final String title;
  final int amount;
  final bool isDark;
  final VoidCallback onTap;

  const _RecentCard({
    required this.title,
    required this.amount,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

// ── 공통 유틸 ─────────────────────────────────────────────────────────────────

String _formatAmount(int amount) {
  if (amount >= 10000) {
    return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
  }
  return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}원';
}
