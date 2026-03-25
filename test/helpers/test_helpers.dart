import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 앱 위젯 생성 헬퍼
///
/// ProviderScope로 감싸고 Pretendard 폰트 의존성을 제거하여
/// 테스트 환경에서 안전하게 위젯을 렌더링할 수 있도록 한다.
Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      // 테스트 환경에서는 앱 이름만 지정, 폰트는 기본값 사용
      title: '하루 만원 살기 플래너 - 테스트',
      home: child,
    ),
  );
}

/// 공통 setUp 패턴 - 각 테스트 그룹에서 재사용
///
/// [onSetUp] : 테스트 시작 전 실행할 콜백 (선택)
/// [onTearDown] : 테스트 종료 후 실행할 콜백 (선택)
void registerSetUpAndTearDown({
  Future<void> Function()? onSetUp,
  Future<void> Function()? onTearDown,
}) {
  setUp(() async {
    if (onSetUp != null) {
      await onSetUp();
    }
  });

  tearDown(() async {
    if (onTearDown != null) {
      await onTearDown();
    }
  });
}

/// ProviderContainer를 생성하고 테스트 종료 시 자동으로 dispose한다.
///
/// 단위 테스트(위젯 없음)에서 Provider 상태를 직접 검증할 때 사용한다.
ProviderContainer createContainer({
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    overrides: overrides,
    observers: observers,
  );

  // 테스트 종료 시 컨테이너 자원을 반드시 해제한다
  addTearDown(container.dispose);

  return container;
}
