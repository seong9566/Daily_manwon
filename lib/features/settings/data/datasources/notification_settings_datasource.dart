import 'package:daily_manwon/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/notification_settings_entity.dart';

/// Drift SQLite를 통한 알림 설정 로컬 접근 객체.
/// 단일 row(id=1)로 알림 설정을 관리한다.
@lazySingleton
class NotificationSettingsDatasource {
  final AppDatabase _db;

  NotificationSettingsDatasource(this._db);

  /// DB에서 알림 설정 row를 조회한다.
  /// row가 없으면 기본값(점심 12:00, 저녁 20:00 활성화)을 반환한다.
  Future<NotificationSettingsEntity> getSettings() async {
    final row = await (_db.select(_db.notificationSettings)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    // 신규 설치 또는 미설정 유저: 비활성화 기본값 반환 (스케줄 미등록 상태와 일치)
    if (row == null) {
      return const NotificationSettingsEntity(
        lunchEnabled: false,
        dinnerEnabled: false,
      );
    }

    // 'HH:mm' 형식의 문자열을 시/분 int로 파싱
    final lunchParts = row.lunchTime.split(':');
    final dinnerParts = row.dinnerTime.split(':');

    return NotificationSettingsEntity(
      lunchEnabled: row.lunchEnabled,
      lunchTimeHour: int.parse(lunchParts[0]),
      lunchTimeMinute: int.parse(lunchParts[1]),
      dinnerEnabled: row.dinnerEnabled,
      dinnerTimeHour: int.parse(dinnerParts[0]),
      dinnerTimeMinute: int.parse(dinnerParts[1]),
    );
  }

  /// 알림 설정을 DB에 upsert한다.
  /// TimeOfDay는 'HH:mm' 형식 문자열로 변환하여 저장한다.
  Future<void> saveSettings(NotificationSettingsEntity settings) async {
    final lunchTime =
        '${settings.lunchTimeHour.toString().padLeft(2, '0')}:${settings.lunchTimeMinute.toString().padLeft(2, '0')}';
    final dinnerTime =
        '${settings.dinnerTimeHour.toString().padLeft(2, '0')}:${settings.dinnerTimeMinute.toString().padLeft(2, '0')}';

    await _db.into(_db.notificationSettings).insertOnConflictUpdate(
          NotificationSettingsCompanion.insert(
            lunchEnabled: Value(settings.lunchEnabled),
            lunchTime: Value(lunchTime),
            dinnerEnabled: Value(settings.dinnerEnabled),
            dinnerTime: Value(dinnerTime),
          ),
        );
  }
}
