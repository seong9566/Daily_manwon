import 'package:daily_manwon/core/services/notification_service.dart';
import 'package:daily_manwon/core/providers/budget_change_provider.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:daily_manwon/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:daily_manwon/features/settings/domain/usecases/get_notification_settings_use_case.dart';
import 'package:daily_manwon/features/settings/domain/usecases/save_notification_settings_use_case.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme_provider.dart';
import 'settings_state.dart';

part 'settings_view_model.g.dart';

@Riverpod(keepAlive: true)
class SettingsViewModel extends _$SettingsViewModel {
  GetNotificationSettingsUseCase get _getSettingsUseCase =>
      GetIt.instance<GetNotificationSettingsUseCase>();

  SaveNotificationSettingsUseCase get _saveSettingsUseCase =>
      GetIt.instance<SaveNotificationSettingsUseCase>();

  NotificationService get _notifService =>
      GetIt.instance<NotificationService>();

  SettingsRepository get _settingsRepository =>
      GetIt.instance<SettingsRepository>();

  /// 각 필드별 사용자 직접 변경 여부 — 초기 DB 로드와의 race condition 방지.
  bool _lunchEnabledInteracted = false;
  bool _lunchTimeInteracted = false;
  bool _dinnerEnabledInteracted = false;
  bool _dinnerTimeInteracted = false;
  bool _carryoverInteracted = false;

  /// DB에서 로드한 설정값 캐시.
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
      await _loadCarryoverEnabled();
    });

    return SettingsState(isDarkMode: initialTheme == ThemeMode.dark);
  }

  /// DB에서 알림 설정을 로드하여 state에 반영한다.
  Future<void> loadNotificationSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final settings = await _getSettingsUseCase.execute();
      _loadedSettings = settings;
      state = state.copyWith(
        lunchEnabled:
            _lunchEnabledInteracted ? state.lunchEnabled : settings.lunchEnabled,
        lunchTime: _lunchTimeInteracted
            ? state.lunchTime
            : settings.lunchTimeOfDay,
        dinnerEnabled: _dinnerEnabledInteracted
            ? state.dinnerEnabled
            : settings.dinnerEnabled,
        dinnerTime: _dinnerTimeInteracted
            ? state.dinnerTime
            : settings.dinnerTimeOfDay,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

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

  Future<void> updateLunchTime(TimeOfDay time) async {
    _lunchTimeInteracted = true;
    state = state.copyWith(lunchTime: time);
    if (state.lunchEnabled) {
      await _notifService.scheduleLunch(time);
    }
    await _saveNotificationSettings();
  }

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

  Future<void> updateDinnerTime(TimeOfDay time) async {
    _dinnerTimeInteracted = true;
    state = state.copyWith(dinnerTime: time);
    if (state.dinnerEnabled) {
      await _notifService.scheduleDinner(time);
    }
    await _saveNotificationSettings();
  }

  void toggleDarkMode(bool value) {
    ref.read(appThemeModeProvider.notifier).setMode(
          value ? ThemeMode.dark : ThemeMode.light,
        );
  }

  Future<void> _loadDailyBudget() async {
    try {
      final budget = await _settingsRepository.getDailyBudget();
      state = state.copyWith(dailyBudget: budget);
    } catch (_) {}
  }

  Future<void> setDailyBudget(int amount) async {
    state = state.copyWith(dailyBudget: amount);
    await _settingsRepository.setDailyBudget(amount);
    await GetIt.instance<DailyBudgetRepository>().updateTodayBaseAmount(amount);
    ref.read(budgetChangeProvider.notifier).increment();
  }

  Future<void> _loadCarryoverEnabled() async {
    try {
      final enabled = await _settingsRepository.getCarryoverEnabled();
      if (!_carryoverInteracted) {
        state = state.copyWith(carryoverEnabled: enabled);
      }
    } catch (_) {}
  }

  Future<void> setCarryoverEnabled(bool enabled) async {
    _carryoverInteracted = true;
    await _settingsRepository.setCarryoverEnabled(enabled);
    state = state.copyWith(carryoverEnabled: enabled);
  }

  Future<void> _saveNotificationSettings() async {
    final loaded = _loadedSettings ?? await _getSettingsUseCase.execute();
    final entity = NotificationSettingsEntity(
      lunchEnabled:
          _lunchEnabledInteracted ? state.lunchEnabled : loaded.lunchEnabled,
      lunchTimeHour:
          _lunchTimeInteracted ? state.lunchTime.hour : loaded.lunchTimeHour,
      lunchTimeMinute: _lunchTimeInteracted
          ? state.lunchTime.minute
          : loaded.lunchTimeMinute,
      dinnerEnabled: _dinnerEnabledInteracted
          ? state.dinnerEnabled
          : loaded.dinnerEnabled,
      dinnerTimeHour: _dinnerTimeInteracted
          ? state.dinnerTime.hour
          : loaded.dinnerTimeHour,
      dinnerTimeMinute: _dinnerTimeInteracted
          ? state.dinnerTime.minute
          : loaded.dinnerTimeMinute,
    );
    await _saveSettingsUseCase.execute(entity);
  }
}
