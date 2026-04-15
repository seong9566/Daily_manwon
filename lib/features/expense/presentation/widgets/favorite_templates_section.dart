import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/favorite_expense.dart';
import '../../domain/usecases/get_favorites_use_case.dart';
import '../../domain/usecases/get_frequent_templates_use_case.dart';
import '../../../home/presentation/viewmodels/home_view_model.dart';

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
    final dismissedFreqKeys =
        ref.watch(homeViewModelProvider.select((s) => s.dismissedFreqKeys));

    return favAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (favorites) => freqAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => const SizedBox.shrink(),
        data: (frequent) {
          final favoriteKeys = favorites
              .map((f) => '${f.amount}_${f.category}')
              .toSet();
          final deduped = frequent
              .where(
                (t) =>
                    !favoriteKeys.contains('${t['amount']}_${t['category']}') &&
                    !dismissedFreqKeys.contains(
                      '${t['amount']}_${t['category']}',
                    ),
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
                                await ref
                                    .read(homeViewModelProvider.notifier)
                                    .incrementFavoriteUsage(fav.id);
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
                                await ref
                                    .read(homeViewModelProvider.notifier)
                                    .deleteFavorite(fav.id);
                              } catch (_) {
                                // 삭제 실패 시 UI는 provider 갱신 없이 그대로 유지
                                return;
                              }
                              ref.invalidate(favoritesProvider);
                            },
                          ),
                        );
                      }),
                      // 자동학습 추천 (중복 제거 + 영구 숨김 적용)
                      ...deduped.map((t) {
                        final cat = ExpenseCategory.values[t['category']!];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
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
                            deleteIconColor: isDark
                                ? AppColors.darkTextSub
                                : AppColors.textSub,
                            onPressed: () {
                              onTemplateTap((
                                amount: t['amount']!,
                                category: t['category']!,
                                memo: '',
                              ));
                            },
                            onDeleted: () {
                              ref
                                  .read(homeViewModelProvider.notifier)
                                  .dismissAutoSuggestion(
                                    '${t['amount']}_${t['category']}',
                                  );
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
