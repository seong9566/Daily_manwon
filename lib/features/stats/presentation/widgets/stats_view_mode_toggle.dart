import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/stats_state.dart';

/// 통계 화면 월간/주간 전환 토글 버튼
/// 캘린더 화면의 ViewModeToggle과 동일한 디자인
class StatsViewModeToggle extends StatelessWidget {
  final StatsViewMode viewMode;
  final bool isDark;
  final VoidCallback onToggle;

  const StatsViewModeToggle({
    super.key,
    required this.viewMode,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: '월간',
            isSelected: viewMode == StatsViewMode.monthly,
            isDark: isDark,
            onTap: viewMode == StatsViewMode.monthly ? () {} : onToggle,
          ),
          _TabItem(
            label: '주간',
            isSelected: viewMode == StatsViewMode.weekly,
            isDark: isDark,
            onTap: viewMode == StatsViewMode.weekly ? () {} : onToggle,
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 60, minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.white : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected
                  ? (isDark ? AppColors.black : AppColors.white)
                  : (isDark ? AppColors.darkTextSub : AppColors.textSub),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
