import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 이월 예산 미니 스플릿 바 + 소비 진행 표시
///
/// - 전체 너비(28px) = effectiveBudget
/// - 컬러(좌측) = 잔여 예산 비율
///   - 양수 이월: 파랑(이월) + 초록(기본 예산) 스플릿
///   - 이월 없음(일요일) 또는 음수 이월 + 미초과: 단색 초록
/// - 회색(우측) = 사용한 금액 비율
/// - 초과 지출 또는 effectiveBudget <= 0: 전체 회색 (컬러 0)
class MiniSplitBar extends StatelessWidget {
  final int carryOver;
  final int effectiveBudget;
  final int totalSpent;

  const MiniSplitBar({
    super.key,
    required this.carryOver,
    required this.effectiveBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkDivider : AppColors.border;

    final remaining = effectiveBudget - totalSpent;
    final ratio = effectiveBudget > 0
        ? (remaining / effectiveBudget).clamp(0.0, 1.0)
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: 28,
        height: 3,
        child: Stack(
          children: [
            // 배경 (회색 — 사용한 금액 구간)
            Container(color: bgColor),
            // 컬러 레이어 (잔여 예산 구간, 좌측부터)
            if (ratio > 0)
              FractionallySizedBox(
                widthFactor: ratio,
                alignment: Alignment.centerLeft,
                child: _ColorFill(carryOver: carryOver, effectiveBudget: effectiveBudget),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorFill extends StatelessWidget {
  final int carryOver;
  final int effectiveBudget;

  // ignore: unused_element_parameter
  const _ColorFill({super.key, required this.carryOver, required this.effectiveBudget});

  @override
  Widget build(BuildContext context) {
    if (carryOver <= 0) {
      return Container(color: AppColors.statusComfortableStrong);
    }
    final baseAmount = effectiveBudget - carryOver;
    return Row(
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
    );
  }
}
