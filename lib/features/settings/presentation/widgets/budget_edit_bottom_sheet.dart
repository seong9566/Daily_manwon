import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 일일 예산 편집 바텀시트
/// 저장 시 입력된 금액(int)을 pop하고, 취소 시 null을 반환한다
class BudgetEditBottomSheet extends StatefulWidget {
  final int initialBudget;

  const BudgetEditBottomSheet({super.key, required this.initialBudget});

  @override
  State<BudgetEditBottomSheet> createState() => _BudgetEditBottomSheetState();
}

class _BudgetEditBottomSheetState extends State<BudgetEditBottomSheet> {
  late final TextEditingController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialBudget.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.replaceAll(',', ''));
    if (value == null || value <= 0) {
      setState(() => _hasError = true);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '일일 예산 설정',
                  style: AppTypography.titleMedium.copyWith(color: textMain),
                ),
                const SizedBox(height: 4),
                Text(
                  '하루 사용할 예산을 입력해 주세요',
                  style: AppTypography.bodySmall.copyWith(color: textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 입력 필드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (_) {
                if (_hasError) setState(() => _hasError = false);
              },
              onSubmitted: (_) => _submit(),
              style: AppTypography.bodyLarge.copyWith(color: textMain),
              decoration: InputDecoration(
                suffixText: '원',
                suffixStyle: AppTypography.bodyLarge.copyWith(color: textSub),
                errorText: _hasError ? '유효한 금액을 입력해 주세요' : null,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: dividerColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkTextMain : AppColors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.budgetDanger),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.budgetDanger, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 취소 / 저장 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTypography.bodyLarge.copyWith(
                          color: textSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.darkTextMain : AppColors.textMain,
                        foregroundColor:
                            isDark ? AppColors.darkBackground : AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '저장',
                        style: AppTypography.bodyLarge.copyWith(
                          color:
                              isDark ? AppColors.darkBackground : AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
