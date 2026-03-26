import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 남은 예산을 크게 표시하는 히어로 위젯
/// 상태별로 크기·색상·웨이트·모션이 달라진다 (디자인 가이드 Section 1)
class HeroBudgetNumber extends StatelessWidget {
  final int remainingBudget;

  const HeroBudgetNumber({super.key, required this.remainingBudget});

  /// 상태별 폰트 크기
  double get _fontSize {
    if (remainingBudget >= 5000) return 72;
    if (remainingBudget >= 1000) return 60;
    if (remainingBudget >= 0) return 52;
    return 48; // 초과
  }

  /// 상태별 폰트 웨이트
  FontWeight get _fontWeight {
    if (remainingBudget >= 5000) return FontWeight.w900;
    if (remainingBudget >= 1000) return FontWeight.w800;
    return FontWeight.w700;
  }

  /// 상태별 색상
  Color get _color {
    if (remainingBudget >= 5000) return AppColors.budgetComfortable;
    if (remainingBudget >= 1000) return AppColors.budgetWarning;
    if (remainingBudget >= 0) return AppColors.budgetDanger;
    return AppColors.budgetOver;
  }

  @override
  Widget build(BuildContext context) {
    final formattedAmount = remainingBudget < 0
        ? '-₩${CurrencyFormatter.formatNumberOnly(remainingBudget)}'
        : '₩${CurrencyFormatter.formatNumberOnly(remainingBudget)}';

    // 금액 변경 시 바운스 애니메이션 (Key를 통해 변경 감지)
    var textWidget = Text(formattedAmount)
        .animate(key: ValueKey(remainingBudget))
        .scale(
          begin: const Offset(1.08, 1.08),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.elasticOut,
        );

    // 위험/초과 상태: 떨림 효과 추가
    if (remainingBudget < 1000 && remainingBudget >= 0) {
      textWidget = textWidget.shakeX(amount: 2, duration: 600.ms);
    } else if (remainingBudget < 0) {
      textWidget = textWidget.shakeX(amount: 4, hz: 4, duration: 400.ms);
    }

    // AnimatedDefaultTextStyle은 Key를 변경하지 않아 부드러운 전환 유지
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: _fontSize,
        fontWeight: _fontWeight,
        color: _color,
        height: 1.2,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: textWidget,
    );
  }
}
