import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings_entity.freezed.dart';

/// 알림 설정 도메인 엔티티.
///
/// TimeOfDay는 freezed 직렬화가 불가하므로 시/분을 int 필드로 분리하여 저장한다.
/// getter를 통해 TimeOfDay로 변환하여 UI에서 사용한다.
@freezed
sealed class NotificationSettingsEntity with _$NotificationSettingsEntity {
  const NotificationSettingsEntity._();

  const factory NotificationSettingsEntity({
    /// 점심 알림 활성화 여부 (기본값: true)
    @Default(true) bool lunchEnabled,

    /// 점심 알림 시 (기본값: 12)
    @Default(12) int lunchTimeHour,

    /// 점심 알림 분 (기본값: 0)
    @Default(0) int lunchTimeMinute,

    /// 저녁 알림 활성화 여부 (기본값: true)
    @Default(true) bool dinnerEnabled,

    /// 저녁 알림 시 (기본값: 20)
    @Default(20) int dinnerTimeHour,

    /// 저녁 알림 분 (기본값: 0)
    @Default(0) int dinnerTimeMinute,
  }) = _NotificationSettingsEntity;

  /// 점심 알림 시간을 TimeOfDay로 변환하는 편의 getter
  TimeOfDay get lunchTimeOfDay =>
      TimeOfDay(hour: lunchTimeHour, minute: lunchTimeMinute);

  /// 저녁 알림 시간을 TimeOfDay로 변환하는 편의 getter
  TimeOfDay get dinnerTimeOfDay =>
      TimeOfDay(hour: dinnerTimeHour, minute: dinnerTimeMinute);
}
