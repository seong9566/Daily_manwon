// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StatsViewModel)
final statsViewModelProvider = StatsViewModelProvider._();

final class StatsViewModelProvider
    extends $AsyncNotifierProvider<StatsViewModel, StatsState> {
  StatsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsViewModelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsViewModelHash();

  @$internal
  @override
  StatsViewModel create() => StatsViewModel();
}

String _$statsViewModelHash() => r'3692612fa8d943c0378918583483dec472d52237';

abstract class _$StatsViewModel extends $AsyncNotifier<StatsState> {
  FutureOr<StatsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StatsState>, StatsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StatsState>, StatsState>,
              AsyncValue<StatsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
