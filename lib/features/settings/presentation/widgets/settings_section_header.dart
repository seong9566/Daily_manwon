import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 설정 화면 섹션 헤더 위젯
class SettingsSectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const SettingsSectionHeader({
    super.key,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.darkTextSub : AppColors.textSub,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
