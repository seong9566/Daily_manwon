import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_change_provider.g.dart';

/// 일일 예산 변경 시 카운터를 증가시켜 관련 VM의 재로드를 트리거한다.
///
/// SettingsViewModel이 예산을 변경할 때 increment하고,
/// Home·Calendar·Stats VM이 ref.listen으로 감지하여 각자 reload한다.
@Riverpod(keepAlive: true)
class BudgetChange extends _$BudgetChange {
  @override
  int build() => 0;

  void increment() => state++;
}
