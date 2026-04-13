import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_summary.freezed.dart';

/// 주간 또는 월간 지출 요약
/// [totalSpent]: 기간 내 총 지출 (원)
/// [totalDays]: 집계 대상 날짜 수 (오늘 포함, 미래 제외)
/// [successDays]: 예산 이하 달성일 수
/// [topCategoryIndex]: 가장 많이 지출한 카테고리 index (지출 없으면 null)
@freezed
sealed class ExpenseSummary with _$ExpenseSummary {
  const factory ExpenseSummary({
    required int totalSpent,
    required int totalDays,
    required int successDays,
    required int? topCategoryIndex,
  }) = _ExpenseSummary;
}
