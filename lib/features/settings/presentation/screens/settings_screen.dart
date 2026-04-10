import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/budget_edit_dialog.dart';
import '../widgets/settings_budget_tile.dart';
import '../widgets/settings_divider.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/settings_tap_tile.dart';
import '../widgets/carryover_toggle_section.dart';
import '../widgets/settings_time_picker_tile.dart';
import '../widgets/time_picker_bottom_sheet.dart';

/// 설정 화면 (U-19 ~ U-20)
/// 알림(점심/저녁), 다크모드, 앱 정보 항목을 ListView로 나열한다
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                '설정',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                ),
              ),
            ),
            // 설정 항목 목록
            Expanded(
              child: ListView(
                children: [
                  // ── 예산 관리 섹션 ─────────────────────────────────────
                  SettingsSectionHeader(label: '예산 관리', isDark: isDark),
                  SettingsBudgetTile(
                    budget: state.dailyBudget,
                    isDark: isDark,
                    onTap: () =>
                        _showBudgetEditDialog(context, state.dailyBudget, vm),
                  ),
                  SettingsDivider(isDark: isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: const CarryoverToggleSection(),
                  ),
                  SettingsDivider(isDark: isDark),

                  // ── 알림 섹션 ──────────────────────────────────────────
                  SettingsSectionHeader(label: '알림 설정', isDark: isDark),

                  // 점심 알림
                  SettingsSwitchTile(
                    label: '점심 알림',
                    value: state.lunchEnabled,
                    onChanged: vm.toggleLunch,
                  ),
                  if (state.lunchEnabled) ...[
                    SettingsDivider(isDark: isDark),
                    SettingsTimePickerTile(
                      label: '점심 시간',
                      time: state.lunchTime,
                      isDark: isDark,
                      onTap: () => _pickTime(
                        context,
                        state.lunchTime,
                        vm.updateLunchTime,
                      ),
                    ),
                  ],
                  SettingsDivider(isDark: isDark),

                  // 저녁 알림
                  SettingsSwitchTile(
                    label: '저녁 알림',
                    value: state.dinnerEnabled,
                    onChanged: vm.toggleDinner,
                  ),
                  if (state.dinnerEnabled) ...[
                    SettingsDivider(isDark: isDark),
                    SettingsTimePickerTile(
                      label: '저녁 시간',
                      time: state.dinnerTime,
                      isDark: isDark,
                      onTap: () => _pickTime(
                        context,
                        state.dinnerTime,
                        vm.updateDinnerTime,
                      ),
                    ),
                  ],
                  SettingsDivider(isDark: isDark),

                  // ── 디스플레이 섹션 ────────────────────────────────────
                  SettingsSectionHeader(label: '디스플레이', isDark: isDark),
                  SettingsSwitchTile(
                    label: '다크 모드',
                    value: state.isDarkMode,
                    onChanged: vm.toggleDarkMode,
                  ),
                  SettingsDivider(isDark: isDark),

                  // ── 홈 위젯 섹션 (비활성) ──────────────────────────────
                  // SettingsSectionHeader(label: '홈 위젯', isDark: isDark),
                  // WidgetPreviewSection(isDark: isDark),
                  // SettingsDivider(isDark: isDark),

                  // ── 앱 정보 섹션 ───────────────────────────────────────
                  SettingsSectionHeader(label: '앱 정보', isDark: isDark),
                  const SettingsTapTile(label: '버전', trailing: '1.0.0'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 일일 예산 편집 다이얼로그를 표시한다
  Future<void> _showBudgetEditDialog(
    BuildContext context,
    int currentBudget,
    SettingsViewModel vm,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => BudgetEditDialog(initialBudget: currentBudget),
    );
    if (result != null && result > 0) {
      await vm.setDailyBudget(result);
    }
  }

  /// 시간 선택 BottomSheet를 표시하고 선택된 시간을 콜백으로 전달한다
  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initialTime,
    Future<void> Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TimePickerBottomSheet(initialTime: initialTime),
    );
    if (picked != null) {
      await onPicked(picked);
    }
  }
}
