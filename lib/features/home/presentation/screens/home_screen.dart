import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../expense/presentation/screens/expense_add_screen.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/home_budget_header.dart';

/// 메인 홈 화면 (디자인 가이드 Section 7.1)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱이 포그라운드로 복귀할 때 날짜 변경 여부를 확인한다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeViewModelProvider.notifier).checkDateChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final subTextColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    HomeBudgetHeader(
                      remainingBudget: state.remainingBudget,
                      totalBudget: state.totalBudget,
                      carryOver: state.carryOver,
                      totalAcorns: state.totalAcorns,
                      streakDays: state.streakDays,
                      isDark: isDark,
                      subTextColor: subTextColor,
                    ),
                    // "오늘의 지출" 헤더
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '오늘의 지출',
                            style: AppTypography.titleMedium.copyWith(color: textColor),
                          ),
                          Text(
                            '${state.expenses.length}건',
                            style: AppTypography.bodySmall.copyWith(color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 지출 리스트
                    Expanded(
                      child: state.expenses.isEmpty
                          ? Center(
                              child: Text(
                                '아직 지출이 없어요',
                                style: AppTypography.bodySmall.copyWith(color: subTextColor),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: state.expenses.length,
                              itemBuilder: (context, index) {
                                final expense = state.expenses[index];
                                final category = ExpenseCategory.values[expense.category];
                                return Dismissible(
                                  key: ValueKey(expense.id),
                                  direction: DismissDirection.horizontal,
                                  dismissThresholds: const {
                                    DismissDirection.endToStart: 0.5,
                                    DismissDirection.startToEnd: 0.5,
                                  },
                                  // 왼쪽→오른쪽: 수정 (스카이 블루)
                                  background: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 24),
                                    color: AppColors.accent,
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // 오른쪽→왼쪽: 삭제 (코랄 레드)
                                  secondaryBackground: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    color: AppColors.budgetDanger,
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      return await _showDeleteDialog(context);
                                    } else {
                                      // TODO: 수정 화면 연결
                                      return false;
                                    }
                                  },
                                  onDismissed: (_) {
                                    ref
                                        .read(homeViewModelProvider.notifier)
                                        .deleteExpense(expense.id);
                                  },
                                  child: Semantics(
                                    label: '${category.label} ${expense.amount}원',
                                    child: ExpenseListItem(expense: expense),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
        // FAB — 검정 배경 + 흰색 아이콘
        floatingActionButton: FloatingActionButton(
          tooltip: '지출 추가',
          backgroundColor: isDark ? AppColors.darkTextMain : AppColors.textPrimary,
          foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
          shape: const CircleBorder(),
          onPressed: () => showExpenseAddBottomSheet(context),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  /// 앱 무드에 맞는 삭제 확인 다이얼로그
  Future<bool?> _showDeleteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                '정말 삭제할까요?',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextMain : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이 지출 기록이 사라져요',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSub : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Semantics(
                        button: true,
                        label: '삭제 취소',
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? AppColors.darkDivider : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '아니요',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSub
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Semantics(
                        button: true,
                        label: '삭제 확인',
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.budgetDanger,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '삭제할게요',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
