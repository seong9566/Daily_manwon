import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

/// iOS 홈 위젯에 데이터를 기록하고 강제 갱신한다.
///
/// App Group 미설정 환경(Xcode 설정 전, 시뮬레이터 등)에서는 안전하게 no-op 처리한다.
@lazySingleton
class WidgetService {
  static const _appGroupId = 'group.seong.dailyManwon.homeWidget';

  /// App Group 접근 가능 여부 — init() 호출 전까지 false
  bool _appGroupAvailable = false;

  /// 앱 시작 시 App Group 접근 가능 여부를 검증한다.
  /// main.dart의 configureDependencies() 이후 호출할 것.
  Future<void> init() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.saveWidgetData<int>('_ping', 1);
      _appGroupAvailable = true;
      debugPrint('WidgetService: App Group 초기화 성공 ($_appGroupId)');
    } catch (e) {
      debugPrint('WidgetService: App Group 접근 불가 — Xcode 설정을 확인하세요. ($e)');
    }
  }

  Future<void> updateWidget({
    required int total,
    required int used,
    required int remaining,
    required int streak,
    required List<Map<String, dynamic>> expenses,
    required String catMood,
  }) async {
    if (!_appGroupAvailable) {
      debugPrint('WidgetService: updateWidget 스킵 — App Group 미초기화');
      return;
    }
    debugPrint(
      'WidgetService: updateWidget 호출 — total=$total, used=$used, remaining=$remaining, streak=$streak, catMood=$catMood',
    );
    try {
      await HomeWidget.saveWidgetData<int>('totalKey', total);
      await HomeWidget.saveWidgetData<int>('usedKey', used);
      await HomeWidget.saveWidgetData<int>('remainingKey', remaining);
      await HomeWidget.saveWidgetData<int>('streakKey', streak);
      await HomeWidget.saveWidgetData<String>('expensesKey', jsonEncode(expenses));
      await HomeWidget.saveWidgetData<String>('cat_mood', catMood);
      await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
      debugPrint('WidgetService: 위젯 갱신 완료');
    } catch (e) {
      debugPrint('WidgetService: 위젯 갱신 실패 — $e');
    }
  }
}
