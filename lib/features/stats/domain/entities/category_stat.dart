import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_stat.freezed.dart';

/// 특정 월의 카테고리별 지출 집계
/// [categoryIndex]: ExpenseCategory.index
/// [totalAmount]: 해당 월 카테고리 총 지출 (원)
/// [percentage]: 전체 대비 비율 (0.0~1.0)
@freezed
sealed class CategoryStat with _$CategoryStat {
  const factory CategoryStat({
    required int categoryIndex,
    required int totalAmount,
    required double percentage,
  }) = _CategoryStat;
}
