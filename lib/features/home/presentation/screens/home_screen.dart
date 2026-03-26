import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_based_theme.dart';
import '../../../expense/presentation/screens/expense_add_screen.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/acorn_streak_badge.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/hero_budget_number.dart';

/// 메인 홈 화면 (디자인 가이드 Section 7.1)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverBudget = state.remainingBudget < 0;

    // 시간대별 배경색
    final bgColor = TimeBasedTheme.getBackgroundColor(
      isDarkMode: isDark,
      isOverBudget: isOverBudget,
    );
    // 시간대별 텍스트 색상
    final textColor = TimeBasedTheme.getTextColor(isDarkMode: isDark);
    final subTextColor = TimeBasedTheme.getSubTextColor(isDarkMode: isDark);

    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // 날짜 표시
                    Text(
                      DateFormat('yyyy. MM. dd').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // "오늘 남은 금액" 라벨
                    Text(
                      '오늘 남은 금액',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 히어로 금액 (디자인 가이드 Section 1)
                    HeroBudgetNumber(remainingBudget: state.remainingBudget),
                    // 이월 금액 표시 (디자인 가이드 Section 1.5)
                    if (state.carryOver > 0)
                      Text(
                        '+ 어제 이월 ₩${NumberFormat('#,###').format(state.carryOver)}',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: subTextColor,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 200.ms)
                          .slideY(
                              begin: 0.3,
                              duration: 300.ms,
                              curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    // 프로그레스 바
                    _BudgetProgressBar(
                      remaining: state.remainingBudget,
                      total: state.totalBudget,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    // 도토리 + 스트릭
                    AcornStreakBadge(
                      totalAcorns: state.totalAcorns,
                      streakDays: state.streakDays,
                    ),
                    const SizedBox(height: 32),
                    // "오늘의 지출" 헤더
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '오늘의 지출',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${state.expenses.length}건',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: subTextColor,
                            ),
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
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: state.expenses.length,
                              itemBuilder: (context, index) {
                                final expense = state.expenses[index];
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
                                    if (direction ==
                                        DismissDirection.endToStart) {
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
                                  child: ExpenseListItem(expense: expense),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
        // FAB — 검정 배경 + 흰색 아이콘
        floatingActionButton: FloatingActionButton(
          backgroundColor:
              isDark ? AppColors.darkTextMain : AppColors.textPrimary,
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
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.darkTextMain : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이 지출 기록이 사라져요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color:
                      isDark ? AppColors.darkTextSub : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '아니요',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextSub
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
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
                        child: const Text(
                          '삭제할게요',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
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

/// 프로그레스 바 위젯
class _BudgetProgressBar extends StatelessWidget {
  final int remaining;
  final int total;
  final bool isDark;

  const _BudgetProgressBar({
    required this.remaining,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    Color barColor;
    if (remaining >= 5000) {
      barColor = AppColors.budgetComfortable;
    } else if (remaining >= 1000) {
      barColor = AppColors.budgetWarning;
    } else {
      barColor = AppColors.budgetDanger;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 4,
          backgroundColor: isDark ? AppColors.darkDivider : AppColors.border,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
    );
  }
}
