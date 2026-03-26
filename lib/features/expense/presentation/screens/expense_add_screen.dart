import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../widgets/category_selector.dart';
import '../widgets/number_keypad.dart';

/// 지출 입력 바텀시트를 표시하는 헬퍼 함수
/// 저장 성공 시 true를 반환하며, 취소/닫기 시 false 또는 null 반환
Future<bool?> showExpenseAddBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    // 화면 높이의 대부분을 차지하도록 설정
    isScrollControlled: true,
    // 둥근 상단 모서리
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    // 배경 클릭 시 닫기 허용
    isDismissible: true,
    // 키보드 등장 시 바텀시트 위로 밀리지 않도록 (커스텀 키패드 사용)
    useRootNavigator: false,
    builder: (context) => const _ExpenseAddBottomSheet(),
  );
}

/// 지출 입력 바텀시트 위젯
/// 금액 입력 → 카테고리 선택 → 저장 흐름을 담당한다
class _ExpenseAddBottomSheet extends StatefulWidget {
  const _ExpenseAddBottomSheet();

  @override
  State<_ExpenseAddBottomSheet> createState() => _ExpenseAddBottomSheetState();
}

class _ExpenseAddBottomSheetState extends State<_ExpenseAddBottomSheet> {
  /// 현재 입력 중인 금액 문자열 (표시용)
  String _amountString = '';

  /// 선택된 카테고리 — 기본값: 카페
  ExpenseCategory _selectedCategory = ExpenseCategory.cafe;

  /// 저장 진행 중 여부 — 버튼 로딩 상태 표시용
  bool _isSaving = false;

  /// 현재 입력된 금액 (int 변환)
  int get _amount => _amountString.isEmpty ? 0 : int.parse(_amountString);

  /// 저장 가능 여부 — 금액이 0보다 커야 활성화
  bool get _canSave => _amount > 0 && !_isSaving;

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
  /// Repository를 통해 저장 후 바텀시트를 닫는다
  Future<void> _onSave() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);

    try {
      final repo = getIt<ExpenseRepository>();
      await repo.addExpense(
        ExpenseEntity(
          id: 0,
          amount: _amount,
          category: _selectedCategory.index,
          createdAt: DateTime.now(),
        ),
      );

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textMainColor = isDark ? AppColors.darkTextMain : AppColors.textMain;
    final textSubColor = isDark ? AppColors.darkTextSub : AppColors.textSub;

    // 화면 높이의 85%를 바텀시트 최대 높이로 설정
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: textSubColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── 금액 표시 영역 ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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

          // ── 기록하기 버튼 ────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: AnimatedOpacity(
              opacity: _canSave ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSave ? _onSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.darkTextMain : AppColors.textMain,
                    foregroundColor:
                        isDark ? AppColors.darkBackground : Colors.white,
                    disabledBackgroundColor:
                        isDark ? AppColors.darkTextMain : AppColors.textMain,
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
        ],
      ),
    );
  }
}
