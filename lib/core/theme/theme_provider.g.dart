// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 앱 전체 테마 모드를 관리하는 Provider
/// 설정 화면에서 다크모드 토글 시 이 Provider를 통해 변경된다

@ProviderFor(AppThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

/// 앱 전체 테마 모드를 관리하는 Provider
/// 설정 화면에서 다크모드 토글 시 이 Provider를 통해 변경된다
final class AppThemeModeProvider
    extends $NotifierProvider<AppThemeMode, ThemeMode> {
  /// 앱 전체 테마 모드를 관리하는 Provider
  /// 설정 화면에서 다크모드 토글 시 이 Provider를 통해 변경된다
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$appThemeModeHash() => r'4c906c83e1b6b2f9d93230781dc7884219ed08c4';

/// 앱 전체 테마 모드를 관리하는 Provider
/// 설정 화면에서 다크모드 토글 시 이 Provider를 통해 변경된다

abstract class _$AppThemeMode extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
