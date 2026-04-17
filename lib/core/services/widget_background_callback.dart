import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../constants/app_constants.dart';
import '../di/injection.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/domain/usecases/add_expense_use_case.dart';
import '../../features/expense/domain/usecases/increment_favorite_usage_use_case.dart';

/// 위젯 버튼 탭 시 앱을 열면 home_widget이 이 콜백을 호출한다.
///
/// iOS AppIntent.perform()이 UserDefaults(App Group)에 URL을 기록하고,
/// 앱이 foreground로 전환될 때 HomeWidget.widgetClicked 스트림이 URL을 전달한다.
/// @pragma('vm:entry-point') 필수 — 릴리즈 빌드에서 tree shaking 방지
@pragma('vm:entry-point')
FutureOr<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.scheme != 'addFavoriteExpense') return;

  final amount = int.tryParse(uri.queryParameters['amount'] ?? '');
  final category = int.tryParse(uri.queryParameters['category'] ?? '');
  final favoriteId = int.tryParse(uri.queryParameters['favoriteId'] ?? '');
  final memo = Uri.decodeComponent(uri.queryParameters['memo'] ?? '');

  if (amount == null || category == null) return;

  // DI 초기화 (백그라운드 isolate에서는 별도 초기화 필요)
  // 중복 등록 방지: 이미 초기화된 경우 건너뜀
  if (!getIt.isRegistered<AddExpenseUseCase>()) {
    await configureDependencies();
  }

  // 참고: iOS AppIntent는 UserDefaults에 pendingExpenseUrl을 기록하지만,
  // home_widget 라이브러리가 URL을 직접 이 콜백으로 전달한다.
  // 별도 UserDefaults 클리어 불필요.

  // 지출 저장
  try {
    await getIt<AddExpenseUseCase>().execute(
      ExpenseEntity(
        amount: amount,
        category: ExpenseCategory.values[category],
        memo: memo,
        createdAt: DateTime.now(),
      ),
    );

    debugPrint(
      'widgetBackgroundCallback: 지출 저장 완료 — amount=$amount, category=$category',
    );

    // 즐겨찾기 사용 횟수 증가
    if (favoriteId != null && favoriteId > 0) {
      await getIt<IncrementFavoriteUsageUseCase>().execute(favoriteId);
    }
  } catch (e) {
    debugPrint('widgetBackgroundCallback: 지출 저장 실패 — $e');
  }
}
