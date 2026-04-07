import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/widget_preview_card.dart';

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
                  // ── 알림 섹션 헤더 ──────────────────────────────────────
                  _SectionHeader(label: '알림 설정', isDark: isDark),

                  // ── 점심 알림 ───────────────────────────────────────────
                  _SettingsSwitchTile(
                    label: '점심 알림',
                    value: state.lunchEnabled,
                    onChanged: vm.toggleLunch,
                  ),
                  // 점심 활성화 시 시간 변경 버튼 노출
                  if (state.lunchEnabled) ...[
                    _divider(isDark),
                    _TimePickerTile(
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
                  _divider(isDark),

                  // ── 저녁 알림 ───────────────────────────────────────────
                  _SettingsSwitchTile(
                    label: '저녁 알림',
                    value: state.dinnerEnabled,
                    onChanged: vm.toggleDinner,
                  ),
                  // 저녁 활성화 시 시간 변경 버튼 노출
                  if (state.dinnerEnabled) ...[
                    _divider(isDark),
                    _TimePickerTile(
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
                  _divider(isDark),

                  // ── 디스플레이 섹션 ────────────────────────────────────
                  _SectionHeader(label: '디스플레이', isDark: isDark),
                  _SettingsSwitchTile(
                    label: '다크 모드',
                    value: state.isDarkMode,
                    onChanged: vm.toggleDarkMode,
                  ),
                  _divider(isDark),

                  // ── 홈 위젯 섹션 ───────────────────────────────────────
                  // _SectionHeader(label: '홈 위젯', isDark: isDark),
                  // _WidgetPreviewSection(isDark: isDark),
                  // _divider(isDark),

                  // ── 앱 정보 섹션 ───────────────────────────────────────
                  _SectionHeader(label: '앱 정보', isDark: isDark),
                  _SettingsTapTile(label: '버전', trailing: '1.0.0'),
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
      builder: (_) => _TimePickerBottomSheet(initialTime: initialTime),
    );
    if (picked != null) {
      await onPicked(picked);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 섹션 헤더
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.darkTextSub : AppColors.textSub,
          fontWeight: FontWeight.w600,
        ),
      ),
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
                activeThumbColor: isDark ? Colors.black : Colors.white,
                activeTrackColor: isDark ? Colors.white : Colors.black,
                inactiveThumbColor: isDark ? Colors.grey[400] : Colors.white,
                inactiveTrackColor: isDark
                    ? Colors.grey[800]
                    : Colors.grey[300],
                trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 알림 시간 변경 타일
// ─────────────────────────────────────────────────────────────────────────────

class _TimePickerTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final bool isDark;
  final VoidCallback onTap;

  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.isDark,
    required this.onTap,
  });

  /// TimeOfDay를 'HH:mm' 형식으로 포맷한다
  String get _formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
            Text(
              _formattedTime,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSub : AppColors.textSub,
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: '$label 변경',
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: isDark ? Colors.white : AppColors.primary,
                ),
                child: Text(
                  '변경',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 시간 선택 BottomSheet
// ─────────────────────────────────────────────────────────────────────────────

class _TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay initialTime;

  const _TimePickerBottomSheet({required this.initialTime});

  @override
  State<_TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<_TimePickerBottomSheet> {
  late int _selectedHour;
  late int _selectedMinute;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '알림 시간 선택',
                  style: AppTypography.titleMedium.copyWith(color: textMain),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 시/분 휠 선택기
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 선택 영역 강조 배경
                Container(
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 시 휠
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourController,
                        itemExtent: 44,
                        perspective: 0.003,
                        diameterRatio: 2.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _selectedHour = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: AppTypography.titleMedium.copyWith(
                                color: i == _selectedHour ? textMain : textSub,
                                fontWeight: i == _selectedHour
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          childCount: 24,
                        ),
                      ),
                    ),
                    // 구분자
                    Text(
                      ':',
                      style: AppTypography.titleMedium.copyWith(
                        color: textMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // 분 휠
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minuteController,
                        itemExtent: 44,
                        perspective: 0.003,
                        diameterRatio: 2.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _selectedMinute = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (_, i) => Center(
                            child: Text(
                              i.toString().padLeft(2, '0'),
                              style: AppTypography.titleMedium.copyWith(
                                color: i == _selectedMinute
                                    ? textMain
                                    : textSub,
                                fontWeight: i == _selectedMinute
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          childCount: 60,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 취소 / 확인 버튼
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
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
                      onPressed: () => Navigator.pop(
                        context,
                        TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkTextMain
                            : AppColors.textMain,
                        foregroundColor: isDark
                            ? AppColors.darkBackground
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '확인',
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.darkBackground
                              : Colors.white,
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

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 홈 위젯 미리보기 섹션
// ─────────────────────────────────────────────────────────────────────────────

/// 홈 위젯 미리보기 섹션
/// 소형/중형 탭 전환 및 선택된 사이즈의 WidgetPreviewCard를 보여준다
class _WidgetPreviewSection extends StatefulWidget {
  final bool isDark;

  const _WidgetPreviewSection({required this.isDark});

  @override
  State<_WidgetPreviewSection> createState() => _WidgetPreviewSectionState();
}

class _WidgetPreviewSectionState extends State<_WidgetPreviewSection> {
  /// 현재 선택된 위젯 사이즈 — 기본값: 소형
  WidgetSize _selectedSize = WidgetSize.small;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;
    final selectedBg = isDark ? AppColors.darkSurface : AppColors.primaryLight;
    final unselectedBg = isDark
        ? AppColors.darkBackground
        : AppColors.background;
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
// 내부 위젯: 사이즈 탭 버튼
// ─────────────────────────────────────────────────────────────────────────────

/// 소형/중형 선택을 위한 탭 버튼
/// 선택 여부에 따라 배경색과 텍스트 색상을 달리한다
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

// ─────────────────────────────────────────────────────────────────────────────
// 내부 위젯: 탭 가능한 일반 항목
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTapTile extends StatelessWidget {
  final String label;
  final String trailing;

  const _SettingsTapTile({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '$label $trailing',
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
                    color: isDark ? AppColors.darkTextMain : AppColors.textMain,
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
    );
  }
}
