import '../entities/notification_settings_entity.dart';

/// 알림 설정 레포지토리 인터페이스.
///
/// 구현체는 data 레이어에서 Drift DB를 통해 처리한다.
abstract interface class NotificationSettingsRepository {
  /// DB에서 현재 알림 설정을 조회한다.
  /// 설정 row가 없으면 기본값을 반환한다.
  Future<NotificationSettingsEntity> getSettings();

  /// 알림 설정을 DB에 저장한다 (upsert).
  Future<void> saveSettings(NotificationSettingsEntity settings);
}
