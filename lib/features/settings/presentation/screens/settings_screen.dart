import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/settings_view_model.dart';

/// 설정 화면 (U-19 ~ U-20)
/// 알림, 다크모드, 데이터 관리, 앱 정보 항목을 ListView로 나열한다
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
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
                  // ── 알림 섹션 ──────────────────────────────────────────
                  _SettingsSwitchTile(
                    label: '매일 알림',
                    value: state.isNotificationEnabled,
                    onChanged: ref
                        .read(settingsViewModelProvider.notifier)
                        .toggleNotification,
                  ),
                  _divider(isDark),
                  _SettingsTapTile(
                    label: '알림 시간',
                    trailing:
                        '${state.notificationTime.hour.toString().padLeft(2, '0')}:${state.notificationTime.minute.toString().padLeft(2, '0')} >',
                    onTap: () => _pickTime(context, state, ref),
                  ),
                  _divider(isDark),

                  // ── 데이터 섹션 ────────────────────────────────────────
                  // _SettingsTapTile(
                  //   label: '데이터 백업',
                  //   trailing: '>',
                  //   onTap: () => _showBackupInfo(context),
                  // ),
                  // _divider(isDark),
                  // _SettingsTapTile(
                  //   label: '데이터 초기화',
                  //   labelColor: AppColors.statusDanger,
                  //   trailing: '>',
                  //   onTap: () => _showResetDialog(context),
                  // ),
                  // _divider(isDark),

                  // ── 디스플레이 섹션 ────────────────────────────────────
                  _SettingsSwitchTile(
                    label: '다크 모드',
                    value: state.isDarkMode,
                    onChanged: ref
                        .read(settingsViewModelProvider.notifier)
                        .toggleDarkMode,
                  ),
                  _divider(isDark),

                  // ── 앱 정보 섹션 ───────────────────────────────────────
                  _SettingsTapTile(
                    label: '버전',
                    trailing: '1.0.0',
                    // 탭 불가 항목 — onTap 없음
                  ),
                  // _divider(isDark),
                  // _SettingsTapTile(
                  //   label: '개인정보 처리방침',
                  //   trailing: '>',
                  //   onTap: () => _showPrivacyPolicy(context),
                  // ),
                  // _divider(isDark),
                  // _SettingsTapTile(
                  //   label: '오픈소스 라이선스',
                  //   trailing: '>',
                  //   onTap: () => showLicensePage(
                  //     context: context,
                  //     applicationName: '하루 만원',
                  //     applicationVersion: '1.0.0',
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 구분선 위젯
  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.darkDivider : AppColors.divider,
      indent: 20,
      endIndent: 20,
    );
  }

  /// 알림 시간 TimePicker
  Future<void> _pickTime(
    BuildContext context,
    SettingsState state,
    WidgetRef ref,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: state.notificationTime,
      helpText: '알림 시간 선택',
      confirmText: '확인',
      cancelText: '취소',
    );
    if (picked != null) {
      ref
          .read(settingsViewModelProvider.notifier)
          .updateNotificationTime(picked);
    }
  }

  /// 데이터 백업 안내 다이얼로그
  void _showBackupInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '데이터 백업',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextMain
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '현재 버전에서는 자동 백업을 지원하지 않습니다.\n추후 업데이트를 통해 제공될 예정입니다.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSub
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 데이터 초기화 확인 다이얼로그
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '데이터 초기화',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextMain
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '모든 지출 내역과 도토리 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSub
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 실제 초기화 로직 연결
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('데이터가 초기화되었습니다.')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.budgetDanger,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('초기화'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 개인정보 처리방침 안내
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '개인정보 처리방침',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextMain
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '하루 만원은 사용자의 개인정보를 수집하지 않습니다.\n모든 데이터는 기기 내에 저장됩니다.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSub
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: Switch 토글 항목
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsSwitchTile extends ConsumerWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
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
                activeThumbColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 탭 가능한 일반 항목
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTapTile extends StatelessWidget {
  final String label;
  final String trailing;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _SettingsTapTile({
    required this.label,
    required this.trailing,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveLabelColor =
        labelColor ?? (isDark ? AppColors.darkTextMain : AppColors.textMain);

    return Semantics(
      button: onTap != null,
      label: '$label $trailing',
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyLarge.copyWith(
                      color: effectiveLabelColor,
                    ),
                  ),
                ),
                Text(
                  trailing,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSub : AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
