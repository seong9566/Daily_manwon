import 'package:daily_manwon/core/services/notification_service.dart';
import 'package:daily_manwon/features/calendar/presentation/viewmodels/calendar_view_model.dart';
import 'package:daily_manwon/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:daily_manwon/features/settings/domain/usecases/get_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/domain/usecases/save_notification_settings_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/theme/theme_provider.dart';

/// 설정 화면의 UI 상태.
/// 점심/저녁 알림 2쌍 구조 + 다크모드 + 로딩 상태를 관리한다.
class SettingsState {
  final bool lunchEnabled;
  final TimeOfDay lunchTime;
  final bool dinnerEnabled;
  final TimeOfDay dinnerTime;
  final bool isDarkMode;

  /// 일일 예산 설정값 (원)
  final int dailyBudget;

  /// 알림 설정 로드/저장 중 로딩 인디케이터 표시 여부
  final bool isLoading;

  const SettingsState({
    this.lunchEnabled = false,
    this.lunchTime = const TimeOfDay(hour: 12, minute: 0),
    this.dinnerEnabled = false,
    this.dinnerTime = const TimeOfDay(hour: 20, minute: 0),
    this.isDarkMode = false,
    this.dailyBudget = 10000,
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? lunchEnabled,
    TimeOfDay? lunchTime,
    bool? dinnerEnabled,
    TimeOfDay? dinnerTime,
    bool? isDarkMode,
    int? dailyBudget,
    bool? isLoading,
  }) {
    return SettingsState(
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 설정 화면 ViewModel.
/// 알림 설정(점심/저녁 토글 + 시간)과 다크모드 상태를 관리한다.
class SettingsViewModel extends Notifier<SettingsState> {
  GetNotificationSettingsUseCase get _getSettingsUseCase =>
      GetIt.instance<GetNotificationSettingsUseCase>();

  SaveNotificationSettingsUseCase get _saveSettingsUseCase =>
      GetIt.instance<SaveNotificationSettingsUseCase>();

  NotificationService get _notifService =>
      GetIt.instance<NotificationService>();

  SettingsRepository get _settingsRepository =>
      GetIt.instance<SettingsRepository>();

  /// 각 필드별 사용자 직접 변경 여부 — 초기 DB 로드와의 race condition 방지.
  /// enabled와 time을 분리하여 토글만 눌렀을 때 기존 저장 시간이 유실되지 않도록 한다.
  bool _lunchEnabledInteracted = false;
  bool _lunchTimeInteracted = false;
  bool _dinnerEnabledInteracted = false;
  bool _dinnerTimeInteracted = false;

  /// DB에서 로드한 설정값 캐시.
  /// 초기 로드 완료 전 사용자가 저장 시도 시 미변경 필드의 DB 원본값을 보존한다.
  NotificationSettingsEntity? _loadedSettings;

  @override
  SettingsState build() {
    final initialTheme = ref.read(appThemeModeProvider);

    // ref.listen으로 테마 변경 감지 — watch 대신 사용하여 rebuild로 인한 알림 상태 리셋 방지
    ref.listen(appThemeModeProvider, (_, themeMode) {
      state = state.copyWith(isDarkMode: themeMode == ThemeMode.dark);
    });

    // build 완료 후 알림 설정과 일일 예산을 DB에서 비동기 로드 (최초 1회)
    Future.microtask(() async {
      await loadNotificationSettings();
      await _loadDailyBudget();
    });

    return SettingsState(isDarkMode: initialTheme == ThemeMode.dark);
  }

  /// DB에서 알림 설정을 로드하여 state에 반영한다.
  /// 사용자가 이미 값을 변경한 경우 알림 필드를 덮어쓰지 않는다.
  Future<void> loadNotificationSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final settings = await _getSettingsUseCase.execute();
      _loadedSettings = settings;
      // 사용자가 변경한 필드는 DB 값으로 덮어쓰지 않음 (미변경 필드만 hydrate)
      state = state.copyWith(
        lunchEnabled: _lunchEnabledInteracted ? state.lunchEnabled : settings.lunchEnabled,
        lunchTime: _lunchTimeInteracted ? state.lunchTime : settings.lunchTimeOfDay,
        dinnerEnabled: _dinnerEnabledInteracted ? state.dinnerEnabled : settings.dinnerEnabled,
        dinnerTime: _dinnerTimeInteracted ? state.dinnerTime : settings.dinnerTimeOfDay,
        isLoading: false,
      );
    } catch (_) {
      // 로드 실패 시 기본값 유지
      state = state.copyWith(isLoading: false);
    }
  }

  /// 점심 알림 활성화 토글.
  /// 활성화 시 알림 권한 요청 후 스케줄링, 비활성화 시 취소한다.
  /// 권한 거부 시 스위치를 false로 되돌린다.
  Future<void> toggleLunch(bool value) async {
    _lunchEnabledInteracted = true;
    state = state.copyWith(lunchEnabled: value);
    if (value) {
      final granted = await _notifService.requestPermission();
      if (!granted) {
        state = state.copyWith(lunchEnabled: false);
        await _saveNotificationSettings();
        return;
      }
      await _notifService.scheduleLunch(state.lunchTime);
    } else {
      await _notifService.cancelLunch();
    }
    await _saveNotificationSettings();
  }

  /// 점심 알림 시간 변경 후 재스케줄링한다.
  Future<void> updateLunchTime(TimeOfDay time) async {
    _lunchTimeInteracted = true;
    state = state.copyWith(lunchTime: time);
    if (state.lunchEnabled) {
      await _notifService.scheduleLunch(time);
    }
    await _saveNotificationSettings();
  }

  /// 저녁 알림 활성화 토글.
  /// 활성화 시 알림 권한 요청 후 스케줄링, 비활성화 시 취소한다.
  /// 권한 거부 시 스위치를 false로 되돌린다.
  Future<void> toggleDinner(bool value) async {
    _dinnerEnabledInteracted = true;
    state = state.copyWith(dinnerEnabled: value);
    if (value) {
      final granted = await _notifService.requestPermission();
      if (!granted) {
        state = state.copyWith(dinnerEnabled: false);
        await _saveNotificationSettings();
        return;
      }
      await _notifService.scheduleDinner(state.dinnerTime);
    } else {
      await _notifService.cancelDinner();
    }
    await _saveNotificationSettings();
  }

  /// 저녁 알림 시간 변경 후 재스케줄링한다.
  Future<void> updateDinnerTime(TimeOfDay time) async {
    _dinnerTimeInteracted = true;
    state = state.copyWith(dinnerTime: time);
    if (state.dinnerEnabled) {
      await _notifService.scheduleDinner(time);
    }
    await _saveNotificationSettings();
  }

  /// 다크모드 토글 — appThemeModeProvider를 통해 DB 저장까지 처리한다.
  void toggleDarkMode(bool value) {
    ref.read(appThemeModeProvider.notifier).setMode(
          value ? ThemeMode.dark : ThemeMode.light,
        );
  }

  /// 일일 예산 설정값을 DB에서 로드한다.
  Future<void> _loadDailyBudget() async {
    try {
      final budget = await _settingsRepository.getDailyBudget();
      state = state.copyWith(dailyBudget: budget);
    } catch (_) {
      // 로드 실패 시 기본값(10000) 유지
    }
  }

  /// 일일 예산을 변경하고 DB에 저장한다.
  /// 저장 후 홈/캘린더 화면이 즉시 새 예산을 반영하도록 Provider를 갱신한다.
  Future<void> setDailyBudget(int amount) async {
    state = state.copyWith(dailyBudget: amount);
    await _settingsRepository.setDailyBudget(amount);
    ref.invalidate(homeViewModelProvider);
    ref.invalidate(calendarViewModelProvider);
  }

  // ── private ──────────────────────────────────────────────────────────────

  /// 알림 설정을 DB에 저장한다.
  /// 초기 로드 미완료 상태에서 저장 시, 미변경 필드는 DB 원본값을 사용하여
  /// 기본값으로 기존 설정을 덮어쓰는 것을 방지한다.
  Future<void> _saveNotificationSettings() async {
    // 아직 초기 로드가 완료되지 않은 경우 DB에서 기존 값을 가져와 보존
    final loaded = _loadedSettings ?? await _getSettingsUseCase.execute();
    final entity = NotificationSettingsEntity(
      lunchEnabled: _lunchEnabledInteracted ? state.lunchEnabled : loaded.lunchEnabled,
      lunchTimeHour: _lunchTimeInteracted ? state.lunchTime.hour : loaded.lunchTimeHour,
      lunchTimeMinute: _lunchTimeInteracted ? state.lunchTime.minute : loaded.lunchTimeMinute,
      dinnerEnabled: _dinnerEnabledInteracted ? state.dinnerEnabled : loaded.dinnerEnabled,
      dinnerTimeHour: _dinnerTimeInteracted ? state.dinnerTime.hour : loaded.dinnerTimeHour,
      dinnerTimeMinute: _dinnerTimeInteracted ? state.dinnerTime.minute : loaded.dinnerTimeMinute,
    );
    await _saveSettingsUseCase.execute(entity);
  }
}

/// 설정 ViewModel Provider
final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
