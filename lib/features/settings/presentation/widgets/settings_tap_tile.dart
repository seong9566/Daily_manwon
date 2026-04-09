import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 탭 가능한 일반 설정 항목 (우측에 텍스트 trailing 표시)
class SettingsTapTile extends StatelessWidget {
  final String label;
  final String trailing;

  const SettingsTapTile({
    super.key,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '$label $trailing',
      child: SizedBox(
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
                trailing,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
