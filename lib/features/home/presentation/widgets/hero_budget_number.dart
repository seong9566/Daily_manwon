import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 남은 예산을 크게 표시하는 히어로 위젯
/// 상태별로 색상과 웨이트가 달라지며, 금액 변경 시 카운팅 애니메이션이 적용됩니다.
class HeroBudgetNumber extends StatelessWidget {
  final int remainingBudget;

  const HeroBudgetNumber({super.key, required this.remainingBudget});

  /// 상태별 폰트 웨이트
  FontWeight _getFontWeight(int value) {
    if (value >= 5000) return FontWeight.w900;
    if (value >= 1000) return FontWeight.w800;
    return FontWeight.w700;
  }

  /// 상태별 색상
  Color _getColor(BuildContext context, int value) {
    if (value >= 5000) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? AppColors.budgetComfortableDark : AppColors.budgetComfortable;
    }
    if (value >= 1000) return AppColors.budgetWarning;
    if (value >= 0) return AppColors.budgetDanger;
    return AppColors.budgetOver;
  }

  @override
  Widget build(BuildContext context) {
    // TweenAnimationBuilder를 사용하여 현재 값에서 새로운 값으로 카운팅 애니메이션 적용
    return TweenAnimationBuilder<int>(
      // begin을 remainingBudget으로 두면 첫 렌더링 시에는 애니메이션 없이 렌더링되고,
      // 이후 remainingBudget이 변경되면 현재 값에서 새 값으로 부드럽게 카운팅됩니다.
      tween: IntTween(begin: remainingBudget, end: remainingBudget),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final formattedAmount = value < 0
            ? '-₩${CurrencyFormatter.formatNumberOnly(value.abs())}'
            : '₩${CurrencyFormatter.formatNumberOnly(value)}';

        Widget textWidget = Text(formattedAmount);

        // 위험/초과 상태: 흔들림(shake) 효과는 금액이 부족할 때의 경고성을 위해 유지
        if (value < 1000 && value >= 0) {
          textWidget = textWidget.animate(key: ValueKey('warn_$value')).shakeX(amount: 2, duration: 600.ms);
        } else if (value < 0) {
          textWidget = textWidget.animate(key: ValueKey('over_$value')).shakeX(amount: 4, hz: 4, duration: 400.ms);
        }

        // 폰트 크기 증감으로 인한 튐 현상을 방지하고자 크기는 60으로 고정하고,
        // AnimatedDefaultTextStyle을 통해 컬러와 웨이트만 부드럽게 전환
        return Semantics(
          label: '남은 예산 ${CurrencyFormatter.formatWithWon(remainingBudget)}',
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 44, // 폰트 크기를 고정하여 카운팅 시 레이아웃 흔들림 방지
              fontWeight: _getFontWeight(value),
              color: _getColor(context, value),
              height: 1.2,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            child: textWidget,
          ),
        );
      },
    );
  }
}
