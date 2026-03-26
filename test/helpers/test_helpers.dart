import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 앱 위젯 생성 헬퍼
Widget createTestApp({
  required Widget child,
}) {
  return ProviderScope(
    child: MaterialApp(
      title: '하루 만원 살기 플래너 - 테스트',
      home: child,
    ),
  );
}

/// 공통 setUp 패턴 - 각 테스트 그룹에서 재사용
void registerSetUpAndTearDown({
  Future<void> Function()? onSetUp,
  Future<void> Function()? onTearDown,
}) {
  setUp(() async {
    if (onSetUp != null) await onSetUp();
  });

  tearDown(() async {
    if (onTearDown != null) await onTearDown();
  });
}

/// ProviderContainer를 생성하고 테스트 종료 시 자동으로 dispose한다.
ProviderContainer createContainer({
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    observers: observers,
  );

  addTearDown(container.dispose);

  return container;
}
