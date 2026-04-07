import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 지출 카테고리 이모지 선택기
/// 5개 카테고리를 가로 Row로 배치하며 선택된 항목에 원형 배경을 강조한다
class CategorySelector extends StatelessWidget {
  /// 현재 선택된 카테고리
  final ExpenseCategory selectedCategory;

  /// 카테고리 변경 콜백
  final void Function(ExpenseCategory category) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ExpenseCategory.values.map((category) {
        final isSelected = category == selectedCategory;
        return _CategoryItem(
          emoji: category.emoji,
          label: category.label,
          isSelected: isSelected,
          isDark: isDark,
          chipColor: category.chipColor,
          onTap: () => onCategoryChanged(category),
        );
      }).toList(),
    );
  }
}

/// 개별 카테고리 아이템 — 이모지 + 레이블 + 선택 상태 표시
class _CategoryItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color chipColor;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.chipColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 선택 시 카테고리별 칩 배경색 (디자인 가이드 Section 5)
    final selectedBg = isDark ? AppColors.darkDivider : chipColor;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected
                      ? (isDark ? AppColors.darkTextMain : AppColors.textMain)
                      : (isDark ? AppColors.darkTextSub : AppColors.textSub),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
