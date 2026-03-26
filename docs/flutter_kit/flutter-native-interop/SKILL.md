---
name: flutter-native-interop
description: s_pass의 Flutter와 네이티브 Android 간 상호운용성을 구현하거나 검토합니다. MethodChannel과 SdkRepository 패턴을 사용합니다.
---

# Flutter 네이티브 상호운용

Flutter 코드가 네이티브 Android와 통신해야 할 때 이 규칙을 따릅니다.

## 올바른 상호운용 메커니즘 선택

- **MethodChannel**: 일회성 요청-응답 흐름 (초기화, 상태 확인, 데이터 요청)
- **EventChannel**: 센서, 연결성, 디바이스 상태 업데이트 같은 지속적인 스트림
- **Pigeon**: API가 여러 메서드로 성장하거나 타입 안전성이 중요할 때
- Plugin 또는 Federated plugin: 여러 앱에서 재사용할 때

## s_pass SDK MethodChannel

채널 이름: `com.example.stc_pass_test/sdk`

제공 메서드:
- `requestPermissions()` → `Future<bool>` — BLE & 위치 권한 요청
- `checkPermissions()` → `Future<bool>` — 권한 확인
- `initSdk(userId: String)` → `Future<void>` — SDK 초기화
- `runBle(power: int)` → `Future<void>` — BLE 광고 시작
- `getQrData()` → `Future<String>` — 암호화된 QR 데이터 생성
- `getNfcStatus()` → `Future<bool>` — NFC 어댑터 상태 확인
- `authenticate()` → `Future<bool>` — 생체인증

## MethodChannel 규칙

- 고유한 reverse-domain 채널 이름 사용 (예: `com.example.app/feature`)
- 채널 이름은 릴리스 후 안정적으로 유지
- 메서드 이름은 명확하고 일관성 있음
- Dart 측의 모든 호출을 `try-catch`로 `PlatformException` 감싸기
- 플랫폼 실패를 앱 수준의 로깅과 제어된 폴백 동작으로 변환
- 페이로드 형태가 알려지고 안정적일 때 느슨한 구조의 맵 전달 금지

## MethodChannel Dart 패턴

```dart
// lib/core/platform/sdk_channel.dart 예시
import 'package:flutter/services.dart';
import 'package:s_pass/core/error/exceptions.dart';

class SdkChannel {
  static const _channel = MethodChannel('com.example.stc_pass_test/sdk');

  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      throw SdkException(message: e.message ?? '권한 요청 실패');
    }
  }

  Future<void> initSdk(String userId) async {
    try {
      await _channel.invokeMethod('initSdk', {'userId': userId});
    } on PlatformException catch (e) {
      throw SdkException(message: e.message ?? 'SDK 초기화 실패');
    }
  }
}
```

## SdkRepository 패턴

`SdkChannel`을 직접 호출하지 않습니다. `SdkRepository`를 통해서만 접근:

```dart
// lib/data/repositories/sdk_repository.dart 예시
class SdkRepository implements ISdkRepository {
  final SdkChannel _sdkChannel;

  Future<void> initializeSdk(String userId) async {
    try {
      await _sdkChannel.initSdk(userId);
    } on SdkException catch (e) {
      throw SdkFailure(message: e.message);
    }
  }
}
```

## EventChannel 규칙

- 참 스트림 데이터에만 `EventChannel` 사용
- 네이티브 측에서 `onListen`과 `onCancel` 구현
- 리스너가 더 이상 필요 없을 때 모든 Dart 구독 해제
- 취소 중에 네이티브 리스너, 콜백, 옵저버 제거
- 중복 구독과 리소스 누수 방지

## Pigeon으로 타입 안전성 확보

- 복잡한 네이티브 API에는 문자열 키와 임의의 맵 대신 `Pigeon` 사용
- 단일 계약에서 host API와 Flutter API 생성
- 스키마는 작고, 명시적이고, 버전 관리 가능하게 유지
- 계약 변경 시마다 바인딩 재생성
- 기능 로직을 연결하기 전에 생성된 인터페이스 검토

## 네이티브 코드 의도적 구조

- 통합이 기능 로컬일 때 관련 기능 근처에 플랫폼 코드 배치
- 같은 네이티브 로직을 여러 기능에서 공유할 때 전용 plugin이나 `plugins/` 디렉토리 사용
- Dart와 네이티브 계층 간에 네이밍 미러링하여 소유권 명확화
- 전송 코드를 비즈니스 로직과 분리. 채널 핸들러는 빠르게 플랫폼 서비스로 위임

## 에러 처리와 라이프사이클

- 지원하지 않는 플랫폼은 명시적으로 처리
- 네이티브 기능이 없거나 권한이 부족할 때 예측 가능하게 실패
- 네이티브 호출 중 UI 스레드 블로킹 회피
- 위젯 폐기나 서비스 종료 중에 오래된 리스너, 옵저버, 콜백 정리
- 필수 권한, 설정 단계, 플랫폼 제한 사항을 통합 근처에 문서화

## iOS 지원 계획

s_pass는 현재 Android-only입니다. iOS 지원 추가 시:
- MethodChannel 메서드를 Swift로 구현
- 동일한 Dart 인터페이스 유지
- 플랫폼 특화 코드는 조건부 컴파일로 분리

## 검토 체크리스트

- 선택된 상호운용 메커니즘이 데이터 흐름과 일치하는지 확인
- `MethodChannel` 호출이 `PlatformException` 처리하는지 확인
- `EventChannel` 리스너가 올바르게 취소되는지 확인
- 복잡한 API가 취약한 맵 기반 페이로드 대신 `Pigeon` 사용하는지 확인
- 네이티브 코드 위치가 기능 소유권이나 plugin 재사용 필요성과 일치하는지 확인
- 라이프사이클 정리와 권한 처리가 완료되었는지 확인
- 모든 네이티브 호출이 Repository 또는 DataSource를 통하는지 확인
