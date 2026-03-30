import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          '업적',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? AppColors.darkTextMain : AppColors.textMain,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      ),
      body: Center(
        child: Text(
          '업적/배지 화면',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextSub : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}
