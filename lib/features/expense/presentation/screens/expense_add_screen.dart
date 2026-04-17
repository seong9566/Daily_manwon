import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/expense.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import '../viewmodels/expense_add_view_model.dart';
import '../widgets/amount_display_section.dart';
import '../widgets/category_selector.dart';
import '../widgets/expense_delete_dialog.dart';
import '../widgets/favorite_templates_section.dart';
import '../widgets/number_keypad.dart';
import '../widgets/quick_add_buttons.dart';
import '../widgets/save_button.dart';

/// 지출 입력 화면을 표시하는 헬퍼 함수
/// [date]를 지정하면 해당 날짜로 지출을 기록한다. 미지정 시 오늘 날짜로 기록한다.
/// 편집 모드([expense] 전달 시)에서는 [date]가 무시되며 기존 지출의 날짜가 표시된다.
/// 저장 성공 시 true를 반환하며, 취소/닫기 시 false 또는 null 반환
Future<bool?> showExpenseAddBottomSheet(
  BuildContext context, {
  ExpenseEntity? expense,
  DateTime? date,
}) {
  return Navigator.of(context, rootNavigator: true).push<bool>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) =>
          ExpenseAddScreen(expense: expense, date: date),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        final tween = Tween(
          begin: begin,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
    ),
  );
}

/// 지출 입력 화면 (Scaffold 기반)
/// 금액 입력 → 카테고리 선택 → 저장 흐름을 담당한다
class ExpenseAddScreen extends ConsumerStatefulWidget {
  final ExpenseEntity? expense;

  /// 새 지출을 기록할 날짜. null이면 오늘. 편집 모드에서는 무시된다.
  final DateTime? date;

  const ExpenseAddScreen({super.key, this.expense, this.date});

  @override
  ConsumerState<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends ConsumerState<ExpenseAddScreen>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late final ExpenseAddArgs _args;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _args = (expense: widget.expense, date: widget.date);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 3.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _shake() {
    if (!_reduceMotion) _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  void _pulse() {
    if (!_reduceMotion) _pulseController.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _onNumberPressed(String digit) {
    final needsShake = ref
        .read(expenseAddViewModelProvider(_args).notifier)
        .onNumberPressed(digit);
    if (needsShake) {
      _shake();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _onBackspacePressed() {
    ref.read(expenseAddViewModelProvider(_args).notifier).onBackspacePressed();
    HapticFeedback.lightImpact();
  }

  void _onAddAmount(int addition) {
    final needsShake = ref
        .read(expenseAddViewModelProvider(_args).notifier)
        .addAmount(addition);
    if (needsShake) {
      _shake();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _onApplyTemplate(
    ({int amount, ExpenseCategory category, String memo}) template,
  ) {
    ref
        .read(expenseAddViewModelProvider(_args).notifier)
        .applyTemplate(template);
    _pulse();
  }

  Future<void> _onSave() async {
    final result = await ref
        .read(expenseAddViewModelProvider(_args).notifier)
        .save();
    if (!mounted) return;
    result.when(
      success: (_) => Navigator.pop(context, true),
      failure: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(f.message.isNotEmpty ? f.message : '저장 중 오류가 발생했습니다.'),
          action: SnackBarAction(label: '다시 시도', onPressed: _onSave),
        ),
      ),
    );
  }

  Future<void> _onDelete() async {
    final vmState = ref.read(expenseAddViewModelProvider(_args));
    if (widget.expense == null || vmState.isSaving) return;

    final shouldDelete = await showExpenseDeleteDialog(context);
    if (shouldDelete == true && mounted) {
      await ref
          .read(homeViewModelProvider.notifier)
          .deleteExpense(widget.expense!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  static String _weekdayLabel(int weekday) {
    const labels = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return labels[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(expenseAddViewModelProvider(_args));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '${vmState.recordDate.month}월 ${vmState.recordDate.day}일 '
          '${_weekdayLabel(vmState.recordDate.weekday)}',
          style: AppTypography.titleMedium.copyWith(color: textMainColor),
        ),
        actions: [
          if (widget.expense != null)
            IconButton(
              onPressed: _onDelete,
              icon: Icon(
                CupertinoIcons.delete,
                size: 22,
                color: AppColors.budgetDanger,
              ),
              tooltip: '삭제',
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, size: 24, color: textSubColor),
            tooltip: '닫기',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          AmountDisplaySection(
            amountString: vmState.amountString,
            amount: vmState.amount,
            addToFavorite: vmState.addToFavorite,
            shakeAnim: _shakeAnim,
            pulseAnim: _pulseAnim,
            onFavoriteTap: () => ref
                .read(expenseAddViewModelProvider(_args).notifier)
                .toggleFavorite(),
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),
          QuickAddButtons(isDark: isDark, onAdd: _onAddAmount),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: CategorySelector(
              selectedCategory: vmState.selectedCategory,
              onCategoryChanged: (cat) => ref
                  .read(expenseAddViewModelProvider(_args).notifier)
                  .selectCategory(cat),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (widget.expense == null)
            FavoriteTemplatesSection(onTemplateTap: _onApplyTemplate),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: NumberKeypad(
              onNumberPressed: _onNumberPressed,
              onBackspacePressed: _onBackspacePressed,
            ),
          ),
          SaveButton(
            canSave: vmState.canSave,
            isSaving: vmState.isSaving,
            saveError: vmState.saveError,
            isDark: isDark,
            onPressed: _onSave,
          ),
        ],
      ),
    );
  }
}
