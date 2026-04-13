import 'dart:async';

import 'package:home_widget/home_widget.dart';

import '../di/injection.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/domain/usecases/add_expense_use_case.dart';
import '../../features/expense/domain/usecases/increment_favorite_usage_use_case.dart';

/// 위젯 버튼 탭 시 앱 없이 백그라운드에서 실행되는 콜백
///
/// home_widget의 [HomeWidget.registerInteractivityCallback]으로 등록된다.
/// URI scheme: `addFavoriteExpense://add?amount=X&category=Y&favoriteId=Z`
///
/// @pragma('vm:entry-point') 필수 — 릴리즈 빌드에서 tree shaking 방지
@pragma('vm:entry-point')
FutureOr<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.scheme != 'addFavoriteExpense') return;

  final amount = int.tryParse(uri.queryParameters['amount'] ?? '');
  final category = int.tryParse(uri.queryParameters['category'] ?? '');
  final favoriteId = int.tryParse(uri.queryParameters['favoriteId'] ?? '');

  if (amount == null || category == null) return;

  // DI 초기화 (백그라운드 isolate에서는 별도 초기화 필요)
  await configureDependencies();

  // 지출 저장
  await getIt<AddExpenseUseCase>().execute(
    ExpenseEntity(
      id: 0,
      amount: amount,
      category: category,
      createdAt: DateTime.now(),
    ),
  );

  // 즐겨찾기 사용 횟수 증가
  if (favoriteId != null && favoriteId > 0) {
    await getIt<IncrementFavoriteUsageUseCase>().execute(favoriteId);
  }
}
