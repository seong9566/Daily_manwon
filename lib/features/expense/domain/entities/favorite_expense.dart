import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/constants/app_constants.dart';

part 'favorite_expense.freezed.dart';

/// 즐겨찾기 지출 템플릿 도메인 엔티티
/// - [id]: DB auto-increment 처리. 0은 미저장 상태
/// - [usageCount]: 탭 횟수 — 높을수록 목록 상단에 정렬
@freezed
sealed class FavoriteExpenseEntity with _$FavoriteExpenseEntity {
  const factory FavoriteExpenseEntity({
    @Default(0) int id,
    required int amount,
    required ExpenseCategory category,
    @Default('') String memo,
    @Default(0) int usageCount,
    required DateTime createdAt,
  }) = _FavoriteExpenseEntity;
}
