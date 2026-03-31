import 'package:injectable/injectable.dart';

import '../entities/notification_settings_entity.dart';
import '../repositories/notification_settings_repository.dart';

/// 알림 설정 저장 UseCase
@lazySingleton
class SaveNotificationSettingsUseCase {
  const SaveNotificationSettingsUseCase(this._repository);

  final NotificationSettingsRepository _repository;

  /// 알림 설정을 DB에 upsert 저장한다.
  Future<void> execute(NotificationSettingsEntity settings) =>
      _repository.saveSettings(settings);
}
