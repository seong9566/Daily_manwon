import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';
import '../widgets/category_selector.dart';
import '../widgets/expense_delete_dialog.dart';
import '../widgets/favorite_templates_section.dart';
import '../widgets/number_keypad.dart';

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
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
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

class _ExpenseAddScreenState extends ConsumerState<ExpenseAddScreen> {
  /// 현재 입력 중인 금액 문자열 (표시용)
  late String _amountString;

  /// 선택된 카테고리 — 기본값: 카페
  late ExpenseCategory _selectedCategory;

  /// 저장 진행 중 여부 — 버튼 로딩 상태 표시용
  bool _isSaving = false;

  /// 저장 시 즐겨찾기에도 추가할지 여부
  bool _addToFavorite = false;

  /// 즐겨찾기/자동학습 칩 탭 시 금액·카테고리 자동 채움
  void _applyTemplate(({int amount, int category, String memo}) template) {
    setState(() {
      _amountString = template.amount.toString();
      _selectedCategory = ExpenseCategory.values[template.category];
    });
  }

  /// 헤더에 표시할 날짜 (시분초=0, 표시 전용)
  late final DateTime _recordDate;

  /// DB에 저장될 실제 createdAt 값.
  /// - 홈 FAB(date=null): DateTime.now() — 실제 시각 보존 (00:00 저장 방지)
  /// - 캘린더 과거 날짜: 정오(12:00) — UTC 날짜 경계 이탈 방지
  /// - 편집 모드: 기존 expense.createdAt — 날짜 변경 없음
  late final DateTime _saveCreatedAt;

  /// 현재 입력된 금액 (int 변환)
  int get _amount => _amountString.isEmpty ? 0 : int.parse(_amountString);

  /// 저장 가능 여부 — 금액이 0보다 커야 활성화
  bool get _canSave => _amount > 0 && !_isSaving;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // 편집 모드 — 기존 날짜·시각 그대로 유지
      final d = widget.expense!.createdAt;
      _recordDate = DateTime(d.year, d.month, d.day);
      _saveCreatedAt = d;
      _amountString = widget.expense!.amount.toString();
      _selectedCategory = ExpenseCategory.values[widget.expense!.category];
    } else if (widget.date != null) {
      // 캘린더 과거 날짜 지정 모드 — 정오(12:00)로 저장해 UTC 날짜 경계 이탈 방지
      final d = widget.date!;
      _recordDate = DateTime(d.year, d.month, d.day);
      _saveCreatedAt = DateTime(d.year, d.month, d.day, 12);
      _amountString = '';
      _selectedCategory = ExpenseCategory.cafe;
    } else {
      // 홈 FAB 모드 — 실제 현재 시각 보존 (자정 저장 방지)
      final now = DateTime.now();
      _recordDate = DateTime(now.year, now.month, now.day);
      _saveCreatedAt = now;
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
  /// HomeViewModel.addExpense()를 통해 저장 후 화면을 닫는다
  /// 신규 지출 모드에서 [_addToFavorite]가 true이면 AddFavoriteUseCase를 호출하고 favoritesProvider를 갱신한다
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
                createdAt: _saveCreatedAt,
              ),
            );
      }

      if (_addToFavorite && widget.expense == null) {
        await ref.read(homeViewModelProvider.notifier).addFavorite(
          amount: _amount,
          category: _selectedCategory.index,
        );
      }

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

    final shouldDelete = await showExpenseDeleteDialog(context);

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
          '${_recordDate.month}월 ${_recordDate.day}일 지출 기록',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── 즐겨찾기 / 자동학습 칩 ──────────────────────
            if (widget.expense == null)
              FavoriteTemplatesSection(onTemplateTap: _applyTemplate),

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
                    if (_amountString.isNotEmpty)
                      Text(
                        '₩ ',
                        style: AppTypography.amountUnit.copyWith(
                          color: textSubColor,
                        ),
                      ),
                    Text(
                      _amountString.isEmpty
                          ? '0'
                          : CurrencyFormatter.formatNumberOnly(_amount),
                      style: AppTypography.displayAmount.copyWith(
                        color: _amountString.isEmpty
                            ? (isDark
                                  ? AppColors.darkTextSub
                                  : AppColors.textSub)
                            : textMainColor,
                      ),
                    ),
                    if (_amountString.isNotEmpty)
                      Text(
                        ' 원',
                        style: AppTypography.amountUnit.copyWith(
                          color: textSubColor,
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 즐겨찾기 추가 체크박스 ────────────────────────
          if (widget.expense == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _addToFavorite,
                  onChanged: (v) => setState(() => _addToFavorite = v ?? false),
                ),
                Text('즐겨찾기에 추가', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),

          // ── 기록하기 버튼 ────────────────────────────────
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
                  height: AppSpacing.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _canSave ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkTextMain
                          : AppColors.textMain,
                      foregroundColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.white,
                      disabledBackgroundColor: isDark
                          ? AppColors.darkTextMain
                          : AppColors.textMain,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.card),
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
                                  : AppColors.white,
                            ),
                          )
                        : Text(
                            '기록하기',
                            style: AppTypography.bodyLarge.copyWith(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.white,
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
