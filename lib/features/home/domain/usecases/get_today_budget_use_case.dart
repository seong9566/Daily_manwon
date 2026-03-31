import 'package:injectable/injectable.dart';

import '../entities/daily_budget.dart';
import '../repositories/daily_budget_repository.dart';

/// 오늘 예산 조회 UseCase — 예산 조회/생성 로직을 캡슐화한다
@lazySingleton
class GetTodayBudgetUseCase {
  const GetTodayBudgetUseCase(this._repository);
  final DailyBudgetRepository _repository;

  /// 오늘 예산을 조회하거나 없으면 기본값으로 생성 후 반환
  Future<DailyBudgetEntity> getOrCreateTodayBudget() =>
      _repository.getOrCreateTodayBudget();

  /// 특정 날짜의 남은 예산 계산
  Future<int> getRemainingBudget(DateTime date) =>
      _repository.getRemainingBudget(date);

  /// 특정 날짜의 예산 조회 (없으면 null)
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date) =>
      _repository.getBudgetByDate(date);
}
