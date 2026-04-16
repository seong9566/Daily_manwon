import '../entities/favorite_expense.dart';

/// 즐겨찾기 지출 템플릿 저장소 인터페이스
abstract interface class FavoriteExpenseRepository {
  /// 즐겨찾기 목록을 usageCount 내림차순으로 반환
  Future<List<FavoriteExpenseEntity>> getFavorites();

  /// 즐겨찾기 추가
  Future<void> addFavorite(FavoriteExpenseEntity favorite);

  /// ID로 즐겨찾기 삭제
  Future<void> deleteFavorite(int id);

  /// ID의 사용 횟수 1 증가 (탭 시)
  Future<void> incrementUsageCount(int id);
}
