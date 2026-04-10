import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 새 주 시작 시 표시되는 전면 인터스티셜 위젯
class NewWeekInterstitialWidget extends StatelessWidget {
  const NewWeekInterstitialWidget({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 카드 탭은 닫기 방지
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/character/new_week_clean.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '새로운 한 주가 시작됐어!',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘부터 다시 10,000원',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.budgetComfortable,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: onDismiss,
                      child: Text(
                        '시작하기',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
          ),
        ),
      ),
    );
  }
}
