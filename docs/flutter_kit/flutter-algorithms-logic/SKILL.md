---
name: flutter-algorithms-logic
description: Flutter와 Dart 애플리케이션에서 효율적인 비즈니스 로직을 설계하고 적절한 자료 구조를 선택합니다.
---

# Flutter 알고리즘 및 로직

Flutter와 Dart 코드에서 비즈니스 로직, 컬렉션 처리, 재사용 가능한 알고리즘 동작을 구현할 때 이 규칙을 따릅니다.

## 핵심 규칙

- **명확함 먼저**: 명확한 로직을 선호
- **의도적 자료 구조**: 자료 구조를 의도적으로 선택
- **불필요한 복잡도 회피**: 자주 실행되는 경로의 알고리즘 비용 회피
- **재사용성**: 비즈니스 로직은 재사용 가능하고 UI 클래스와 독립적

## 복잡도 인식

- 도입하는 작업의 대략적 비용 이해
- 사용자 직면 또는 자주 실행되는 경로에서 `O(n²)` 이상 로직 재고
- 특히 필터링, 정렬, 검색, 중복 제거, 컬렉션 증가 중 중첩 반복에 주의
- 전체 리스트 스캔 반복을 keyed 구조나 캐시된 결과로 해결할 수 있으면 효율성 고려

## 자료 구조 선택

- **Map**: 빠른 키 기반 조회
- **Set**: 고유성과 빠른 포함 확인
- **List**: 정렬된 인덱스 접근과 순차 순회
- **LinkedHashMap / LinkedHashSet**: 삽입 순서와 빠른 조회가 모두 필요할 때
- 기본값 대신 dominant 접근 패턴과 일치하는 구조 선택

## 검색과 정렬

- 이진 검색: 컬렉션이 이미 정렬되었고 반복 조회가 정당할 때만 사용
- 정렬: 일반적인 필요에는 기본 `sort()` 사용
- 정렬 키가 변경되지 않으면 동일 컬렉션을 반복해서 정렬 회피
- 커스텀 비교 로직은 집중되고 결정적
- 원본 데이터 순서와 표시 포맷을 구분 (두 관심사 모두 있을 때)

## 로직 패턴

### Debouncing

사용자 상호작용이 settle될 때까지 실행 대기에 사용. 검색-입력-중, 필터 입력, 빠른 텍스트 변경 같은 패턴에 적용.

### Throttling

최대 interval당 한 번 실행할 때 사용. 반복 스크롤 콜백, 빠른 버튼 tap, 빈번한 이벤트 스트림 같은 패턴에 적용.

### Memoization

비용이 큰 순함수 (입력에만 의존하는 출력)에 사용. 계산 비용이 의미 있을 때와 캐시 수명이 명확할 때만 캐시. 불순 로직이나 변경 가능한 외부 상태에 tied된 값 memoize 금지.

## 비즈니스 로직 조직

- 비즈니스 로직은 순함수나 전용 domain service에 배치
- 복잡한 로직을 위젯 내에 묻지 않음
- Guard clause로 빠르게 무효 입력이나 불가능한 상태에서 실패
- 복잡한 검증은 여러 화면이나 흐름에서 재사용할 때 재사용 가능하게 유지
- 변환, 검증, 결정 로직을 명확성과 재사용성이 개선될 때 분리

## Validation 규칙

- 복잡한 validation을 UI 계층 외에 유지할 때 여러 곳에서 재사용하거나 독립적 테스트 필요
- 경계가 허용하는 한 조기 validation
- 여러 실패 케이스가 중요할 때 구조화된 validation 결과 반환
- 동일 validation 확인이 여러 위젯이나 핸들러에 산재 금지

```dart
// ✅ 좋은 예: 중앙화된 validator
class UserValidator {
  static String? validateEmail(String email) {
    if (email.isEmpty) return '이메일 필수';
    if (!email.contains('@')) return '유효한 이메일 필요';
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return '비밀번호 필수';
    if (password.length < 8) return '8자 이상 필요';
    return null;
  }
}

// ❌ 나쁜 예: 여러 곳에서 validation 중복
if (email.isEmpty) {
  // 에러 표시
}
if (password.isEmpty) {
  // 에러 표시
}
```

## UseCase 패턴과 연계

Domain UseCase에서 비즈니스 로직과 validation 중앙화:

```dart
// lib/domain/usecases/validate_login_usecase.dart
class ValidateLoginUseCase {
  Future<Either<Failure, void>> call(String email, String password) async {
    if (email.isEmpty) return Left(ValidationFailure('이메일 필수'));
    if (password.isEmpty) return Left(ValidationFailure('비밀번호 필수'));

    return Right(null);
  }
}
```

## 검토 체크리스트

- 선택된 자료 구조가 접근 패턴과 일치하는지 확인
- 반복 스캔, 중첩 루프, 반복 정렬이 정당한지 확인
- 이벤트 빈도가 높을 때 debouncing이나 throttling이 적용되는지 확인
- Memoization이 순함수이고 비용이 큰 로직에만 사용되는지 확인
- 비즈니스 로직이 재사용 가능하고 UI 클래스에 내장되지 않았는지 확인
- Validation 로직이 재사용이나 일관성이 중요할 때 중앙화되었는지 확인
