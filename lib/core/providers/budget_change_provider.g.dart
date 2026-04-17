// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_change_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 일일 예산 변경 시 카운터를 증가시켜 관련 VM의 재로드를 트리거한다.
///
/// SettingsViewModel이 예산을 변경할 때 increment하고,
/// Home·Calendar·Stats VM이 ref.listen으로 감지하여 각자 reload한다.

@ProviderFor(BudgetChange)
final budgetChangeProvider = BudgetChangeProvider._();

/// 일일 예산 변경 시 카운터를 증가시켜 관련 VM의 재로드를 트리거한다.
///
/// SettingsViewModel이 예산을 변경할 때 increment하고,
/// Home·Calendar·Stats VM이 ref.listen으로 감지하여 각자 reload한다.
final class BudgetChangeProvider extends $NotifierProvider<BudgetChange, int> {
  /// 일일 예산 변경 시 카운터를 증가시켜 관련 VM의 재로드를 트리거한다.
  ///
  /// SettingsViewModel이 예산을 변경할 때 increment하고,
  /// Home·Calendar·Stats VM이 ref.listen으로 감지하여 각자 reload한다.
  BudgetChangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetChangeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetChangeHash();

  @$internal
  @override
  BudgetChange create() => BudgetChange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$budgetChangeHash() => r'3bfdf9a7a4607a28efad28f98a9e294785e994c4';

/// 일일 예산 변경 시 카운터를 증가시켜 관련 VM의 재로드를 트리거한다.
///
/// SettingsViewModel이 예산을 변경할 때 increment하고,
/// Home·Calendar·Stats VM이 ref.listen으로 감지하여 각자 reload한다.

abstract class _$BudgetChange extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
