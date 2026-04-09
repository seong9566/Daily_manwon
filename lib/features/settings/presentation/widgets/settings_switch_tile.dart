import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// 설정 화면 토글 스위치 항목
class SettingsSwitchTile extends ConsumerWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                ),
              ),
            ),
            Semantics(
              toggled: value,
              label: label,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: isDark ? AppColors.black : AppColors.white,
                activeTrackColor: isDark ? AppColors.white : AppColors.black,
                inactiveThumbColor: isDark ? Colors.grey[400] : AppColors.white,
                inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
                trackOutlineColor:
                    const WidgetStatePropertyAll(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
