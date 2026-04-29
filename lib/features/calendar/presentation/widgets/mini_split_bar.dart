import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 이월 예산 미니 스플릿 바
///
/// - 음수 이월: 전폭 빨간 바 (budgetDanger)
/// - 양수 이월: 파랑(이월) + 초록(기본 예산) 비율 스플릿
///
/// 호출자는 `effectiveBudget != baseAmount` 조건을 확인한 뒤 전달한다.
class MiniSplitBar extends StatelessWidget {
  final int carryOver;
  final int effectiveBudget;

  const MiniSplitBar({
    super.key,
    required this.carryOver,
    required this.effectiveBudget,
  }) : assert(carryOver != 0, 'MiniSplitBar: carryOver must not be 0');

  @override
  Widget build(BuildContext context) {
    if (carryOver < 0) {
      // key 유지 — weekly_calendar_day_cell_test.dart가 'mini-split-bar-negative'를 assert
      return ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Container(
          key: const Key('mini-split-bar-negative'),
          width: 28,
          height: 3,
          color: AppColors.budgetDanger,
        ),
      );
    }

    final baseAmount = effectiveBudget - carryOver;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 28,
        height: 3,
        child: Row(
          children: [
            Flexible(
              flex: carryOver,
              child: Container(color: AppColors.accent),
            ),
            if (baseAmount > 0)
              Flexible(
                flex: baseAmount,
                child: Container(color: AppColors.statusComfortableStrong),
              ),
          ],
        ),
      ),
    );
  }
}
