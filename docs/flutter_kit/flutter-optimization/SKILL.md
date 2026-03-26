---
name: flutter-optimization
description: Flutter와 Dart 런타임 성능을 진단하고 개선합니다. Riverpod rebuild 최적화, lazy 렌더링, SharedPreferences 최적화를 중점합니다.
---

# Flutter 최적화

Flutter와 Dart 코드의 런타임 성능을 진단하거나 개선할 때 이 규칙을 따릅니다.

## 핵심 규칙

- **측정 먼저**: 최적화 전에 측정
- **추측 금지**: 증거 없이 마이크로 최적화 적용 금지
- **병목 식별**: 먼저 병목을 찾고, 측정된 경로만 최적화, 그 후 검증

## 최적화 흐름

1. 느린 현상 또는 회귀 재현
2. 병목 확인: 프레임 렌더링? rebuild 빈도? 파싱? 네트워킹? DB 접근? 순수 Dart 실행?
3. 적절한 도구로 경로 프로파일링
4. 측정된 병목만 최적화
5. 최적화 후 프로파일링 또는 벤치마크 재실행하여 개선 검증
6. 증거가 없으면 가독성 저하 회피

## 프로파일링과 측정

- Flutter DevTools Performance 뷰로 프레임 타이밍과 jank 검사
- Flutter DevTools CPU Profiler로 경로와 비용이 큰 함수 식별
- 메모리 도구로 누수나 객체 부하 의심할 때 사용
- 고립된 순수 Dart 벤치마크에만 `package:benchmark_harness` 사용
- 프로파일링 도구 사용 가능하면 직관에 의존하지 않음

## 경로 규칙

- 단단한 루프 내 작업 최소화
- 반복되는 계산과 객체 생성을 루프 외로 이동 (가능할 때)
- 자주 실행되는 경로에서 반복되는 문자열 포맷팅, 날짜 파싱, 컬렉션 변환 회피
- rebuild-heavy나 loop-heavy 코드의 수명이 짧은 할당 감소
- 검증된 경로에서는 더 단순한 제어 흐름 선호

## 컬렉션 성능

- 빈번한 멤버십 확인은 `Set` 사용
- 정렬된 인덱스 접근은 `List` 사용
- 경로에서 불필요한 중간 컬렉션 회피
- 필요하지 않으면 불필요한 `.toList()`와 `.toSet()` 변환 회피
- 조회 비용이 측정 가능하고 수명이 명확할 때 파생 값 캐시

## Flutter UI 성능

- `build()` 내에서 비용이 큰 작업 금지
- rebuild 범위를 실용적인 수준으로 최소화
- 비자명한 컬렉션은 `ListView.builder`, `GridView.builder`, sliver builders 사용
- 가능한 `const` 위젯 사용하여 rebuild 비용 감소
- `RepaintBoundary`는 프로파일링으로 repaint 격리가 도움이 될 때만 사용
- 자주 rebuild되는 UI 경로에서 레이아웃 깊이와 래퍼 위젯 불필요하게 회피

## Riverpod Rebuild 최적화

- 작은 상태 변경이 넓은 rebuild를 유발할 때 불필요한 provider 재계산 조사
- 각 위젯은 필요한 상태만 watch (ref.watch 범위 최소화)
- 자주 watched 되는 provider에서 비용이 큰 변환 로직 회피
- 한 번의 업데이트가 큰 UI 영역에 펼쳐질 때 dependent provider 체인 재확인

```dart
// ❌ 나쁜 예: 전체 상태 watch
final userProvider = ref.watch(userNotifier);
final name = userProvider.name; // 전체 rebuild 유발

// ✅ 좋은 예: 필요한 부분만 select
final name = ref.watch(userNotifier.select((user) => user.name));
```

## 파싱과 직렬화

- 큰 JSON 파싱은 프로파일링으로 메인 스레드 영향이 보일 때 critical path에서 제거
- 비용이 측정 가능할 때 isolate로 무거운 파싱/변환 수행
- 동일 요청 흐름에서 매핑 작업 반복 회피
- 데이터-backed 화면이 느릴 때 쿼리, 파싱, 매핑 비용 측정

## 네트워킹과 DB 성능

- 상태 변화 중 중복 요청 회피
- 사용자 직면 흐름에서 응답 처리 경량화
- 상호작용 패턴이 허용할 때 요청 batch 또는 debounce
- 단단한 상호작용 루프에서 불필요한 SharedPreferences 읽고 쓰기 회피
- 메모리 필터링보다 targeted 쿼리 선호
- 데이터 backed 화면이 느릴 때 쿼리, 파싱, 매핑 비용 측정

SharedPreferences 최적화:

```dart
// ❌ 나쁜 예: 매번 읽음
Future<String> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') ?? '';
}

// ✅ 좋은 예: Riverpod으로 캐시
final userIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') ?? '';
});
```

## 메모리와 라이프사이클

- Controller, subscription, listener 올바르게 폐기
- GC를 방지하는 retained 참조 감시
- 명확한 수명 정책 없이 큰 객체 캐시 회피
- 반복된 네비게이션이나 화면 사용에서 메모리가 증가하면 누수 조사

## 최적화할 시점

- 프로파일링으로 실제 병목이 보일 때
- 프레임 드롭, jank, 과도한 CPU 사용이 사용자 경험에 영향을 미칠 때
- rebuild, 파싱, 쿼리, 할당 비용이 측정 가능할 때
- 사용자 직면 또는 운영상 중요하지 않은 코드 경로는 최적화 금지

## 검토 체크리스트

- 변경 전 문제가 측정되었는지 확인
- 병목이 올바르게 식별되었는지 확인
- 최적화가 검증된 경로를 대상으로 했는지 확인
- `build()`와 자주 watched 되는 provider가 무거운 작업을 하지 않는지 확인
- 크거나 비제한적인 컬렉션에 lazy 렌더링이 있는지 확인
- 필요할 때 큰 파싱 작업이 critical UI path 외에 있는지 확인
- Dio와 SharedPreferences 사용이 중복이나 과도한 작업을 회피하는지 확인
- 최적화 결과가 변경 후 검증되었는지 확인
