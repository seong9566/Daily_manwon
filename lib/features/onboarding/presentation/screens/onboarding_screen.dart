import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Center(
        child: Text(
          '온보딩 화면',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextSub : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}
