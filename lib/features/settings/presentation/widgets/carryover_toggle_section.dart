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
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextMain
                          : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '매주 일요일 초기화됩니다',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              toggled: enabled,
              label: '남은 예산 이월',
              child: Switch(
                value: enabled,
                onChanged: (value) async {
                  await ref
                      .read(settingsViewModelProvider.notifier)
                      .setCarryoverEnabled(value);
                  if (context.mounted) {
                    _showPolicyChangedDialog(context, isDark);
                  }
                },
                activeThumbColor: isDark ? AppColors.black : AppColors.white,
                activeTrackColor: isDark ? AppColors.white : AppColors.black,
                inactiveThumbColor: isDark ? Colors.grey[400] : AppColors.white,
                inactiveTrackColor: isDark
                    ? Colors.grey[800]
                    : Colors.grey[300],
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ),
          ],
        ),
        // 이월 ON일 때 시뮬레이션 카드
        if (enabled) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                ),
                const SizedBox(width: 8),
                Text(
                  '예) 일일 예산 10,000원\n오늘 3,000원 사용 시 → 내일 17,000원',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showPolicyChangedDialog(BuildContext context, bool isDark) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정책 변경',
                style: AppTypography.titleMedium.copyWith(color: textMain),
              ),
              const SizedBox(height: 12),
              Text(
                '내일부터 적용됩니다.\n오늘 예산은 유지됩니다.',
                style: AppTypography.bodyMedium.copyWith(
                  color: textSub,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    '확인',
                    style: AppTypography.labelMedium.copyWith(
                      color: textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
