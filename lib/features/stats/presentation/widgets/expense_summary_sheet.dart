import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense_summary.dart';
import '../viewmodels/stats_view_model.dart';

/// 주간/월간 요약 바텀시트
/// [showExpenseSummarySheet]를 통해 호출한다
Future<void> showExpenseSummarySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExpenseSummarySheetBody(),
  );
}

class _ExpenseSummarySheetBody extends ConsumerWidget {
  const _ExpenseSummarySheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final vm = ref.read(statsViewModelProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FutureBuilder(
        future: Future.wait([
          vm.getWeeklySummary(),
          vm.getMonthlySummary(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return const SizedBox(
                height: 120,
                child: Center(child: Text('데이터를 불러오지 못했습니다.')),
              );
            }
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final weekly = snapshot.data![0];
          final monthly = snapshot.data![1];
          final selectedMonth =
              ref.read(statsViewModelProvider).requireValue.selectedMonth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                title: '이번 주',
                titleColor: AppColors.budgetWarning,
                summary: weekly,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                title: '${selectedMonth.month}월',
                titleColor: isDark ? AppColors.darkTextMain : AppColors.textMain,
                summary: monthly,
                isDark: isDark,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final ExpenseSummary summary;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.titleColor,
    required this.summary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardWarm;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    final topCategory = summary.topCategoryIndex != null
        ? ExpenseCategory.values[summary.topCategoryIndex!]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          _Row(
            label: '총 지출',
            value: CurrencyFormatter.format(summary.totalSpent),
            isFirst: true,
            textMain: textMain,
            textSub: textSub,
            dividerColor: dividerColor,
          ),
          _Row(
            label: '예산 달성일',
            value: '${summary.successDays}일 / ${summary.totalDays}일',
            valueColor: AppColors.statusComfortableStrong,
            textMain: textMain,
            textSub: textSub,
            dividerColor: dividerColor,
          ),
          _Row(
            label: '가장 많은 카테고리',
            value: topCategory != null
                ? '${topCategory.emoji} ${topCategory.label}'
                : '—',
            isLast: true,
            textMain: textMain,
            textSub: textSub,
            dividerColor: dividerColor,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isFirst;
  final bool isLast;
  final Color textMain;
  final Color textSub;
  final Color dividerColor;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.isFirst = false,
    this.isLast = false,
    required this.textMain,
    required this.textSub,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst) Divider(color: dividerColor, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: textSub,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  color: valueColor ?? textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
