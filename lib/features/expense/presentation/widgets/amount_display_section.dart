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
        const SizedBox(
          width: double.infinity,
        ), // Stack이 전체 너비를 차지하도록 강제하여 즐겨찾기 버튼이 우측 상단에 고정되게 함
        AnimatedBuilder(
          animation: Listenable.merge([shakeAnim, pulseAnim]),
          builder: (context, child) => Transform.translate(
            offset: Offset(shakeAnim.value, 0),
            child: Transform.scale(scale: pulseAnim.value, child: child),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              // horizontal: AppSpacing.amountPadding,
              horizontal: 100,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
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
        ),
        Positioned(
          top: -16,
          right: 16,
          child: Align(
            child: Semantics(
              button: true,
              label: addToFavorite ? '즐겨찾기 해제' : '즐겨찾기에 추가',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  onFavoriteTap();
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: addToFavorite
                        ? Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1)
                        : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: addToFavorite
                          ? Colors.amber.withValues(alpha: 0.5)
                          : isDark
                          ? Colors.white12
                          : Colors.black12,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: AppDurations.normal,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          addToFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          key: ValueKey(addToFavorite),
                          size: 16,
                          color: addToFavorite ? Colors.amber : textSubColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedDefaultTextStyle(
                        duration: AppDurations.normal,
                        style: AppTypography.labelMedium.copyWith(
                          fontSize: 12,
                          color: addToFavorite
                              ? (isDark
                                    ? Colors.amber.shade300
                                    : Colors.amber.shade700)
                              : textSubColor,
                          fontWeight: addToFavorite
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        child: const Text("즐겨찾기"),
                      ),
                    ],
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
