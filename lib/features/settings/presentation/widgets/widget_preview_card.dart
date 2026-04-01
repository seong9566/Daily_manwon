import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 홈 위젯 사이즈 정의
/// small: 2×2 정사각형, medium: 4×2 가로형
enum WidgetSize { small, medium }

/// 홈 위젯 미리보기 카드
/// 설정 화면에서 위젯이 어떻게 보이는지 목업으로 보여준다
class WidgetPreviewCard extends StatelessWidget {
  final WidgetSize size;
  final bool isDark;

  const WidgetPreviewCard({
    super.key,
    required this.size,
    required this.isDark,
  });

  /// 사이즈에 따른 카드 너비 — small: 160, medium: 320
  double get _width => size == WidgetSize.small ? 160 : 320;

  /// 카드 높이는 두 사이즈 모두 160 고정
  double get _height => 160;

  /// 목업 진행도 (73%)
  static const double _progress = 0.73;

  @override
  Widget build(BuildContext context) {
    // 라이트/다크에 따른 색상 분기
    final bgColor = isDark ? AppColors.darkCard : AppColors.background;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final progressTrackColor = isDark
        ? AppColors.darkDivider
        : AppColors.divider;

    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // 다크모드에서는 그림자를 더 옅게 처리
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 앱 이름 라벨 — 상단 좌측
          Text(
            '하루 만원',
            style: AppTypography.bodySmall.copyWith(
              color: textSubColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // 남은 금액 — 화면 중앙 핵심 수치
          Center(
            child: Text(
              '₩7,300',
              style: AppTypography.displayLarge.copyWith(
                color: textMainColor,
                // 소형 위젯에서는 폰트 크기를 줄여 잘림 방지
                fontSize: size == WidgetSize.small ? 32 : 40,
              ),
            ),
          ),
          const Spacer(),

          // 선형 프로그레스 바 — budgetComfortable 색상
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: progressTrackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.budgetComfortable,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 상태 텍스트 — 하단
          Text(
            '오늘도 잘 하고 있어요',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.budgetComfortable,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
