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

    // 위젯에서 기록한 pending 지출이 있으면 처리 (콜드 스타트 경로)
    await processPendingWidgetExpense();
  }

  /// UserDefaults의 pending 지출 URL 배열을 확인하고, 존재하면 순서대로 저장한 뒤 키를 초기화한다.
  ///
  /// 호출 위치:
  ///  - [init]: 콜드 스타트 시
  ///  - HomeViewModel.processPendingWidgetExpense: 앱 포그라운드 복귀 시
  ///
  /// Swift IntentIntent는 버튼 탭마다 URL을 JSON 배열에 append 한다.
  /// 연속 탭 시에도 모든 지출이 누락 없이 처리되도록 배열 전체를 순회한다.
  Future<void> processPendingWidgetExpense() async {
    if (!_appGroupAvailable) return;
    try {
      final pendingRaw = await HomeWidget.getWidgetData<String>(
        'widget.pendingExpenseUrl',
      );
      if (pendingRaw == null || pendingRaw.isEmpty) return;

      // Swift가 JSON 배열로 저장; 이전 버전 호환을 위해 단일 URL 포맷도 처리
      List<String> pendingUrls;
      if (pendingRaw.startsWith('[')) {
        final decoded = jsonDecode(pendingRaw) as List<dynamic>;
        pendingUrls = decoded.cast<String>();
      } else {
        pendingUrls = [pendingRaw];
      }

      if (pendingUrls.isEmpty) return;

      debugPrint('WidgetService: pending 지출 ${pendingUrls.length}건 발견');

      // 키 즉시 초기화 — 처리 전에 비워야 이후 탭이 새 배열로 누적된다
      await HomeWidget.saveWidgetData<String>('widget.pendingExpenseUrl', '[]');

      final addExpenseUseCase = GetIt.instance<AddExpenseUseCase>();
      final incrementUseCase = GetIt.instance<IncrementFavoriteUsageUseCase>();

      for (final urlString in pendingUrls) {
        final uri = Uri.tryParse(urlString);
        if (uri == null) continue;

        final amount = int.tryParse(uri.queryParameters['amount'] ?? '');
        final category = int.tryParse(uri.queryParameters['category'] ?? '');
        final favoriteId = int.tryParse(uri.queryParameters['favoriteId'] ?? '');
        final memo = Uri.decodeComponent(uri.queryParameters['memo'] ?? '');

        if (amount == null || category == null) continue;

        await addExpenseUseCase.execute(
          ExpenseEntity(
            id: 0,
            amount: amount,
            category: category,
            memo: memo,
            createdAt: DateTime.now(),
          ),
        );

        if (favoriteId != null && favoriteId > 0) {
          await incrementUseCase.execute(favoriteId);
        }
      }

      debugPrint('WidgetService: pending 지출 ${pendingUrls.length}건 처리 완료');
    } catch (e) {
      debugPrint('WidgetService: pending 지출 처리 실패 — $e');
    }
  }

  /// 위젯 "직접 입력(+)" 버튼 탭 여부를 확인하고 플래그를 초기화한다.
  ///
  /// `true` 반환 시 caller(HomeScreen)에서 showExpenseAddBottomSheet를 호출해야 한다.
  ///
  /// 플래그 계약 (Swift ↔ Dart):
  ///   Swift(OpenAddExpenseIntent): UserDefaults[pendingActionKey] = "open_add_expense"
  ///   Dart: `HomeWidget.getWidgetData<String>('widget.pendingAction') == 'open_add_expense'`
  ///
  /// 플래그 초기화: ''(빈 문자열)로 덮어쓴다.
  /// getWidgetData는 키 미존재 시 null, 클리어 후엔 ''를 반환하므로
  /// `action == 'open_add_expense'` 조건이 중복 트리거를 방지한다.
  Future<bool> checkAndClearPendingOpenExpense() async {
    if (!_appGroupAvailable) return false;
    try {
      final action = await HomeWidget.getWidgetData<String>('widget.pendingAction');
      if (action == 'open_add_expense') {
        await HomeWidget.saveWidgetData<String>('widget.pendingAction', '');
        debugPrint('WidgetService: pending open_add_expense 감지 → 플래그 초기화');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('WidgetService: pending action 확인 실패 — $e');
      return false;
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

  /// 즐겨찾기 목록만 위젯에 갱신한다.
  ///
  /// 지출·잔액 등 나머지 키는 기존 값을 유지하고 favoritesKey만 덮어쓴다.
  /// 즐겨찾기 추가/삭제 시 호출한다.
  Future<void> updateFavorites(List<Map<String, dynamic>> favorites) async {
    if (!_appGroupAvailable) return;
    try {
      await HomeWidget.saveWidgetData<String>(
        'favoritesKey',
        jsonEncode(favorites),
      );
      await HomeWidget.updateWidget(iOSName: 'DailyHomeWidget');
      debugPrint('WidgetService: 즐겨찾기 위젯 갱신 완료 (${favorites.length}건)');
    } catch (e) {
      debugPrint('WidgetService: 즐겨찾기 위젯 갱신 실패 — $e');
    }
  }
}
