import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SaveButton extends StatelessWidget {
  final bool canSave;
  final bool isSaving;
  final bool saveError;
  final bool isDark;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.canSave,
    required this.isSaving,
    required this.saveError,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? AppColors.darkBackground : AppColors.white;
    final bg = saveError
        ? AppColors.budgetDanger
        : (isDark ? AppColors.darkTextMain : AppColors.textMain);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Semantics(
        button: true,
        enabled: canSave,
        label: saveError ? '다시 시도' : (canSave ? '기록하기' : '금액을 입력해주세요'),
        child: AnimatedOpacity(
          opacity: canSave ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: canSave ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                disabledBackgroundColor: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: fg,
                      ),
                    )
                  : Text(
                      saveError ? '다시 시도' : '기록하기',
                      style: AppTypography.bodyLarge.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
