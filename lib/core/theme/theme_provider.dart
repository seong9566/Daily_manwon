import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// 앱 전체 테마 모드를 관리하는 Provider
/// 설정 화면에서 다크모드 토글 시 이 Provider를 통해 변경된다
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  /// 다크/라이트 토글
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// 특정 모드로 설정
  void setMode(ThemeMode mode) {
    state = mode;
  }
}
