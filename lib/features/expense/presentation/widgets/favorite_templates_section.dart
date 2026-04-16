import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';

/// 즐겨찾기 칩 목록 — 수동(isAuto=false)·자동(isAuto=true) 통합 표시
/// 비어 있으면 아무것도 렌더하지 않는다
class FavoriteTemplatesSection extends ConsumerWidget {
  final void Function(({int amount, int category, String memo})) onTemplateTap;

  const FavoriteTemplatesSection({super.key, required this.onTemplateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    if (homeState.isLoading) return const SizedBox.shrink();

    final favorites = homeState.favorites;
    if (favorites.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: favorites.map((fav) {
                final cat = ExpenseCategory.values[fav.category];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: fav.isAuto
                      ? _AutoChip(
                          fav: fav,
                          cat: cat,
                          isDark: isDark,
                          onTap: () => onTemplateTap((
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
                            onTemplateTap((
                              amount: fav.amount,
                              category: fav.category,
                              memo: fav.memo,
                            ));
                          },
                          onDelete: () => ref
                              .read(homeViewModelProvider.notifier)
                              .deleteFavorite(fav.id),
                        ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

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
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.primaryLight,
      deleteIconColor: isDark ? AppColors.darkTextSub : AppColors.textSub,
      onPressed: onTap,
      onDeleted: onDelete,
    );
  }
}

String _formatAmount(int amount) {
  if (amount >= 10000) {
    return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
  }
  return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}원';
}
