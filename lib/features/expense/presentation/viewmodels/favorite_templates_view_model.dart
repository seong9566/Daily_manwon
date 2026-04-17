import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/widget_service.dart';
import '../../domain/usecases/delete_favorite_use_case.dart';
import '../../domain/usecases/get_favorites_use_case.dart';
import '../../domain/usecases/get_recent_expenses_use_case.dart';
import '../../domain/usecases/increment_favorite_usage_use_case.dart';
import 'favorite_templates_state.dart';

part 'favorite_templates_view_model.g.dart';

/// 즐겨찾기 템플릿 섹션 상태 — home 피처 ViewModel에 의존하지 않고
/// 자체 UseCase를 통해 데이터를 로드한다
@riverpod
class FavoriteTemplatesViewModel extends _$FavoriteTemplatesViewModel {
  @override
  FavoriteTemplatesState build() {
    _load();
    return const FavoriteTemplatesState();
  }

  Future<void> _load() async {
    final favorites =
        (await getIt<GetFavoritesUseCase>().execute()).dataOrNull ?? [];
    final recent =
        (await getIt<GetRecentExpensesUseCase>().execute()).dataOrNull ?? [];
    state = state.copyWith(
      favorites: favorites,
      recentExpenses: recent,
      isLoading: false,
    );
  }

  Future<void> incrementUsage(int id) async {
    final result = await getIt<IncrementFavoriteUsageUseCase>().execute(id);
    if (result.isSuccess) {
      final updated =
          (await getIt<GetFavoritesUseCase>().execute()).dataOrNull ?? [];
      state = state.copyWith(favorites: updated);
    }
  }

  /// 즐겨찾기 삭제 후 state 갱신 및 iOS 위젯 동기화
  Future<void> deleteFavorite(int id) async {
    final result = await getIt<DeleteFavoriteUseCase>().execute(id);
    if (result.isSuccess) {
      final updated =
          (await getIt<GetFavoritesUseCase>().execute()).dataOrNull ?? [];
      state = state.copyWith(favorites: updated);
      // iOS 위젯 즐겨찾기 동기화 — 실패해도 앱 동작에 영향 없음
      getIt<WidgetService>()
          .updateFavorites(
            updated
                .map((f) => {
                      'id': f.id,
                      'amount': f.amount,
                      'category': f.category.index,
                      'memo': f.memo,
                    })
                .toList(),
          )
          .ignore();
    }
  }
}
