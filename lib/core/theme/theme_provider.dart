import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/injection.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

part 'theme_provider.g.dart';

/// 앱 전체 테마 모드를 관리하는 Provider
/// DB에서 저장된 다크모드 설정을 로드하고, 변경 시 DB에 저장한다
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  /// DB에서 저장된 다크모드 설정을 로드하여 반영
  Future<void> loadFromDatabase() async {
    final repository = getIt<SettingsRepository>();
    final isDark = await repository.getIsDarkMode();
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// 다크/라이트 토글
  void toggle() {
    final newMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setMode(newMode);
  }

  /// 특정 모드로 설정하고 DB에 저장
  void setMode(ThemeMode mode) {
    state = mode;
    _persistToDatabase(mode == ThemeMode.dark);
  }

  /// DB에 비동기로 저장 (UI 블로킹 방지)
  Future<void> _persistToDatabase(bool isDark) async {
    final repository = getIt<SettingsRepository>();
    await repository.setIsDarkMode(value: isDark);
  }
}
