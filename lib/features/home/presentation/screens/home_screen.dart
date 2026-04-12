import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../expense/presentation/screens/expense_add_screen.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/carryover_badge_widget.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/home_budget_header.dart';
import '../widgets/new_week_interstitial_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _notifSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Terminated/Background 상태에서 알림 탭으로 진입한 경우 처리
    _handlePendingNotification();

    // Foreground 상태에서 알림 탭 이벤트를 구독하여 화면 이동 처리
    _subscribeNotificationNavigation();
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 앱이 포그라운드로 복귀할 때 날짜 변경 확인 + 미소비 알림 payload를 처리한다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(homeViewModelProvider.notifier).checkDateChange();
      // Background에서 알림 탭으로 재개된 경우 pending payload 소비
      _handlePendingNotification();
    }
  }

  /// Terminated/Background 상태에서 알림 탭 후 앱 진입 시 처리.
  ///
  /// notification_handler.dart의 onBackgroundNotificationTap이 저장한
  /// pending payload를 소비하고 홈 화면으로 이동한다.
  Future<void> _handlePendingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString('pending_notification_payload');
    if (payload != null) {
      // payload 소비 후 홈으로 이동
      await prefs.remove('pending_notification_payload');
      if (mounted) context.go(AppRoutes.home);
    }
  }

  /// Foreground 상태에서 알림 탭 이벤트를 구독한다.
  ///
  /// NotificationService.navigationStream(static)을 listen하여
  /// 알림 탭 시 홈 화면으로 이동한다.
  void _subscribeNotificationNavigation() {
    _notifSubscription = NotificationService.navigationStream.listen((payload) {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 신규 칭호 획득 시 Snackbar로 알림 (S-26g)
    ref.listen<HomeState>(homeViewModelProvider, (prev, next) {
      if (next.newlyAchievedTitle != null &&
          next.newlyAchievedTitle != prev?.newlyAchievedTitle) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '새 칭호 획득! ${next.newlyAchievedTitle}',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.black : AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: isDark
                ? AppColors.white
                : AppColors.budgetComfortable,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        ref.read(homeViewModelProvider.notifier).clearAchievedTitle();
      }
    });

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
            : Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        HomeBudgetHeader(
                          remainingBudget: state.remainingBudget,
                          totalBudget: state.totalBudget,
                          subTextColor: subTextColor,
                        ),
                        // 이월 배지
                        if (state.carryOver != 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CarryoverBadgeWidget(
                                carryOver: state.carryOver),
                          ),
                        // "오늘의 지출" 헤더
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '오늘의 지출',
                                style: AppTypography.titleMedium.copyWith(
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '${state.expenses.length}건',
                                style: AppTypography.bodySmall.copyWith(
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
                                    style: AppTypography.bodySmall.copyWith(
                                      color: subTextColor,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: state.expenses.length,
                                  itemBuilder: (context, index) {
                                    final expense = state.expenses[index];
                                    final category =
                                        ExpenseCategory.values[expense.category];
                                    return Semantics(
                                      label:
                                          '${category.label} ${expense.amount}원',
                                      child: ExpenseListItem(
                                        expense: expense,
                                        onTap: () => showExpenseAddBottomSheet(
                                          context,
                                          expense: expense,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  // 새 주 시작 인터스티셜
                  if (state.isNewWeek)
                    NewWeekInterstitialWidget(
                      onDismiss: () => ref
                          .read(homeViewModelProvider.notifier)
                          .markNewWeekSeen(),
                    ),
                ],
              ),
        // FAB — 라이트: black(primary) + white 아이콘, 다크: white + black 아이콘
        floatingActionButton: FloatingActionButton(
          heroTag: 'home_add_expense',
          tooltip: '지출 추가',
          backgroundColor: isDark ? AppColors.white : AppColors.primary,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape: const CircleBorder(),
          onPressed: () => showExpenseAddBottomSheet(context),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
