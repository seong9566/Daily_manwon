import 'package:daily_manwon/core/utils/app_date_utils.dart';
import 'package:daily_manwon/features/home/domain/entities/daily_budget.dart';
import 'package:daily_manwon/features/home/domain/repositories/daily_budget_repository.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetTodayBudgetUseCase {
  GetTodayBudgetUseCase(this._repository, this._settingsRepository);

  final DailyBudgetRepository _repository;
  final SettingsRepository _settingsRepository;

  Future<DailyBudgetEntity> getOrCreateTodayBudget() async {
    await _fillMissingDays();
    await _syncWeeklyCarryOvers();
    final carryOver = await _computeTodayCarryOver();
    return _repository.getOrCreateTodayBudget(carryOver: carryOver);
  }

  /// 특정 날짜의 남은 예산 계산
  Future<int> getRemainingBudget(DateTime date) =>
      _repository.getRemainingBudget(date);

  /// 특정 날짜의 예산 조회 (없으면 null)
  Future<DailyBudgetEntity?> getBudgetByDate(DateTime date) =>
      _repository.getBudgetByDate(date);

  Future<void> _fillMissingDays() async {
    final lastDate = await _repository.getLastBudgetDate();
    if (lastDate == null) return;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var cursor = DateTime(lastDate.year, lastDate.month, lastDate.day)
        .add(const Duration(days: 1));
    while (cursor.isBefore(todayDate)) {
      final isSunday = cursor.weekday == DateTime.sunday;
      final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
      int carryOver = 0;
      int? baseAmount;
      if (carryoverEnabled && !isSunday) {
        final prev = cursor.subtract(const Duration(days: 1));
        final prevBudget = await _repository.getBudgetByDate(prev);
        if (prevBudget != null) {
          final prevSpent = await _repository.getTotalExpensesByDate(prev);
          carryOver = prevBudget.effectiveBudget - prevSpent;
          baseAmount = prevBudget.baseAmount;
        }
      } else {
        // 일요일(주 시작)이거나 이월 비활성 — 당일 예산도 이전 날과 동일한 baseAmount 유지
        final prev = cursor.subtract(const Duration(days: 1));
        final prevBudget = await _repository.getBudgetByDate(prev);
        baseAmount = prevBudget?.baseAmount;
      }
      await _repository.getOrCreateBudgetForDate(
        date: cursor,
        carryOver: carryOver,
        baseAmount: baseAmount,
      );
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  /// 이번 주(일~오늘 전날)의 carryOver 체인을 순방향으로 재계산해
  /// DB에 저장된 stale 값을 보정한다.
  ///
  /// - carryoverEnabled=false이면 즉시 return
  /// - 오늘이 일요일(주 첫날)이면 즉시 return
  /// - 일요일 carryOver는 항상 0 (주 리셋)
  /// - 음수 carryOver는 clamp 없이 그대로 전파한다 (초과 지출 정책)
  Future<void> _syncWeeklyCarryOvers() async {
    final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
    if (!carryoverEnabled) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (todayDate.weekday == DateTime.sunday) return;

    final weekStart = AppDateUtils.weekStartOf(todayDate); // 이번 주 일요일
    var cursor = weekStart.add(const Duration(days: 1)); // 월요일부터 시작
    var runningCarryOver = 0; // 일요일 carryOver는 항상 0

    while (cursor.isBefore(todayDate)) {
      final prev = cursor.subtract(const Duration(days: 1));
      final prevBudget = await _repository.getBudgetByDate(prev);
      if (prevBudget == null) break;

      final prevEffective = prevBudget.baseAmount + runningCarryOver;
      final prevSpent = await _repository.getTotalExpensesByDate(prev);
      final newCarryOver = prevEffective - prevSpent;

      final cursorBudget = await _repository.getBudgetByDate(cursor);
      if (cursorBudget != null && cursorBudget.carryOver != newCarryOver) {
        await _repository.updateCarryOverForDate(cursor, newCarryOver);
      }

      runningCarryOver = newCarryOver;
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  Future<int> _computeTodayCarryOver() async {
    final carryoverEnabled = await _settingsRepository.getCarryoverEnabled();
    final today = DateTime.now();
    final isSunday = today.weekday == DateTime.sunday;
    if (!carryoverEnabled || isSunday) return 0;
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayBudget = await _repository.getBudgetByDate(yesterday);
    if (yesterdayBudget == null) return 0;
    final yesterdaySpent = await _repository.getTotalExpensesByDate(yesterday);
    return yesterdayBudget.effectiveBudget - yesterdaySpent;
  }
}
