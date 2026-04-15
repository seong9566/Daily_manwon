import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/favorite_expense.dart';
import '../../domain/usecases/get_favorites_use_case.dart';
import '../../domain/usecases/get_frequent_templates_use_case.dart';
import '../../../../core/services/widget_service.dart';
import '../../domain/usecases/delete_favorite_use_case.dart';
import '../../domain/usecases/increment_favorite_usage_use_case.dart';

/// 수동 즐겨찾기 + 자동학습 추천 칩 목록
/// 모두 비어 있으면 아무것도 렌더하지 않는다
class FavoriteTemplatesSection extends ConsumerWidget {
  /// 칩 탭 시 호출 — amount, category, memo 전달
  final void Function(({int amount, int category, String memo})) onTemplateTap;

  const FavoriteTemplatesSection({super.key, required this.onTemplateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final freqAsync = ref.watch(frequentTemplatesProvider);

    return favAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (favorites) => freqAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (frequent) {
          final favoriteKeys = favorites
              .map((f) => '${f.amount}_${f.category}')
              .toSet();
          final deduped = frequent
              .where(
                (t) =>
                    !favoriteKeys.contains('${t['amount']}_${t['category']}'),
              )
              .toList();

          if (favorites.isEmpty && deduped.isEmpty) {
            return const SizedBox.shrink();
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...favorites.map((fav) {
                        final cat = ExpenseCategory.values[fav.category];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            avatar: Image.asset(
                              cat.assetPath,
                              width: 18,
                              height: 18,
                            ),
                            label: Text(
                              _formatAmount(fav.amount),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextMain
                                    : AppColors.textMain,
                              ),
                            ),
                            backgroundColor: isDark
                                ? AppColors.darkCard
                                : cat.chipColor,
                            deleteIconColor: isDark
                                ? AppColors.darkTextSub
                                : AppColors.textSub,
                            onPressed: () async {
                              try {
                                await getIt<IncrementFavoriteUsageUseCase>()
                                    .execute(fav.id);
                              } catch (_) {
                                // usageCount 증가 실패는 UI에 영향 없음
                              }
                              onTemplateTap((
                                amount: fav.amount,
                                category: fav.category,
                                memo: fav.memo,
                              ));
                              ref.invalidate(favoritesProvider);
                            },
                            onDeleted: () async {
                              try {
                                await getIt<DeleteFavoriteUseCase>()
                                    .execute(fav.id);
                              } catch (_) {
                                // 삭제 실패 시 UI는 provider 갱신 없이 그대로 유지
                                return;
                              }

                              // iOS HomeWidget favoritesKey 동기화 먼저 —
                              // provider 갱신 전에 실행해 DB 이중 쿼리 방지
                              try {
                                final updated = await getIt<
                                  GetFavoritesUseCase
                                >().execute();
                                await getIt<WidgetService>().updateFavorites(
                                  updated
                                      .map(
                                        (f) => {
                                          'id': f.id,
                                          'amount': f.amount,
                                          'category': f.category,
                                          'memo': f.memo,
                                        },
                                      )
                                      .toList(),
                                );
                              } catch (_) {
                                // 위젯 동기화 실패는 앱 동작에 영향 없음
                              }

                              // 위젯 sync 완료 후 provider 갱신 — DB 재조회 1회만 발생
                              ref.invalidate(favoritesProvider);
                            },
                          ),
                        );
                      }),
                      // 자동학습 추천 (중복 제거된 것만)
                      ...deduped.map((t) {
                        final cat = ExpenseCategory.values[t['category']!];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: Image.asset(
                              cat.assetPath,
                              width: 18,
                              height: 18,
                            ),
                            label: Text(
                              _formatAmount(t['amount']!),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSub
                                    : AppColors.textSub,
                              ),
                            ),
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.primaryLight,
                            onPressed: () {
                              onTemplateTap((
                                amount: t['amount']!,
                                category: t['category']!,
                                memo: '',
                              ));
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
    }
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}원';
  }
}

/// 수동 즐겨찾기 프로바이더
final favoritesProvider = FutureProvider<List<FavoriteExpenseEntity>>((
  ref,
) async {
  return getIt<GetFavoritesUseCase>().execute();
});

/// 자동학습 추천 프로바이더
final frequentTemplatesProvider = FutureProvider<List<Map<String, int>>>((
  ref,
) async {
  return getIt<GetFrequentTemplatesUseCase>().execute(limit: 3);
});
