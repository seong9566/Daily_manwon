import '../entities/favorite_expense.dart';

/// 즐겨찾기 지출 템플릿 저장소 인터페이스
abstract interface class FavoriteExpenseRepository {
  /// 즐겨찾기 목록을 usageCount 내림차순으로 반환 (수동 + 자동 모두 포함)
  Future<List<FavoriteExpenseEntity>> getFavorites();

  /// 수동 즐겨찾기 추가
  Future<void> addFavorite(FavoriteExpenseEntity favorite);

  /// ID로 즐겨찾기 삭제 (수동·자동 공통)
  Future<void> deleteFavorite(int id);

  /// ID의 사용 횟수 1 증가 (수동 즐겨찾기 탭 시)
  Future<void> incrementUsageCount(int id);

  /// 최근 사용 상위 3개 조합으로 자동 즐겨찾기를 동기화한다
  Future<void> syncAutoFavorites();
}
