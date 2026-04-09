import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 설정 화면 구분선 위젯
class SettingsDivider extends StatelessWidget {
  final bool isDark;

  const SettingsDivider({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.darkDivider : AppColors.divider,
      indent: 20,
      endIndent: 20,
    );
  }
}
