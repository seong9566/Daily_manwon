// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 홈 화면 뷰모델 — 오늘의 예산, 지출을 관리한다

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

/// 홈 화면 뷰모델 — 오늘의 예산, 지출을 관리한다
final class HomeViewModelProvider
    extends $NotifierProvider<HomeViewModel, HomeState> {
  /// 홈 화면 뷰모델 — 오늘의 예산, 지출을 관리한다
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeViewModelHash() => r'963696ea4900a1e52b4bc155a9ea7ef749c96d84';

/// 홈 화면 뷰모델 — 오늘의 예산, 지출을 관리한다

abstract class _$HomeViewModel extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
