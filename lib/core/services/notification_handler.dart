import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background/Terminated 상태에서 알림을 탭했을 때 호출되는 핸들러.
///
/// ⚠️ top-level 함수 필수 — isolate에서 실행되므로 클래스 메서드로 정의 불가.
/// @pragma('vm:entry-point') 어노테이션으로 tree-shaking 방지.
@pragma('vm:entry-point')
void onBackgroundNotificationTap(NotificationResponse response) {
  _savePendingPayload(response.payload);
}

/// 알림 탭 payload를 SharedPreferences에 저장하여 앱 복귀 시 처리할 수 있도록 한다.
/// HomeScreen의 _handlePendingNotification()에서 소비된다.
Future<void> _savePendingPayload(String? payload) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pending_notification_payload', payload ?? 'home');
}
