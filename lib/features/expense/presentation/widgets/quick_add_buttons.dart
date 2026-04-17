import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class QuickAddButtons extends StatelessWidget {
  final bool isDark;
  final void Function(int amount) onAdd;

  const QuickAddButtons({
    super.key,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuickAddBtn(label: '+ 1천', amount: 1000, isDark: isDark, onAdd: onAdd),
        const SizedBox(width: AppSpacing.md),
        _QuickAddBtn(label: '+ 5천', amount: 5000, isDark: isDark, onAdd: onAdd),
        const SizedBox(width: AppSpacing.md),
        _QuickAddBtn(
          label: '+ 1만',
          amount: 10000,
          isDark: isDark,
          onAdd: onAdd,
        ),
      ],
    );
  }
}

class _QuickAddBtn extends StatelessWidget {
  final String label;
  final int amount;
  final bool isDark;
  final void Function(int) onAdd;

  const _QuickAddBtn({
    required this.label,
    required this.amount,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${label.replaceAll('+ ', '')}원 추가',
      child: InkWell(
        onTap: () => onAdd(amount),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
