import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'widget_preview_card.dart';

/// 홈 위젯 미리보기 섹션
/// 소형/중형 탭 전환 및 선택된 사이즈의 WidgetPreviewCard를 보여준다
class WidgetPreviewSection extends StatefulWidget {
  final bool isDark;

  const WidgetPreviewSection({super.key, required this.isDark});

  @override
  State<WidgetPreviewSection> createState() => _WidgetPreviewSectionState();
}

class _WidgetPreviewSectionState extends State<WidgetPreviewSection> {
  /// 현재 선택된 위젯 사이즈 — 기본값: 소형
  WidgetSize _selectedSize = WidgetSize.small;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final selectedBg = isDark ? AppColors.darkSurface : AppColors.primaryLight;
    final unselectedBg = isDark ? AppColors.darkBackground : AppColors.background;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 소형/중형 탭 버튼 Row
          Row(
            children: [
              _SizeTabButton(
                label: '소형',
                isSelected: _selectedSize == WidgetSize.small,
                isDark: isDark,
                selectedBg: selectedBg,
                unselectedBg: unselectedBg,
                borderColor: borderColor,
                selectedTextColor: AppColors.primary,
                unselectedTextColor: textSubColor,
                onTap: () => setState(() => _selectedSize = WidgetSize.small),
              ),
              const SizedBox(width: 8),
              _SizeTabButton(
                label: '중형',
                isSelected: _selectedSize == WidgetSize.medium,
                isDark: isDark,
                selectedBg: selectedBg,
                unselectedBg: unselectedBg,
                borderColor: borderColor,
                selectedTextColor: AppColors.primary,
                unselectedTextColor: textSubColor,
                onTap: () => setState(() => _selectedSize = WidgetSize.medium),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 선택된 사이즈의 위젯 미리보기 — 가운데 정렬
          Center(
            child: WidgetPreviewCard(size: _selectedSize, isDark: isDark),
          ),
          const SizedBox(height: 12),

          // 안내 문구
          Text(
            '홈 화면에 위젯을 추가하면 잔액을 바로 확인할 수 있어요',
            style: AppTypography.bodySmall.copyWith(color: textSubColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 소형/중형 사이즈 탭 버튼
// ─────────────────────────────────────────────────────────────────────────────

class _SizeTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color selectedBg;
  final Color unselectedBg;
  final Color borderColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  const _SizeTabButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.selectedBg,
    required this.unselectedBg,
    required this.borderColor,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: '$label 위젯',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? selectedTextColor : unselectedTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
