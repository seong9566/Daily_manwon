# flutter-architecture

이 스킬은 Riverpod 기반 Flutter 프로젝트를 Feature-First Clean Architecture로 설계하거나 리뷰할 때 사용하는 기준 문서입니다.

## 언제 사용하는가

- 프로젝트 구조를 처음 설계할 때
- feature, layer, model, repository, data source 책임을 나눌 때
- Domain, UI State, API Model 경계를 정리할 때
- 아키텍처 규칙 위반 여부를 리뷰할 때

## 핵심 요약

- 의존성 방향은 `Presentation -> Domain <- Data`를 따릅니다.
- Domain 레이어는 순수 Dart로 유지하고 Flutter 의존성을 넣지 않습니다.
- 상태 관리는 Riverpod를 사용합니다.
- 불변 모델링은 `freezed`, HTTP는 `Dio`, 로컬 DB는 `sqlite`를 기준으로 합니다.
- Repository는 Domain Entity를 반환하고, DataSource는 외부 원시 접근만 담당합니다.

