import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_expense.freezed.dart';

/// 즐겨찾기 지출 템플릿 도메인 엔티티
/// - [category]: ExpenseCategory enum의 index 값
/// - [usageCount]: 탭 횟수 — 높을수록 목록 상단에 정렬
/// - [isAuto]: true면 자동학습으로 추가된 row (수동 row와 동일 조합 공존 가능)
@freezed
sealed class FavoriteExpenseEntity with _$FavoriteExpenseEntity {
  const factory FavoriteExpenseEntity({
    required int id,
    required int amount,
    required int category,
    @Default('') String memo,
    @Default(0) int usageCount,
    @Default(false) bool isAuto,
    required DateTime createdAt,
  }) = _FavoriteExpenseEntity;
}
