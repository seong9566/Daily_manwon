import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/calendar_view_model.dart';

/// 월간/주간 탭 토글 위젯
class ViewModeToggle extends StatelessWidget {
  final CalendarViewMode mode;
  final ValueChanged<CalendarViewMode> onChanged;
  final bool isDark;

  const ViewModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
    required this.isDark,
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
            isSelected: mode == CalendarViewMode.monthly,
            onTap: () => onChanged(CalendarViewMode.monthly),
            isDark: isDark,
          ),
          _TabItem(
            label: '주간',
            isSelected: mode == CalendarViewMode.weekly,
            onTap: () => onChanged(CalendarViewMode.weekly),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
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
