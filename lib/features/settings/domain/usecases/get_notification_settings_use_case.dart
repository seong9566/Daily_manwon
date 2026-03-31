import 'package:injectable/injectable.dart';

import '../entities/notification_settings_entity.dart';
import '../repositories/notification_settings_repository.dart';

/// 알림 설정 조회 UseCase
@lazySingleton
class GetNotificationSettingsUseCase {
  const GetNotificationSettingsUseCase(this._repository);

  final NotificationSettingsRepository _repository;

  /// DB에서 현재 알림 설정을 반환한다. 없으면 기본값 반환.
  Future<NotificationSettingsEntity> execute() => _repository.getSettings();
}
