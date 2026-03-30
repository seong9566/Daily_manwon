import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 지출 금액 입력용 커스텀 숫자 키패드
/// 3×4 레이아웃: 1~9, 빈칸, 0, 백스페이스
class NumberKeypad extends StatelessWidget {
  /// 숫자 버튼 탭 콜백 (digit: "0"~"9")
  final void Function(String digit) onNumberPressed;

  /// 백스페이스 탭 콜백
  final VoidCallback onBackspacePressed;

  const NumberKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 키패드 레이아웃 정의: null = 빈 셀, 'back' = 백스페이스
    final keys = <String?>[
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      null, '0', 'back',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // 키 높이를 너비보다 살짝 작게 — 콤팩트한 키패드 느낌
        childAspectRatio: 1.4,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];

        // 빈 셀 — 하단 왼쪽 자리
        if (key == null) {
          return ExcludeSemantics(child: const SizedBox.shrink());
        }

        // 백스페이스 키
        if (key == 'back') {
          return Semantics(
            button: true,
            label: '지우기',
            child: _KeyCell(
              isDark: isDark,
              onTap: onBackspacePressed,
              child: Icon(
                Icons.backspace_outlined,
                size: 24,
                color: isDark ? AppColors.darkTextMain : AppColors.textMain,
              ),
            ),
          );
        }

        // 숫자 키
        return Semantics(
          button: true,
          label: key,
          child: _KeyCell(
            isDark: isDark,
            onTap: () => onNumberPressed(key),
            child: Text(
              key,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 22,
                color: isDark ? AppColors.darkTextMain : AppColors.textMain,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 개별 키 셀 위젯 — 터치 피드백 포함
class _KeyCell extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isDark;

  const _KeyCell({
    required this.child,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // 셀 배경은 투명 — 바텀시트 배경색을 그대로 사용
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: isDark
            ? AppColors.darkDivider.withAlpha(120)
            : AppColors.primary.withAlpha(60),
        highlightColor: Colors.transparent,
        child: Center(child: child),
      ),
    );
  }
}
