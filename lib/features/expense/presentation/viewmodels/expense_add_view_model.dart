import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/expense.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import 'expense_add_state.dart';

typedef ExpenseAddArgs = ({ExpenseEntity? expense, DateTime? date});

final expenseAddViewModelProvider =
    NotifierProvider.autoDispose.family<
      ExpenseAddViewModel,
      ExpenseAddState,
      ExpenseAddArgs
    >((arg) => ExpenseAddViewModel(arg));

class ExpenseAddViewModel extends Notifier<ExpenseAddState> {
  ExpenseAddViewModel(this.arg);

  final ExpenseAddArgs arg;

  @override
  ExpenseAddState build() {
    if (arg.expense != null) {
      final d = arg.expense!.createdAt;
      return ExpenseAddState(
        amountString: arg.expense!.amount.toString(),
        selectedCategory: arg.expense!.category,
        recordDate: DateTime(d.year, d.month, d.day),
        saveCreatedAt: d,
      );
    }
    if (arg.date != null) {
      final d = arg.date!;
      return ExpenseAddState(
        recordDate: DateTime(d.year, d.month, d.day),
        saveCreatedAt: DateTime(d.year, d.month, d.day, 12),
      );
    }
    final now = DateTime.now();
    return ExpenseAddState(
      recordDate: DateTime(now.year, now.month, now.day),
      saveCreatedAt: now,
    );
  }

  // ── 입력 ──────────────────────────────────────────────────────────────────

  /// 숫자 키 입력. true 반환 시 흔들림 애니메이션 필요.
  bool onNumberPressed(String digit) {
    if (state.isSaving) return false;
    if (digit == '00') {
      final s1 = _appendDigit('0');
      if (s1) return true;
      return _appendDigit('0');
    }
    return _appendDigit(digit);
  }

  bool _appendDigit(String digit) {
    if (state.amountString.length >= 7) return true;
    if (state.amountString == '0' && digit == '0') return true;
    if (state.amountString.isEmpty && digit == '0') return false;
    state = state.copyWith(amountString: state.amountString + digit);
    return false;
  }

  void onBackspacePressed() {
    if (state.amountString.isEmpty || state.isSaving) return;
    state = state.copyWith(
      amountString: state.amountString.substring(
        0,
        state.amountString.length - 1,
      ),
    );
  }

  /// 빠른 금액 추가. true 반환 시 흔들림 애니메이션 필요.
  bool addAmount(int addition) {
    if (state.isSaving) return false;
    final next = state.amount + addition;
    if (next > 9999999) return true;
    state = state.copyWith(amountString: next.toString());
    return false;
  }

  /// 즐겨찾기/최근 내역 칩 탭. 호출 후 State에서 pulse 트리거.
  void applyTemplate(
    ({int amount, ExpenseCategory category, String memo}) template,
  ) {
    if (state.isSaving) return;
    state = state.copyWith(
      amountString: template.amount.toString(),
      selectedCategory: template.category,
    );
  }

  void selectCategory(ExpenseCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleFavorite() {
    state = state.copyWith(addToFavorite: !state.addToFavorite);
  }

  // ── 저장 ──────────────────────────────────────────────────────────────────

  /// 저장. 성공 → Screen이 pop. 실패 → Screen이 SnackBar 표시.
  Future<Result<void>> save() async {
    if (!state.canSave) return Result.success(null);

    state = state.copyWith(isSaving: true, saveError: false);

    final Result<void> result;
    if (arg.expense != null) {
      result = await ref
          .read(homeViewModelProvider.notifier)
          .updateExpense(
            arg.expense!.copyWith(
              amount: state.amount,
              category: state.selectedCategory,
            ),
          );
    } else {
      result = await ref
          .read(homeViewModelProvider.notifier)
          .addExpense(
            ExpenseEntity(
              amount: state.amount,
              category: state.selectedCategory,
              createdAt: state.saveCreatedAt,
            ),
          );
    }

    if (result.isSuccess && state.addToFavorite) {
      await ref
          .read(homeViewModelProvider.notifier)
          .addFavorite(
            amount: state.amount,
            category: state.selectedCategory,
          );
    }

    if (!result.isSuccess) {
      state = state.copyWith(isSaving: false, saveError: true);
    }

    return result;
  }
}
