// ignore_for_file: unused_import
import 'package:mocktail/mocktail.dart';

// TODO: Drift AppDatabase가 구현되면 아래 import를 활성화한다.
// import 'package:daily_manwon/core/database/app_database.dart';

// TODO: 도메인 레포지토리 인터페이스가 구현되면 아래 import를 활성화한다.
// import 'package:daily_manwon/features/expense/domain/repositories/expense_repository.dart';

/// AppDatabase Mock - Drift DB가 구현된 후 실제 클래스로 교체한다.
///
/// 현재는 placeholder로만 존재하며, DB 레이어가 완성되면
/// `class MockAppDatabase extends Mock implements AppDatabase {}` 로 변경한다.
// TODO: AppDatabase 구현 후 활성화
// class MockAppDatabase extends Mock implements AppDatabase {}

/// ExpenseRepository Mock - 도메인 레이어 구현 후 활성화한다.
// TODO: ExpenseRepository 구현 후 활성화
// class MockExpenseRepository extends Mock implements ExpenseRepository {}

/// mocktail에서 커스텀 객체를 인자로 사용할 때 registerFallbackValue()가 필요하다.
///
/// 각 테스트 파일의 setUpAll() 또는 이 함수를 통해 fallback 값을 등록한다.
/// 예시:
/// ```dart
/// setUpAll(() {
///   registerMockFallbackValues();
/// });
/// ```
void registerMockFallbackValues() {
  // TODO: 커스텀 엔티티/DTO 클래스가 생기면 여기에 fallback 값을 등록한다.
  // 예: registerFallbackValue(const ExpenseEntity(...));
}
