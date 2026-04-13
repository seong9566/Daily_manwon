import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expense/domain/entities/expense.dart';

/// 지출 리스트 아이템 위젯 (U-08)
/// 이모지 + 카테고리명 + 시간 | 금액 | ↩ 반복 버튼(선택)
class ExpenseListItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback? onTap;

  /// 반복 버튼 콜백 — 제공 시 ↩ 버튼 표시, null이면 미표시
  final VoidCallback? onRepeat;

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
    this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.values[expense.category];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('HH:mm').format(expense.createdAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // 이모지 아이콘 (원형 배경)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : category.chipColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                category.assetPath,
                width: 24,
                height: 24,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            // 카테고리명 + 시간
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.memo.isNotEmpty ? expense.memo : category.label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(timeStr, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            // 금액
            Text(
              '-${CurrencyFormatter.formatNumberOnly(expense.amount)}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
