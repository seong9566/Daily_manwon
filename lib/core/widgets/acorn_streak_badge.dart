import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 발도장 수 + 연속 성공 표시 배지 (U-07)
///
/// 아이콘·수치·레이블이 묶인 칩 2개를 나란히 배치해
/// 각 숫자의 의미를 명확히 전달한다.
class AcornStreakBadge extends StatelessWidget {
  final int totalAcorns;
  final int streakDays;

  /// 첫 번째 칩의 레이블 (기본값: '발도장')
  /// 캘린더에서는 '이달 성공' 또는 '이번주 성공' 등으로 덮어쓴다
  final String rewardLabel;

  const AcornStreakBadge({
    super.key,
    required this.totalAcorns,
    required this.streakDays,
    this.rewardLabel = '발도장',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '$rewardLabel $totalAcorns개, 연속 $streakDays일',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatChip(
            icon: AppEmoji.rewardIcon,
            value: '$totalAcorns개',
            label: rewardLabel,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _StatChip(
            icon: AppEmoji.streakIcon,
            value: '$streakDays일',
            label: '연속 성공',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.background;
    final mainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final subColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    final isStreak = icon == AppEmoji.streakIcon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStreak)
                // 불꽃 아이콘은 원래 컬러(빨강) 유지 + 다크모드 그림자로 가독성 확보
                Text(
                  icon,
                  style: TextStyle(
                    fontSize: 14,
                    shadows: isDark
                        ? [
                            Shadow(
                              color: AppColors.white.withValues(alpha: 0.5),
                              blurRadius: 4,
                            )
                          ]
                        : null,
                  ),
                )
              else
                // 발도장 등 단색 아이콘은 테마 색상과 동기화
                ColorFiltered(
                  colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn),
                  child: Text(icon, style: const TextStyle(fontSize: 14)),
                ),
              const SizedBox(width: 4),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: mainColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: subColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
