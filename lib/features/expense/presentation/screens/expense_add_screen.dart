import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import '../widgets/category_selector.dart';
import '../widgets/number_keypad.dart';

/// 지출 입력 바텀시트를 표시하는 헬퍼 함수
/// 저장 성공 시 true를 반환하며, 취소/닫기 시 false 또는 null 반환
Future<bool?> showExpenseAddBottomSheet(
  BuildContext context, {
  ExpenseEntity? expense,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    // 화면 높이의 대부분을 차지하도록 설정
    isScrollControlled: true,
    // 둥근 상단 모서리
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    // 배경 클릭 시 닫기 허용
    isDismissible: true,
    // 키보드 등장 시 바텀시트 위로 밀리지 않도록 (커스텀 키패드 사용)
    useRootNavigator: true,
    builder: (context) => _ExpenseAddBottomSheet(expense: expense),
  );
}

/// 지출 입력 바텀시트 위젯
/// 금액 입력 → 카테고리 선택 → 저장 흐름을 담당한다
class _ExpenseAddBottomSheet extends ConsumerStatefulWidget {
  final ExpenseEntity? expense;

  const _ExpenseAddBottomSheet({this.expense});

  @override
  ConsumerState<_ExpenseAddBottomSheet> createState() =>
      _ExpenseAddBottomSheetState();
}

class _ExpenseAddBottomSheetState
    extends ConsumerState<_ExpenseAddBottomSheet> {
  /// 현재 입력 중인 금액 문자열 (표시용)
  late String _amountString;

  /// 선택된 카테고리 — 기본값: 카페
  late ExpenseCategory _selectedCategory;

  /// 저장 진행 중 여부 — 버튼 로딩 상태 표시용
  bool _isSaving = false;

  /// 현재 입력된 금액 (int 변환)
  int get _amount => _amountString.isEmpty ? 0 : int.parse(_amountString);

  /// 저장 가능 여부 — 금액이 0보다 커야 활성화
  bool get _canSave => _amount > 0 && !_isSaving;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountString = widget.expense!.amount.toString();
      _selectedCategory = ExpenseCategory.values[widget.expense!.category];
    } else {
      _amountString = '';
      _selectedCategory = ExpenseCategory.cafe;
    }
  }

  /// 숫자 키 입력 처리
  /// - 최대 7자리 (9,999,999원) 제한
  /// - leading zero 방지 (0 입력 후 또 0은 허용하지 않음)
  void _onNumberPressed(String digit) {
    if (_amountString.length >= 7) return;

    // 현재 금액이 0이면 0을 leading zero로 허용하지 않는다
    if (_amountString == '0' && digit == '0') return;

    // 첫 입력이 0이면 그냥 0 하나만 표시 (다음 숫자로 대체)
    if (_amountString.isEmpty && digit == '0') {
      // 0 단독 입력은 표시하지 않음 (leading zero 방지)
      return;
    }

    setState(() {
      _amountString += digit;
    });
    // 햅틱 피드백 — 가벼운 터치감
    HapticFeedback.lightImpact();
  }

  /// 백스페이스 처리
  void _onBackspacePressed() {
    if (_amountString.isEmpty) return;
    setState(() {
      _amountString = _amountString.substring(0, _amountString.length - 1);
    });
    HapticFeedback.lightImpact();
  }

  /// 지출 저장 처리
  /// HomeViewModel.addExpense()를 통해 저장 후 바텀시트를 닫는다
  Future<void> _onSave() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    try {
      if (widget.expense != null) {
        await ref
            .read(homeViewModelProvider.notifier)
            .updateExpense(
              widget.expense!.copyWith(
                amount: _amount,
                category: _selectedCategory.index,
              ),
            );
      } else {
        await ref
            .read(homeViewModelProvider.notifier)
            .addExpense(
              ExpenseEntity(
                id: 0,
                amount: _amount,
                category: _selectedCategory.index,
                createdAt: DateTime.now(),
              ),
            );
      }

      // 홈 화면 데이터 동기화 (캘린더 invalidate는 HomeViewModel.addExpense에서 처리)
      ref.read(homeViewModelProvider.notifier).refresh();

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 중 오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _onDelete() async {
    if (widget.expense == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Text('🗑️', style: TextStyle(fontSize: 36)),
              Icon(
                CupertinoIcons.trash,
                size: 36,
                color: AppColors.budgetDanger,
              ),
              const SizedBox(height: 12),
              Text(
                '정말 삭제할까요?',
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextMain : AppColors.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이 지출 기록이 사라져요',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSub : AppColors.textSub,
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
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSub
                                  : AppColors.textSub,
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

    if (shouldDelete == true && mounted) {
      ref
          .read(homeViewModelProvider.notifier)
          .deleteExpense(widget.expense!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    // 화면 높이의 70%를 바텀시트 최대 높이로 설정
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 드래그 핸들 ──────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkDivider : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── 헤더: 제목 + 닫기 버튼 ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '지출 기록',
                  style: AppTypography.titleMedium.copyWith(
                    color: textMainColor,
                  ),
                ),
                const Spacer(),
                if (widget.expense != null)
                  IconButton(
                    onPressed: _onDelete,
                    icon: Icon(
                      CupertinoIcons.delete,
                      size: 24,
                      color: AppColors.budgetDanger,
                    ),
                    tooltip: '삭제',
                  ),
                // IconButton(
                //   onPressed: () => Navigator.pop(context),
                //   icon: Icon(
                //     Icons.close_rounded,
                //     size: 24,
                //     color: textSubColor,
                //   ),
                //   tooltip: '닫기',
                // ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── 중앙 영역 (금액, 카테고리, 키패드) - 스크롤 처리로 오버플로우 방지 ──
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 12),
                  // ── 금액 표시 영역 ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Semantics(
                      label: _amountString.isEmpty
                          ? '입력 금액 없음'
                          : '입력 금액 ${CurrencyFormatter.formatWithWon(_amount)}',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // 금액이 있을 때만 단위 텍스트 표시
                          if (_amountString.isNotEmpty)
                            Text(
                              '₩ ',
                              style: AppTypography.titleMedium.copyWith(
                                color: textSubColor,
                                fontSize: 20,
                              ),
                            ),
                          // 금액 숫자 — 입력 없을 때 플레이스홀더 표시
                          Text(
                            _amountString.isEmpty
                                ? '0'
                                : CurrencyFormatter.formatNumberOnly(_amount),
                            style: AppTypography.displayLarge.copyWith(
                              color: _amountString.isEmpty
                                  ? (isDark
                                        ? AppColors.darkTextSub
                                        : AppColors.textSub)
                                  : textMainColor,
                              fontSize: 44,
                            ),
                          ),
                          if (_amountString.isNotEmpty)
                            Text(
                              ' 원',
                              style: AppTypography.titleMedium.copyWith(
                                color: textSubColor,
                                fontSize: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 카테고리 선택 ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CategorySelector(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── 구분선 ───────────────────────────────────
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                  const SizedBox(height: 8),

                  // ── 커스텀 숫자 키패드 ───────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: NumberKeypad(
                      onNumberPressed: _onNumberPressed,
                      onBackspacePressed: _onBackspacePressed,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── 기록하기 버튼 (하단 고정) ────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Semantics(
              button: true,
              enabled: _canSave,
              label: _canSave ? '기록하기' : '금액을 입력해주세요',
              child: AnimatedOpacity(
                opacity: _canSave ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canSave ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkTextMain
                          : AppColors.textMain,
                      foregroundColor: isDark
                          ? AppColors.darkBackground
                          : Colors.white,
                      disabledBackgroundColor: isDark
                          ? AppColors.darkTextMain
                          : AppColors.textMain,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: isDark
                                  ? AppColors.darkBackground
                                  : Colors.white,
                            ),
                          )
                        : Text(
                            '기록하기',
                            style: AppTypography.bodyLarge.copyWith(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
