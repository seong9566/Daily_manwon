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
  Future<DailyBudgetEntity> getOrCreateTodayBudget({required int carryOver}) =>
      _datasource.getOrCreateTodayBudget(carryOver: carryOver);

  @override
  Future<DailyBudgetEntity> getOrCreateBudgetForDate({
    required DateTime date,
    required int carryOver,
    int? baseAmount,
  }) =>
      _datasource.getOrCreateBudgetForDate(date: date, carryOver: carryOver, baseAmount: baseAmount);

  @override
  Future<int> getRemainingBudget(DateTime date) =>
      _datasource.getRemainingBudget(date);

  @override
  Stream<int> watchRemainingBudget(DateTime date) =>
      _datasource.watchRemainingBudget(date);

  @override
  Future<DateTime?> getLastBudgetDate() =>
      _datasource.getLastBudgetDate();

  @override
  Future<int> getTotalExpensesByDate(DateTime date) =>
      _datasource.getTotalExpensesByDate(date);
}
