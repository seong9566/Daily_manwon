import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool lunchEnabled,
    @Default(TimeOfDay(hour: 12, minute: 0)) TimeOfDay lunchTime,
    @Default(false) bool dinnerEnabled,
    @Default(TimeOfDay(hour: 20, minute: 0)) TimeOfDay dinnerTime,
    @Default(false) bool isDarkMode,
    @Default(10000) int dailyBudget,
    @Default(false) bool carryoverEnabled,
    @Default(false) bool isLoading,
  }) = _SettingsState;
}
