import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/settings_view_model.dart';

/// 설정 화면의 이월 정책 토글 섹션
class CarryoverToggleSection extends ConsumerWidget {
  const CarryoverToggleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = state.carryoverEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 토글 행
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '남은 예산 이월',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '매주 월요일 초기화됩니다',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              activeTrackColor: AppColors.budgetComfortable,
              onChanged: (value) async {
                await ref
                    .read(settingsViewModelProvider.notifier)
                    .setCarryoverEnabled(value);
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('정책 변경'),
                      content: const Text('내일부터 적용됩니다.\n오늘 예산은 유지됩니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
        // 이월 ON일 때 시뮬레이션 카드
        if (enabled) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.budgetComfortable.withValues(alpha: 0.15)
                  : AppColors.budgetComfortable.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.budgetComfortable,
                ),
                const SizedBox(width: 8),
                Text(
                  '예) 오늘 3,000원 사용 시 → 내일 17,000원',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.budgetComfortable,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
