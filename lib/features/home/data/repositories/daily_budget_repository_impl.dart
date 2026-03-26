import 'package:daily_manwon/features/home/data/datasources/daily_budget_local_datasource.dart';
import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:injectable/injectable.dart';

/// DailyBudgetRepository 인터페이스의 Drift 기반 구현체
@LazySingleton(as: DailyBudgetRepository)
class DailyBudgetRepositoryImpl implements DailyBudgetRepository {
  final DailyBudgetLocalDatasource _datasource;

  DailyBudgetRepositoryImpl(this._datasource);

  @override
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date) =>
      _datasource.getBudgetByDate(date);

  @override
  Future<DailyBudgetEntity> getOrCreateTodayBudget() =>
      _datasource.getOrCreateTodayBudget();

  @override
  Future<int> getRemainingBudget(DateTime date) =>
      _datasource.getRemainingBudget(date);

  @override
  Stream<int> watchRemainingBudget(DateTime date) =>
      _datasource.watchRemainingBudget(date);
}
