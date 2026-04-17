import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';

class AmountDisplaySection extends StatelessWidget {
  final String amountString;
  final int amount;
  final bool addToFavorite;
  final Animation<double> shakeAnim;
  final Animation<double> pulseAnim;
  final VoidCallback onFavoriteTap;
  final bool isDark;

  const AmountDisplaySection({
    super.key,
    required this.amountString,
    required this.amount,
    required this.addToFavorite,
    required this.shakeAnim,
    required this.pulseAnim,
    required this.onFavoriteTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([shakeAnim, pulseAnim]),
          builder: (context, child) => Transform.translate(
            offset: Offset(shakeAnim.value, 0),
            child: Transform.scale(scale: pulseAnim.value, child: child),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.amountPadding),
            child: Semantics(
              label: amountString.isEmpty
                  ? '입력 금액 없음'
                  : '입력 금액 ${CurrencyFormatter.formatWithWon(amount)}',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    amountString.isEmpty
                        ? '0'
                        : CurrencyFormatter.formatNumberOnly(amount),
                    style: AppTypography.displayAmount.copyWith(
                      color: amountString.isEmpty
                          ? textSubColor
                          : textMainColor,
                    ),
                  ),
                  AnimatedSize(
                    duration: AppDurations.fast,
                    curve: Curves.easeOut,
                    child: amountString.isNotEmpty
                        ? Text(
                            '원',
                            style: AppTypography.amountUnit.copyWith(
                              color: textSubColor,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          top: -24,
          left: 16,
          child: Align(
            alignment: Alignment.topLeft,
            child: Semantics(
              button: true,
              label: addToFavorite ? '즐겨찾기 해제' : '즐겨찾기에 추가',
              child: GestureDetector(
                onTap: () {
                  onFavoriteTap();
                  HapticFeedback.lightImpact();
                },
                child: SizedBox(
                  width: AppSpacing.touchTarget,
                  height: AppSpacing.touchTarget,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: AppDurations.normal,
                      child: Icon(
                        addToFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        key: ValueKey(addToFavorite),
                        size: 24,
                        color: addToFavorite ? Colors.amber : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
