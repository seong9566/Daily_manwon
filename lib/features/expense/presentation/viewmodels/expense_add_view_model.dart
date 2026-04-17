import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense_use_case.dart';
import '../../domain/usecases/add_favorite_use_case.dart';
import '../../domain/usecases/delete_expense_use_case.dart';
import '../../domain/usecases/update_expense_use_case.dart';
import 'expense_add_state.dart';

part 'expense_add_view_model.g.dart';

@riverpod
class ExpenseAddViewModel extends _$ExpenseAddViewModel {
  @override
  ExpenseAddState build({ExpenseEntity? expense, DateTime? date}) {
    if (expense != null) {
      final d = expense.createdAt;
      return ExpenseAddState(
        amountString: expense.amount.toString(),
        selectedCategory: expense.category,
        recordDate: DateTime(d.year, d.month, d.day),
        saveCreatedAt: d,
      );
    }
    if (date != null) {
      final d = date;
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

  /// 즐겨찾기/최근 내역 칩 탭.
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
  Future<Result<void>> save({ExpenseEntity? originalExpense}) async {
    if (!state.canSave) {
      return Result.failure(const ValidationFailure('금액을 입력해주세요'));
    }

    state = state.copyWith(isSaving: true, saveError: false);

    final Result<void> result;
    if (originalExpense != null) {
      result = await getIt<UpdateExpenseUseCase>().execute(
        originalExpense.copyWith(
          amount: state.amount,
          category: state.selectedCategory,
        ),
      );
    } else {
      result = await getIt<AddExpenseUseCase>().execute(
        ExpenseEntity(
          amount: state.amount,
          category: state.selectedCategory,
          createdAt: state.saveCreatedAt,
        ),
      );
    }

    if (result.isSuccess && state.addToFavorite) {
      await getIt<AddFavoriteUseCase>().execute(
        amount: state.amount,
        category: state.selectedCategory,
      );
    }

    state = state.copyWith(isSaving: false, saveError: !result.isSuccess);

    return result;
  }

  /// 지출 삭제.
  Future<void> delete(int id) async {
    await getIt<DeleteExpenseUseCase>().execute(id);
  }
}
