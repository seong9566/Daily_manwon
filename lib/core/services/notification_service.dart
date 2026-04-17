import 'dart:async';

import 'package:daily_manwon/core/services/notification_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 알림 채널 및 알림 ID 상수
const String _channelId = 'daily_budget_channel';
const String _channelName = '하루 만원 알림';
const String _channelDesc = '하루 예산 관리 알림';
const int _lunchId = 1001;
const int _dinnerId = 1002;

/// 알림 본문 텍스트 — UX-05
const String _lunchTitle = '점심 알림';
const String _lunchBody = '오늘 만원 예산 잘 지키고 있나요?';
const String _dinnerTitle = '저녁 알림';
const String _dinnerBody = '오늘 남은 예산을 확인해보세요';

/// 로컬 알림 서비스 싱글톤.
///
/// 역할:
/// - 초기화 (타임존, 플러그인 설정)
/// - 알림 권한 요청
/// - 점심/저녁 알림 스케줄링 및 취소
/// - Foreground 알림 탭 → navigationStream 브로드캐스트
/// - Terminated 상태 알림 탭 → SharedPreferences 저장
@lazySingleton
class NotificationService {
  late final FlutterLocalNotificationsPlugin _plugin;

  /// init()이 호출된 플랫폼에서만 true.
  /// Linux/Windows 등 미지원 플랫폼에서는 false이며 모든 메서드가 no-op으로 동작한다.
  bool _initialized = false;

  /// Foreground 상태에서 알림 탭 시 네비게이션 이벤트를 전달하는 스트림.
  /// HomeScreen에서 listen하여 화면 이동을 처리한다.
  static final StreamController<String> _navigationController =
      StreamController<String>.broadcast();

  /// 외부에서 구독 가능한 네비게이션 스트림
  static Stream<String> get navigationStream => _navigationController.stream;

  /// 앱 종료 시 스트림 자원을 해제한다.
  static void disposeStream() => _navigationController.close();

  /// 알림 서비스 초기화.
  ///
  /// main()에서 configureDependencies() 완료 후 호출해야 한다.
  /// 타임존을 Asia/Seoul로 고정하여 정확한 스케줄링을 보장한다.
  Future<void> init() async {
    _plugin = FlutterLocalNotificationsPlugin();

    // iOS/macOS: 초기화 시 권한 요청 팝업을 띄우지 않음 (설정 화면에서 별도 요청)
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _onForegroundTap,
      // background/terminated 핸들러는 top-level 함수만 허용
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    // 타임존 초기화 — 한국 표준시 고정
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Terminated 상태에서 알림을 탭해 앱이 실행된 경우 payload를 저장
    await _checkLaunchedFromNotification();
    _initialized = true;
  }

  /// 알림 권한을 사용자에게 요청한다.
  /// 설정 화면에서 알림을 처음 활성화할 때 호출한다.
  /// 미지원 플랫폼(Linux/Windows)에서는 false를 반환한다.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();

    bool granted = false;
    if (ios != null) {
      granted =
          await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (macos != null) {
      granted =
          await macos.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (android != null) {
      granted = await android.requestNotificationsPermission() ?? false;
      // Android 14+: exactAllowWhileIdle 스케줄링을 위한 별도 권한 요청
      if (granted) {
        await android.requestExactAlarmsPermission();
      }
    }
    return granted;
  }

  /// 점심 알림을 매일 지정한 시간에 스케줄링한다.
  Future<void> scheduleLunch(TimeOfDay time) => _initialized
      ? _scheduleDaily(_lunchId, time, _lunchTitle, _lunchBody)
      : Future.value();

  /// 저녁 알림을 매일 지정한 시간에 스케줄링한다.
  Future<void> scheduleDinner(TimeOfDay time) => _initialized
      ? _scheduleDaily(_dinnerId, time, _dinnerTitle, _dinnerBody)
      : Future.value();

  /// 점심 알림을 취소한다.
  Future<void> cancelLunch() =>
      _initialized ? _plugin.cancel(_lunchId) : Future.value();

  /// 저녁 알림을 취소한다.
  Future<void> cancelDinner() =>
      _initialized ? _plugin.cancel(_dinnerId) : Future.value();

  /// 모든 예약 알림을 취소한다.
  Future<void> cancelAll() =>
      _initialized ? _plugin.cancelAll() : Future.value();

  // ── private ──────────────────────────────────────────────────────────────

  /// Foreground 상태에서 알림 탭 시 navigationStream에 payload를 발행한다.
  void _onForegroundTap(NotificationResponse response) {
    _navigationController.add(response.payload ?? 'home');
  }

  /// Terminated/Background 상태에서 알림 탭으로 진입한 pending payload를 소비한다.
  ///
  /// payload가 존재하면 true를 반환하고 SharedPreferences에서 제거한다.
  /// HomeScreen이 SharedPreferences에 직접 접근하지 않도록 이 서비스를 거친다.
  Future<bool> checkAndConsumePendingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString('pending_notification_payload');
    if (payload != null) {
      await prefs.remove('pending_notification_payload');
      return true;
    }
    return false;
  }

  /// 앱이 Terminated 상태에서 알림 탭으로 실행된 경우,
  /// getNotificationAppLaunchDetails()로 감지하여 payload를 SharedPreferences에 저장한다.
  Future<void> _checkLaunchedFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'pending_notification_payload',
        details?.notificationResponse?.payload ?? 'home',
      );
    }
  }

  /// 매일 반복되는 알림을 지정 시간에 스케줄링한다.
  /// 이미 지난 시간이면 다음 날로 자동 설정된다.
  /// Android 12+: exact alarm 권한 여부에 따라 exactAllowWhileIdle / inexactAllowWhileIdle 자동 선택.
  Future<void> _scheduleDaily(
    int id,
    TimeOfDay time,
    String title,
    String body,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    // 오늘 이미 지난 시간이면 내일로 이월
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Android 12+: exact alarm 권한 미승인 시 inexact 모드로 폴백
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = android == null ||
        (await android.canScheduleExactNotifications() ?? false);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      // iOS: 로컬 타임존 기준으로 시간 해석
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // 매일 같은 시간에 반복 — 날짜 컴포넌트 무시하고 시/분만 매칭
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
