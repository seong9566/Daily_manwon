import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 홈 화면 잔액 부근에 표시되는 이월 배지
class CarryoverBadgeWidget extends StatelessWidget {
  const CarryoverBadgeWidget({super.key, required this.carryOver});

  final int carryOver;

  @override
  Widget build(BuildContext context) {
    if (carryOver == 0) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = carryOver > 0;
    final color = isPositive
        ? (isDark ? AppColors.budgetComfortableDark : AppColors.budgetComfortable)
        : (isDark ? AppColors.budgetDanger : AppColors.budgetDanger);
    final label = isPositive
        ? '+${CurrencyFormatter.formatWithWon(carryOver)} 이월'
        : '${CurrencyFormatter.formatWithWon(carryOver)} 초과이월';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: color),
      ),
    );
  }
}
