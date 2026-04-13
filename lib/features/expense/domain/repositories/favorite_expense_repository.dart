import '../entities/favorite_expense.dart';

/// 즐겨찾기 지출 템플릿 저장소 인터페이스
abstract interface class FavoriteExpenseRepository {
  /// 즐겨찾기 목록을 usageCount 내림차순으로 반환
  Future<List<FavoriteExpenseEntity>> getFavorites();

  /// 새로운 즐겨찾기 추가
  Future<void> addFavorite(FavoriteExpenseEntity favorite);

  /// ID로 즐겨찾기 삭제
  Future<void> deleteFavorite(int id);

  /// ID의 사용 횟수 1 증가
  Future<void> incrementUsageCount(int id);

  /// 최근 30일 지출에서 상위 [limit]개의 자주 쓰는 템플릿 반환
  /// 반환 Map keys: `amount`, `category`, `frequency`
  Future<List<Map<String, int>>> getFrequentTemplates({int limit = 3});
}
