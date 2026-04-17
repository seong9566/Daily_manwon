// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_add_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpenseAddViewModel)
final expenseAddViewModelProvider = ExpenseAddViewModelFamily._();

final class ExpenseAddViewModelProvider
    extends $NotifierProvider<ExpenseAddViewModel, ExpenseAddState> {
  ExpenseAddViewModelProvider._({
    required ExpenseAddViewModelFamily super.from,
    required ({ExpenseEntity? expense, DateTime? date}) super.argument,
  }) : super(
         retry: null,
         name: r'expenseAddViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseAddViewModelHash();

  @override
  String toString() {
    return r'expenseAddViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ExpenseAddViewModel create() => ExpenseAddViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseAddState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseAddState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseAddViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseAddViewModelHash() =>
    r'e398c7c4c17f8aa88d41cc110da00e7e7d964bc6';

final class ExpenseAddViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ExpenseAddViewModel,
          ExpenseAddState,
          ExpenseAddState,
          ExpenseAddState,
          ({ExpenseEntity? expense, DateTime? date})
        > {
  ExpenseAddViewModelFamily._()
    : super(
        retry: null,
        name: r'expenseAddViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseAddViewModelProvider call({ExpenseEntity? expense, DateTime? date}) =>
      ExpenseAddViewModelProvider._(
        argument: (expense: expense, date: date),
        from: this,
      );

  @override
  String toString() => r'expenseAddViewModelProvider';
}

abstract class _$ExpenseAddViewModel extends $Notifier<ExpenseAddState> {
  late final _$args = ref.$arg as ({ExpenseEntity? expense, DateTime? date});
  ExpenseEntity? get expense => _$args.expense;
  DateTime? get date => _$args.date;

  ExpenseAddState build({ExpenseEntity? expense, DateTime? date});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ExpenseAddState, ExpenseAddState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExpenseAddState, ExpenseAddState>,
              ExpenseAddState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(expense: _$args.expense, date: _$args.date),
    );
  }
}
