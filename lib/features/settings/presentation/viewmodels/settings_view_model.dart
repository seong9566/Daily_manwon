import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';

/// 설정 화면의 UI 상태
class SettingsState {
  final bool isNotificationEnabled;
  final TimeOfDay notificationTime;
  final bool isDarkMode;

  const SettingsState({
    this.isNotificationEnabled = false,
    this.notificationTime = const TimeOfDay(hour: 21, minute: 0),
    this.isDarkMode = false,
  });

  SettingsState copyWith({
    bool? isNotificationEnabled,
    TimeOfDay? notificationTime,
    bool? isDarkMode,
  }) {
    return SettingsState(
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// 설정 화면 ViewModel
/// 알림 토글, 알림 시간, 다크모드 상태를 관리한다
class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // 초기 다크모드 상태는 appThemeModeProvider 기준으로 동기화
    final themeMode = ref.read(appThemeModeProvider);
    return SettingsState(
      isDarkMode: themeMode == ThemeMode.dark,
    );
  }

  /// 알림 활성화 토글
  void toggleNotification(bool value) {
    // MVP: 앱 내 상태만 관리 (flutter_local_notifications 미연동)
    state = state.copyWith(isNotificationEnabled: value);
  }

  /// 알림 시간 변경
  void updateNotificationTime(TimeOfDay time) {
    state = state.copyWith(notificationTime: time);
  }

  /// 다크모드 토글 — appThemeModeProvider와 연동하여 앱 전체 테마를 변경
  void toggleDarkMode(bool value) {
    state = state.copyWith(isDarkMode: value);
    ref.read(appThemeModeProvider.notifier).setMode(
        value ? ThemeMode.dark : ThemeMode.light);
  }
}

/// 설정 ViewModel Provider
final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
