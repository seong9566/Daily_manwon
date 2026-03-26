# flutter-codegen

이 스킬은 Flutter/Dart 프로젝트에서 코드 생성이 필요한 경우 `build_runner` 기반 생성 코드를 안전하게 갱신하는 데 사용합니다.

## 언제 사용하는가

- 새로운 모델이나 annotation을 추가했을 때
- 기존 생성 대상 클래스를 수정했을 때
- JSON 직렬화나 매핑 코드가 다시 생성되어야 할 때

## 핵심 요약

- 코드 생성 명령은 `dart run build_runner build --delete-conflicting-outputs`를 사용합니다.
- 생성 결과에 영향을 주는 소스를 수정한 뒤 즉시 생성 작업을 다시 수행합니다.
- generated 파일은 직접 수정하지 않고, 원본 소스 변경 후 재생성합니다.
- 소스 변경과 생성 결과는 같은 변경 세트로 관리합니다.

