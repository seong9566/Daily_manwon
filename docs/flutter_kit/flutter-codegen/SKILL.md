---
name: flutter-codegen
description: Freezed, JsonSerializable, Riverpod 코드 생성을 실행하고 관리합니다. build_runner 출력물을 안전하게 재생성합니다.
---

# Flutter 코드 생성

프로젝트가 생성된 Dart 코드를 사용할 때 이 규칙을 따릅니다.

## 코드 생성 대상

- Freezed 모델 (`@freezed` 주석)
- JSON 직렬화 (`@JsonSerializable` 주석)
- Riverpod 코드 생성 (`@riverpod` 주석)
- 기타 `build_runner`로 관리되는 생성 코드

## 실행 명령

```bash
dart run build_runner build --delete-conflicting-outputs
```

이 명령:
- 모든 source로부터 코드 생성
- 충돌하는 기존 파일 삭제
- `.g.dart` 파일 생성/업데이트

## 코드 생성 실행 시점

- 새 Freezed 모델 추가
- 기존 Freezed 모델 수정 (필드 추가/제거/이름 변경)
- 새 Riverpod provider 추가
- 기존 Riverpod provider 수정
- `@JsonSerializable` 주석 추가/변경
- 생성 코드에 영향을 미치는 주석 업데이트

## 핵심 규칙

- 소스 변경 직후 코드 생성 즉시 실행
- 생성된 파일은 수정 금지 (프로젝트 명시적 요구 제외)
- 생성된 diff 검토 (예상 변경만 포함되었는지)
- 소스 정의와 생성 결과물은 동일한 변경 세트에 포함
- 코드 생성 실패 시 source 문제 먼저 해결하고 재실행

## 실행 흐름

1. Source 모델 또는 주석 달린 클래스 업데이트
2. 코드 생성 명령 실행
3. 생성 파일을 검토하여 예상 변경만 확인
4. 오래된 생성 파일이 남지 않았는지 확인
5. 적절할 때 source와 생성된 변경을 동일 커밋에 포함

## Freezed 예시

```dart
// lib/presentation/feature/models/user_ui_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_ui_state.freezed.dart';
part 'user_ui_state.g.dart';

@freezed
class UserUiState with _$UserUiState {
  const factory UserUiState({
    required String id,
    required String name,
    @Default(false) bool isLoading,
  }) = _UserUiState;

  factory UserUiState.fromJson(Map<String, dynamic> json) =>
      _$UserUiStateFromJson(json);
}
```

## Riverpod 코드 생성 예시

```dart
// lib/presentation/feature/providers/user_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_notifier.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<UserUiState> build() async {
    // 초기 상태 구축
    return UserUiState.initial();
  }

  Future<void> loadUser(String userId) async {
    state = const AsyncValue.loading();
    // 로직 수행
  }
}
```

## 최종 확인

- 모델 변경 후 코드 생성 실행되었는지 확인
- 생성 파일이 업데이트된 source와 일치하는지 확인
- 무관한 생성 diff가 도입되지 않았는지 확인
- 수동 작성 코드가 생성 로직을 중복하지 않는지 확인
- `part 'xxx.g.dart'` 선언이 모든 주석 달린 클래스에 있는지 확인
