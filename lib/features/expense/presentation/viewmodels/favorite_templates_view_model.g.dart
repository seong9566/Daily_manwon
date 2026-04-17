// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_templates_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 즐겨찾기 템플릿 섹션 상태 — home 피처 ViewModel에 의존하지 않고
/// 자체 UseCase를 통해 데이터를 로드한다

@ProviderFor(FavoriteTemplatesViewModel)
final favoriteTemplatesViewModelProvider =
    FavoriteTemplatesViewModelProvider._();

/// 즐겨찾기 템플릿 섹션 상태 — home 피처 ViewModel에 의존하지 않고
/// 자체 UseCase를 통해 데이터를 로드한다
final class FavoriteTemplatesViewModelProvider
    extends
        $NotifierProvider<FavoriteTemplatesViewModel, FavoriteTemplatesState> {
  /// 즐겨찾기 템플릿 섹션 상태 — home 피처 ViewModel에 의존하지 않고
  /// 자체 UseCase를 통해 데이터를 로드한다
  FavoriteTemplatesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteTemplatesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteTemplatesViewModelHash();

  @$internal
  @override
  FavoriteTemplatesViewModel create() => FavoriteTemplatesViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteTemplatesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteTemplatesState>(value),
    );
  }
}

String _$favoriteTemplatesViewModelHash() =>
    r'3df4ff1574a496e7714906c93e2980bfb9092f50';

/// 즐겨찾기 템플릿 섹션 상태 — home 피처 ViewModel에 의존하지 않고
/// 자체 UseCase를 통해 데이터를 로드한다

abstract class _$FavoriteTemplatesViewModel
    extends $Notifier<FavoriteTemplatesState> {
  FavoriteTemplatesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<FavoriteTemplatesState, FavoriteTemplatesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoriteTemplatesState, FavoriteTemplatesState>,
              FavoriteTemplatesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
