import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 일일 예산 표시 및 변경 타일
class SettingsBudgetTile extends StatelessWidget {
  final int budget;
  final bool isDark;
  final VoidCallback onTap;

  const SettingsBudgetTile({
    super.key,
    required this.budget,
    required this.isDark,
    required this.onTap,
  });

  String get _formattedBudget {
    if (budget >= 10000 && budget % 10000 == 0) {
      return '${budget ~/ 10000}만원';
    }
    if (budget >= 1000) {
      final formatted = budget.toString().replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (m) => ',',
          );
      return '$formatted원';
    }
    return '$budget원';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '일일 예산 $_formattedBudget, 변경',
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '일일 예산',
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                    ),
                  ),
                ),
                Text(
                  _formattedBudget,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
