import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 홈 위젯 목업 미리보기 위젯 (U-23)
///
/// 실제 home_widget 패키지 연동 없이 소형/중형 위젯 UI를 시각적으로 보여준다
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 타이틀
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(
            '위젯 미리보기',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.darkTextSub : AppColors.textSub,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 소형/중형 위젯 목업 가로 배치
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 소형 위젯 (2x2)
            _SmallWidgetMockup(isDark: isDark),
            const SizedBox(width: 12),
            // 중형 위젯 (4x2)
            Expanded(child: _MediumWidgetMockup(isDark: isDark)),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 소형 위젯 목업 (2x2)
// ─────────────────────────────────────────────────────────────────────────────

class _SmallWidgetMockup extends StatelessWidget {
  final bool isDark;

  const _SmallWidgetMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 다람쥐 아이콘
          const Text('🐿️', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          // 남은 금액
          Text(
            '3,200원',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          // 부제
          Text(
            '남았어요',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSub : AppColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 중형 위젯 목업 (4x2)
// ─────────────────────────────────────────────────────────────────────────────

class _MediumWidgetMockup extends StatelessWidget {
  final bool isDark;

  const _MediumWidgetMockup({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 상단 행: 타이틀 + 다람쥐
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '하루 만원',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text('🐿️', style: TextStyle(fontSize: 18)),
            ],
          ),

          // 중간: 남은 금액
          Text(
            '3,200원',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.textMain,
              fontSize: 22,
            ),
          ),

          // 하단 행: 진행 바 + 도토리
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 예산 사용률 바 (6800원 사용 / 10000원)
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 0.68,
                  backgroundColor:
                      isDark ? AppColors.darkDivider : AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation(AppColors.statusWarning),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '6,800원 사용',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                    ),
                  ),
                  const Spacer(),
                  const Text('🌰', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 2),
                  Text(
                    '12개',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
