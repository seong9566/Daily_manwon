import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 지출 삭제 확인 다이얼로그를 표시하는 헬퍼 함수
/// 삭제 확인 시 true, 취소 시 false 또는 null 반환
Future<bool?> showExpenseDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => const ExpenseDeleteDialog(),
  );
}

/// 지출 삭제 확인 다이얼로그
class ExpenseDeleteDialog extends StatelessWidget {
  const ExpenseDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.trash,
              size: 36,
              color: AppColors.budgetDanger,
            ),
            const SizedBox(height: 12),
            Text(
              '정말 삭제할까요?',
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.darkTextMain : AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이 지출 기록이 사라져요',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSub : AppColors.textSub,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Semantics(
                      button: true,
                      label: '삭제 취소',
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '아니요',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSub
                                : AppColors.textSub,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: Semantics(
                      button: true,
                      label: '삭제 확인',
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.budgetDanger,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '삭제할게요',
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
