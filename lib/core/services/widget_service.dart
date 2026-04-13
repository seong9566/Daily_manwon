import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/domain/usecases/add_expense_use_case.dart';
import '../../features/expense/domain/usecases/increment_favorite_usage_use_case.dart';

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

    // 위젯에서 기록한 pending 지출이 있으면 처리 (fallback 안전장치)
    await _processPendingExpense();
  }

  /// UserDefaults의 pending 지출 URL을 확인하고, 존재하면 콜백을 실행한 뒤 삭제한다.
  ///
  /// HomeWidgetBackgroundWorker가 정상 동작하면 이 메서드는 no-op이다.
  /// 앱이 완전히 종료된 상태에서 위젯 버튼을 탭한 경우 등
  /// 백그라운드 콜백이 실행되지 못한 케이스를 보완한다.
  Future<void> _processPendingExpense() async {
    if (!_appGroupAvailable) return;
    try {
      final pendingUrl = await HomeWidget.getWidgetData<String>(
        'widget.pendingExpenseUrl',
      );
      if (pendingUrl == null || pendingUrl.isEmpty) return;

      debugPrint('WidgetService: pending 지출 발견 — $pendingUrl');

      // pending 키 즉시 삭제 (중복 처리 방지)
      await HomeWidget.saveWidgetData<String?>(
        'widget.pendingExpenseUrl',
        null,
      );

      // 콜백에 위임
      final uri = Uri.tryParse(pendingUrl);
      if (uri != null) {
        // widget_background_callback.dart의 widgetBackgroundCallback 재사용
        // 단, 여기서는 이미 DI가 초기화된 상태
        final amount = int.tryParse(uri.queryParameters['amount'] ?? '');
        final category = int.tryParse(uri.queryParameters['category'] ?? '');
        final favoriteId = int.tryParse(
          uri.queryParameters['favoriteId'] ?? '',
        );
        final memo = Uri.decodeComponent(
          uri.queryParameters['memo'] ?? '',
        );

        if (amount != null && category != null) {
          final addExpenseUseCase =
              GetIt.instance<AddExpenseUseCase>();
          await addExpenseUseCase.execute(
            ExpenseEntity(
              id: 0,
              amount: amount,
              category: category,
              memo: memo,
              createdAt: DateTime.now(),
            ),
          );
          debugPrint(
            'WidgetService: pending 지출 처리 완료 — amount=$amount, category=$category',
          );

          if (favoriteId != null && favoriteId > 0) {
            final incrementUseCase =
                GetIt.instance<IncrementFavoriteUsageUseCase>();
            await incrementUseCase.execute(favoriteId);
          }
        }
      }
    } catch (e) {
      debugPrint('WidgetService: pending 지출 처리 실패 — $e');
    }
  }

  Future<void> updateWidget({
    required int total,
    required int used,
    required int remaining,
    required int streak,
    required List<Map<String, dynamic>> expenses,
    required String catMood,
    List<Map<String, dynamic>> favorites = const [],
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
      await HomeWidget.saveWidgetData<String>('favoritesKey', jsonEncode(favorites));
      await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
      debugPrint('WidgetService: 위젯 갱신 완료');
    } catch (e) {
      debugPrint('WidgetService: 위젯 갱신 실패 — $e');
    }
  }
}
