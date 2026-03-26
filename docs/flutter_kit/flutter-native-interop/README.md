# flutter-native-interop

이 스킬은 Flutter와 Android/iOS 같은 네이티브 플랫폼 간 연동을 유지보수 가능하고 타입 안정적으로 구현할 때 사용합니다.

## 언제 사용하는가

- `MethodChannel` 또는 `EventChannel`을 추가하거나 수정할 때
- Flutter와 네이티브 코드 사이의 통신 구조를 설계할 때
- `Pigeon` 기반 타입 안전 인터페이스를 검토할 때
- 재사용 가능한 플랫폼 기능을 plugin 또는 federated plugin 형태로 분리할 때

## 핵심 요약

- 일회성 호출은 `MethodChannel`, 스트림형 데이터는 `EventChannel`을 사용합니다.
- Dart 쪽 채널 호출은 예외 처리를 포함해 안전하게 감쌉니다.
- 복잡한 네이티브 API는 문자열 기반 매핑보다 `Pigeon`을 우선 검토합니다.
- 네이티브 코드는 feature 내부 또는 재사용 가능한 plugin 구조에 맞게 배치합니다.

