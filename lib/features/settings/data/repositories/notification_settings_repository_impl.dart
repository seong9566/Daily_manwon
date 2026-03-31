import 'package:injectable/injectable.dart';

import '../../domain/entities/notification_settings_entity.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import '../datasources/notification_settings_datasource.dart';

/// NotificationSettingsRepository 인터페이스의 Drift 기반 구현체
@LazySingleton(as: NotificationSettingsRepository)
class NotificationSettingsRepositoryImpl
    implements NotificationSettingsRepository {
  final NotificationSettingsDatasource _datasource;

  NotificationSettingsRepositoryImpl(this._datasource);

  @override
  Future<NotificationSettingsEntity> getSettings() {
    return _datasource.getSettings();
  }

  @override
  Future<void> saveSettings(NotificationSettingsEntity settings) {
    return _datasource.saveSettings(settings);
  }
}
