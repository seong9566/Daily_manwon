import 'package:daily_manwon/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:daily_manwon/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

/// SettingsRepository 인터페이스의 Drift 기반 구현체
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<bool> getIsDarkMode() {
    return _datasource.getIsDarkMode();
  }

  @override
  Future<void> setIsDarkMode({required bool value}) {
    return _datasource.setIsDarkMode(value: value);
  }

  @override
  Future<int> getDailyBudget() {
    return _datasource.getDailyBudget();
  }

  @override
  Future<void> setDailyBudget(int amount) {
    return _datasource.setDailyBudget(amount);
  }

  @override
  Future<bool> getCarryoverEnabled() => _datasource.getCarryoverEnabled();

  @override
  Future<void> setCarryoverEnabled(bool enabled) =>
      _datasource.setCarryoverEnabled(enabled);

  @override
  Future<bool> hasSeenNewWeekThisWeek(String weekKey) =>
      _datasource.hasSeenNewWeekThisWeek(weekKey);

  @override
  Future<void> markNewWeekSeen(String weekKey) =>
      _datasource.markNewWeekSeen(weekKey);

  @override
  Future<Set<String>> getDismissedAutoSuggestions() =>
      _datasource.getDismissedAutoSuggestions();

  @override
  Future<void> addDismissedAutoSuggestion(String key) =>
      _datasource.addDismissedAutoSuggestion(key);
}
