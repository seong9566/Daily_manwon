import 'package:injectable/injectable.dart';

import '../repositories/favorite_expense_repository.dart';

/// 자동학습 추천 템플릿 조회 — 최근 30일 지출 집계
@lazySingleton
class GetFrequentTemplatesUseCase {
  const GetFrequentTemplatesUseCase(this._repository);

  final FavoriteExpenseRepository _repository;

  /// [limit]개까지 자동학습 추천 반환 — 각 항목: {amount, category, frequency}
  Future<List<Map<String, int>>> execute({int limit = 3}) =>
      _repository.getFrequentTemplates(limit: limit);
}
