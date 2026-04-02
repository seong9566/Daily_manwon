import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

/// iOS 홈 위젯에 데이터를 기록하고 강제 갱신한다.
@lazySingleton
class WidgetService {
  static const _appGroupId = 'group.dailyManWon.dailyHomeWidget';

  Future<void> updateWidget({
    required int total,
    required int used,
    required int remaining,
    required int streak,
    required List<Map<String, dynamic>> expenses,
  }) async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<int>('totalKey', total);
    await HomeWidget.saveWidgetData<int>('usedKey', used);
    await HomeWidget.saveWidgetData<int>('remainingKey', remaining);
    await HomeWidget.saveWidgetData<int>('streakKey', streak);
    await HomeWidget.saveWidgetData<String>('expensesKey', jsonEncode(expenses));
    await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
  }
}
