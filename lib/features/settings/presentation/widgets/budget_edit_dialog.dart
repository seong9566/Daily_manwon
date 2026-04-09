import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 일일 예산 편집 다이얼로그
/// 저장 시 입력된 금액(int)을 pop하고, 취소 시 null을 반환한다
class BudgetEditDialog extends StatefulWidget {
  final int initialBudget;

  const BudgetEditDialog({super.key, required this.initialBudget});

  @override
  State<BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<BudgetEditDialog> {
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

    return AlertDialog(
      backgroundColor: bgColor,
      title: Text(
        '일일 예산 설정',
        style: AppTypography.titleMedium.copyWith(color: textMain),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '하루 사용할 예산을 입력해 주세요',
            style: AppTypography.bodySmall.copyWith(color: textSub),
          ),
          const SizedBox(height: 12),
          TextField(
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
                borderSide: BorderSide(color: AppColors.budgetDanger, width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '취소',
            style: AppTypography.labelMedium.copyWith(color: textSub),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            '저장',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.darkTextMain : AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
