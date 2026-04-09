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
}
