import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// 금액 차감 카운트다운 애니메이션 위젯 (U-05)
/// 이전 금액 → 새 금액으로 숫자가 빠르게 변화하는 효과
class BudgetCountdown extends StatefulWidget {
  final int targetAmount;
  final Duration duration;

  const BudgetCountdown({
    super.key,
    required this.targetAmount,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<BudgetCountdown> createState() => _BudgetCountdownState();
}

class _BudgetCountdownState extends State<BudgetCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _previousAmount;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _previousAmount = widget.targetAmount;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = IntTween(
      begin: _previousAmount,
      end: widget.targetAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant BudgetCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetAmount != widget.targetAmount) {
      _previousAmount = oldWidget.targetAmount;
      _animation = IntTween(
        begin: _previousAmount,
        end: widget.targetAmount,
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '₩${CurrencyFormatter.formatNumberOnly(_animation.value)}',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextMain : AppColors.textMain,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }
}
