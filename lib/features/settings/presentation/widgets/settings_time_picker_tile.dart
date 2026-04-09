import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 알림 시간 변경 타일
class SettingsTimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final bool isDark;
  final VoidCallback onTap;

  const SettingsTimePickerTile({
    super.key,
    required this.label,
    required this.time,
    required this.isDark,
    required this.onTap,
  });

  /// TimeOfDay를 'HH:mm' 형식으로 포맷한다
  String get _formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                ),
              ),
            ),
            Text(
              _formattedTime,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSub : AppColors.textSub,
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: '$label 변경',
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: isDark ? AppColors.white : AppColors.primary,
                ),
                child: Text(
                  '변경',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
