---
name: flutter-architecture
description: daily_manwon 프로젝트의 Feature-First 클린 아키텍처를 설계하거나 검토합니다. Riverpod, Injectable, Freezed, Dio, SharedPreferences를 사용합니다.
---

# Flutter 아키텍처

Flutter 프로젝트 구조와 기능 아키텍처 구현 시 이 규칙을 따릅니다.

## 기술 스택

- Flutter를 크로스플랫폼 개발에 사용
- Dart를 주 언어로 사용
- Riverpod을 상태 관리로 사용
- Injectable을 의존성 주입으로 사용
- Freezed를 불변 데이터 모델링에 사용
- Dio를 HTTP 네트워킹에 사용
- SharedPreferences를 로컬 데이터 저장에 사용
- MethodChannel을 네이티브 SDK와의 통신에 사용

## 클린 아키텍처 규칙

- Domain 레이어는 순수 Dart만 사용. `package:flutter` 임포트 금지
- 의존성 방향: `Presentation -> Domain <- Data`
- Data 레이어가 Domain 레이어의 인터페이스 구현
- Feature-First 구조로 `DataSource`와 `Repository` 명확히 분리
- `DataSource`는 외부 접근과 원본 데이터 처리만 담당
- `Repository`는 Domain 추상화와 조율만 담당

## 디렉토리 구조

```
lib/
├── core/                         # 공용 코드
│   ├── constants/
│   ├── database/                 # 로컬 데이터베이스 모듈
│   ├── di/                       # 의존성 주입
│   ├── router/                   # 네비게이션 및 라우터 설정
│   ├── services/                 # 공용 프론트엔드 서비스
│   ├── theme/                    # 앱 테마 및 색상
│   ├── utils/                    # 유틸리티 함수 모음
│   └── widgets/                  # 공용 위젯
├── features/                     # 도메인 기능별 모듈
│   ├── feature_a/
│   │   ├── data/                 # Feature-specific Data 레이어
│   │   │   ├── datasources/
│   │   │   │   ├── local/        # 로컬(SharedPreferences/DB) 접근
│   │   │   │   └── remote/       # 리모트(네이티브 SDK/API) 접근
│   │   │   ├── models/           # API/SDK 응답 모델 (*_api_model.dart)
│   │   │   ├── repositories/     # Data 계층의 Repository 구현체
│   │   │   └── mappers/          # 데이터를 Entity로 변환하는 매퍼
│   │   ├── domain/               # Feature-specific Domain 레이어
│   │   │   ├── entities/         # 핵심 비즈니스 모델 (*_entity.dart)
│   │   │   ├── repositories/     # Repository 인터페이스 정의 (*_repository.dart)
│   │   │   └── usecases/         # 개별 비즈니스 유스케이스
│   │   └── presentation/         # Feature-specific Presentation 레이어
│   │       ├── providers/        # Riverpod Notifier/Provider (*_notifier.dart)
│   │       ├── models/           # UI State 모델 (*_ui_state.dart)
│   │       ├── screens/          # 화면 단위 위젯
│   │       └── widgets/          # 기능 전용 부분 위젯
│   └── feature_b/
│       └── (동일 구조)
└── main.dart
```

## Riverpod 상태 관리

- Riverpod을 BLoC 대신 사용
- `Notifier`, `AsyncNotifier` 또는 동등한 provider 패턴 사용
- Provider 상태 전이는 명시적이고 예측 가능해야 함
- 비즈니스 로직을 위젯에 배치하지 않음
- Provider는 UseCase나 Repository와 협력하여 UI 준비 상태 노출
- 위젯은 렌더링과 사용자 상호작용에만 집중

## 3-계층 데이터 모델 패턴

각 계층마다 별도의 모델 타입 사용:

### API 계층 (`ItemApiModel`)

- 네이티브 SDK/서버에서 받은 원본 응답 표현
- API 계약에 정의된 모든 필드 포함
- 백엔드 페이로드 구조와 최대한 가까움

### Domain 계층 (`ItemEntity`)

- 내부 비즈니스 모델 표현
- 비즈니스 로직에 필요한 필드만 포함
- 전송용 또는 불필요한 API 필드 제거

### UI 계층 (`ItemUiState`)

- UI 렌더링에 최적화된 데이터 표현
- 파싱되고 포맷팅된 표시 준비 완료 값 저장
- UI 변환 로직 결과만 포함

## 데이터 모델 규칙

- Freezed를 사용하여 불변 데이터 모델 정의
- API, Domain, UI 계층별로 별도 타입 정의
- UI가 API 모델 직접 사용 금지
- UI가 Domain 모델 직접 사용 금지 (UI State 기대)
- UI State 모델은 Domain Entity에서 파생
- Domain Entity는 API 모델에서 파생
- Domain Entity를 UI State에서 파생 금지
- API 모델에서 UI State로 직접 파생 금지 (명시적 예외 제외)

## Repository와 DataSource 패턴

- Repository는 여러 DataSource를 조율하고 Domain Entity 반환
- DataSource는 원본 SDK/API 접근과 API 모델 또는 원본 결과 반환
- Repository를 기능의 진실 공급원으로 취급
- API-to-Domain 매핑은 Repository 계층 또는 그 계층의 매퍼에서
- DataSource에 매핑이나 비즈니스 로직 배치 금지
- DataSource 외부에서 백엔드 SDK/API 직접 호출 금지

## ViewModel 책임 범위 (클린 아키텍처 기준)

클린 아키텍처에서 ViewModel(Presenter)은 **자신의 Use Case를 호출하고, 결과를 자신의 UI State로 변환**하는 것만 담당한다.

> **핵심 원칙: ViewModel은 UseCase를 호출하고, Repository 기반 데이터를 읽을 수 있다.
> 다른 ViewModel의 상태는 읽기도, 변경도 하지 않는다.**

### Provider 접근 기준 — "어떻게"가 아닌 "무엇을"

| 대상                                | watch / listen | read (상태 변경)    |
| ----------------------------------- | -------------- | ------------------- |
| **UseCase Provider**                | —              | ✅ 허용 (핵심 책임) |
| **Repository 기반 데이터 Provider** | ✅ 허용        | ❌ 금지             |
| **다른 ViewModel의 state**          | ❌ 금지        | ❌ 금지             |

```dart
// ✅ UseCase 호출 — ViewModel의 핵심 책임
final result = await ref.read(downloadCardUseCaseProvider).call(...);

// ✅ Repository 기반 Provider 읽기
ref.watch(cachedCardListProvider)  // UseCase → Repository 기반이므로 허용

// ✅ 자신의 state 갱신
state = state.copyWith(isLoading: false, error: null);

// ❌ 다른 ViewModel state watch — 읽기라도 Presenter 간 결합 발생
ref.watch(homeViewModelProvider)

// ❌ 다른 ViewModel state 변이
ref.read(homeViewModelProvider.notifier).refresh();
ref.read(lastActivatedCardProvider.notifier).set(card);
ref.invalidate(cachedCardListProvider);
```

`ref.watch(homeViewModelProvider)`가 금지인 이유: 비즈니스 판단에 다른 Presenter의 상태를 사용하게 되어 Presenter 간 결합이 생긴다. 각 ViewModel은 **Use Case에만 의존**해야 한다.

### Screen에서 금지

```dart
// ❌ Screen이 Domain Entity를 직접 보유
case ActivationStartSuccess(:final AccessCard card): // Entity가 Screen에 노출됨

// ❌ Screen이 비즈니스 판단
final isFirstCard = ref.read(homeViewModelProvider).value?.cardList.isEmpty ?? true;
```

Screen은 렌더링과 사용자 이벤트 전달만 담당한다. Domain Entity와 비즈니스 로직은 ViewModel 아래 계층의 책임이다.

### 화면 간 데이터 전달 — 올바른 방법

**방법 A: 네비게이션 인수 (표시용 값만 전달)**

```dart
// ViewModel — 라우팅 신호에 Entity 없이 라우팅 결정값만 포함
sealed class ActivationResult {}
class ActivationSuccess extends ActivationResult {
  final bool isFirstCard;  // 라우팅 결정용만 포함, Entity 없음
}

// Screen — 라우팅만 처리
case ActivationSuccess(:final isFirstCard):
  if (isFirstCard) context.go(AppRoutes.activateSuccess);
  else context.pop(true);
```

**방법 B: Repository를 진실 공급원으로 사용**

```dart
// 성공 화면 ViewModel — Repository 기반 Provider로 최신 데이터 조회
@riverpod
ActivationSuccessInfo? activationSuccessInfo(Ref ref) {
  final lastCard = ref.watch(cachedCardListProvider).valueOrNull?.lastOrNull;
  if (lastCard == null) return null;
  return ActivationSuccessInfo(
    name: lastCard.name ?? '',
    siteLabel: SiteKeyConstants.labelFor(lastCard.siteKey),
  );
}
```

### Presentation 레이어 공유 가변 상태 (`keepAlive` Provider)

- Presentation 레이어 공유 가변 상태는 클린 아키텍처 관점에서 안티패턴이다.
- Repository가 진실 공급원이어야 하며, Presentation 레이어에 별도 가변 상태를 두면 동기화 문제가 발생한다
- 불가피하게 도입할 경우 해당 Provider의 존재 이유와 소유 주체를 주석으로 명시한다
- 장기적으로는 제거하고 Repository 기반 조회로 대체하는 것을 목표로 한다

## 데이터 흐름

```text
[단방향 흐름]

UI Event
  └─► ViewModel (로딩 상태 설정)
        └─► UseCase
              └─► Repository
                    └─► DataSource

DataSource 응답
  └─► Repository (API Model → Domain Entity 매핑)
        └─► UseCase (비즈니스 규칙 적용)
              └─► ViewModel (Domain Entity → UI State 변환, 자신의 state만 갱신)
                    └─► Screen (UI State 렌더링 + 라우팅)
```

**핵심 원칙:**

- 의존성 방향은 항상 안쪽(Domain)을 향한다
- ViewModel ↔ ViewModel 직접 통신 금지 — 공유 데이터는 Repository를 진실 공급원으로 사용
- Screen은 ViewModel의 UI State와 라우팅 신호만 소비한다

## Dart 3 언어 기능

- `sealed class`를 Domain Failure와 닫힌 상태 계층 구조에 사용
- 가벼운 다중값 반환 시 `record` 사용 (별도 클래스보다 나을 때)
- 단일 null 확인 대신 `if (value case final v?)` 선호
- `final`, `interface`, `base`, `sealed` 한정자로 API 의도 명시
- 완전 처리 보장 시 `switch` 식 사용

## 에러 처리

- 계층 경계에서 함수형 에러 처리 선호: `Either<Failure, T>` 또는 `Result<T>` sealed class
- 아키텍처 계층 간 예외 던지기 금지 (명시적 경계 제외)
- DataSource나 Repository 같은 적절한 경계에서 인프라 예외 캐치
- 컨텍스트와 함께 에러 로깅
- UI에 사용자 친화적 에러 메시지 표시
- 조용한 실패 회피
- Sealed Failure나 State 변종을 Provider와 UI에서 철저히 처리

## 네이티브 SDK와의 상호작용

- `SdkChannel` 래퍼를 통해서만 MethodChannel 접근
- 가능한 메서드:
  - `requestPermissions()` — BLE & 위치 권한 요청
  - `checkPermissions()` — 권한 확인
  - `initSdk(userId)` — SDK 초기화
  - `runBle(power)` — BLE 광고 시작
  - `getQrData()` — 암호화된 QR 데이터 생성
  - `getNfcStatus()` — NFC 상태 확인
- `PlatformException`을 `SdkException`으로 변환
- 위젯이나 Provider에서 MethodChannel 직접 호출 금지
- 지원하지 않는 플랫폼은 `MissingPluginException` 처리

## Freezed와 JsonSerializable

- Freezed로 API 모델, Entity, UI State 정의
- `@freezed` 및 `part` 선언 필수
- `dart run build_runner build --delete-conflicting-outputs` 실행
- 모델 변경 후 코드 생성 실행

## 환경 변수

- `flutter_dotenv`로 환경 변수 관리
- `.env.dev`, `.env.prod` 파일 사용
- 민감한 정보 (API 키, 토큰) 저장 금지

## 코딩 가이드라인

- 파일은 약 300줄 이하로 유지
- 함수는 약 50줄 이하로 유지
- 클래스는 초점이 명확하고 공개 API 작음
- `dynamic` 사용 금지. 명시적 타입이나 `Object?` 선호
- Guard clause와 조기 반환으로 중첩 감소
- `TextEditingController`, `ScrollController`, `FocusNode`, `StreamSubscription`, `AnimationController` 등은 `initState()`에서 초기화
- `dispose()`에서 폐기
- `print()` 사용 금지. `Logger` 사용
- 반복된 위젯이나 로직은 공용 위젯이나 유틸리티로 추출

## 문서 작성 규칙

- 무엇이 아닌 왜를 설명하는 주석 작성
- 공개 클래스와 공개 메서드는 `///` 주석으로 문서화
- 소스 파일에 버전 이력 주석이나 "fixed by" 주석 추가 금지
- Git 이력을 변경 이력의 진실 공급원으로 유지

## 검토 체크리스트

- 계층 의존성이 `Presentation -> Domain <- Data` 따르는지 확인
- Domain 계층이 Flutter 없는지 확인
- DataSource가 원본 외부 접근만 포함하는지 확인
- Repository가 Domain Entity 반환하고 매핑 책임을 소유하는지 확인
- UI가 Domain이나 API 모델 직접 사용하지 않는지 확인
- Freezed 기반 불변 모델과 매핑 규칙이 프로젝트 규약 따르는지 확인
- 에러 처리가 명시적이고 철저한지 확인
- 로깅, 라이프사이클 정리, 공용 코드 배치가 일관성 있는지 확인
