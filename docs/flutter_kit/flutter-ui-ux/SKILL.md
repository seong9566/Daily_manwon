---
name: flutter-ui-ux
description: s_pass의 Flutter UI/UX를 구축하거나 검토합니다. 일관된 테마, 재사용 가능한 위젯 구조, 반응형 레이아웃, 접근성을 적용합니다.
---

# Flutter UI/UX

Flutter 표현 코드를 작성하거나 수정할 때 이 규칙을 따릅니다.

## 기존 패턴부터 시작

- 새로운 UI 패턴을 도입하기 전에 기존 기능, 테마 계층, 공용 위젯 검토
- 디자인 시스템이 이미 있으면 프로젝트의 현재 디자인 언어 유지
- 반복이나 불일치를 정당화할 때만 새로운 토큰이나 공용 컴포넌트 도입

## AppColors와 테마 토큰

Daily_manwon AppColors:

```dart
// Primary & Base
static const Color primary = Color(0xFF000000);
static const Color primaryLight = Color(0xFFEEEEEE);
static const Color white = Color(0xFFFFFFFF);
static const Color black = Color(0xFF000000);
static const Color background = Color(0xFFFFFFFF);

// 예산/감정 상태 색상
static const Color budgetComfortable = Color(0xFF000000);
static const Color budgetWarning = Color(0xFFF5A623);
static const Color budgetDanger = Color(0xFFE85D5D);
static const Color budgetOver = Color(0xFFC0392B);
static const Color accent = Color(0xFF4A90D9);

// 텍스트 및 UI 구조요소
static const Color textMain = Color(0xFF3D3D3D);
static const Color textSub = Color(0xFF8E8E8E);
static const Color divider = Color(0xFFF0E8E0);
static const Color border = Color(0xFFE5E7EB);
static const Color card = Color(0xFFFFFFFF);

// 다크 모드 전용 속성 및 기타 카테고리/칩 색상 (app_colors.dart 참조)
```

이 색상들을 하드코딩 대신 항상 `AppColors`에서 참조합니다.

## 렌더링 안전한 기본값

- 모든 위젯은 가능한 `const` 선언
- 긴 컬렉션은 lazy 렌더링 사용. `ListView.builder`, `GridView.builder`, sliver builders 사용
- 고비용 애니메이션 영역은 `RepaintBoundary`로 래핑 (repaint 부하가 예상될 때)
- 대용량 파일(약 1MB 이상)은 UI 스레드 외에서 파싱/변환 작업 수행
- 비동기 후 `BuildContext` 사용 전 `mounted` 확인

## 디자인 토큰 적용

- 기능 위젯에 하드코딩된 색상, 간격, 반경, 타이포그래피 금지
- 프로젝트 토큰 계층 사용: `AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`
- 또는 `Theme.of(context).colorScheme`와 `Theme.of(context).textTheme` 사용 (프로젝트 패턴에 따라)
- 간격은 `SizedBox`나 패딩 상수 사용
- 라이트 및 다크 테마 지원. 단일 밝기 모드 가정 금지
- 텍스트 크기 조정 존중. 접근성 폰트 크기에서 깨지는 레이아웃 금지

## 위젯 재사용 구조

- 각 위젯은 하나의 명확한 책임
- 재사용 가능한 동작은 별도 파라미터로 노출
- 반복되거나 복잡한 UI는 전용 위젯 클래스로 추출
- 큰 `_build*()`의 비공개 메서드 숨김 금지. 작은 위젯 클래스 선호
- 재사용 가능한 위젯은 공용 위치에 배치: `core/views/widgets` 또는 기능별 equivalent
- 테스트 접근이 필요할 때 중요한 상호작용 위젯에 안정적인 `Key` 값 추가

## 카드 및 컨테이너 스타일

- `elevation: 6`과 `BorderRadius.circular(16)`로 카드 일관성 유지
- Material 3 스타일 적용

## 예측 가능한 상호작용 패턴

- 복잡한 스크롤 화면은 `CustomScrollView`와 sliver 사용
- 주 긍정 액션 (추가, 생성)은 floating action button 사용 (프로젝트 패턴과 일치할 때)
- 스크롤 컨텐츠에 충분한 하단 패딩 추가 (FAB, 하단 바, 지속적인 footer가 컨텐츠를 덮을 수 있을 때)
- 다단계 또는 복잡한 폼은 `showModalBottomSheet` 대신 전체 `Scaffold` 화면 선호
- 모바일 레이아웃에서 주 액션은 시각적으로 명확하고 접근하기 쉬워야 함

## 반응형 디자인

- 모바일 먼저, 이후 태블릿과 데스크톱 적응
- 페이지 수준 breakpoint에는 `MediaQuery.sizeOf(context)` 사용
- 로컬 레이아웃 제약에는 `LayoutBuilder` 사용
- 약 600-840 logical pixels를 태블릿, 840 이상을 데스크톱으로 간주 (프로젝트 정의 있으면 그 기준 사용)
- 제품이 명시적으로 요구하지 않으면 방향 잠금 금지
- 큰 화면 플랫폼에서 포인터 호버, 키보드 네비게이션, 포커스 가시성 지원

## UI 상태 커버

- 모든 비자명한 화면에 loading, error, empty, success 상태 구현
- 상태 메시징과 복구 액션은 명확하고 직접적
- 터치 대상은 최소 48x48 dp
- 라벨이나 역할이 표준 위젯에서 명확하지 않으면 `Semantics` 추가
- WCAG AA 대비 또는 프로젝트 승인 접근성 목표 유지

## 위젯 분리 기준

- 100줄 이상이거나 재사용될 때 위젯으로 추출
- 복잡한 상태 관리나 다중 책임은 별도 위젯 클래스로 분리

## 검토 체크리스트

- 토큰이 일관성 있게 사용되는지 확인
- 반복된 UI가 추출되었는지 확인
- 스크롤, 하단 inset, 키보드 동작이 안전한지 확인
- Loading, error, empty 상태가 존재하는지 확인
- 접근성 라벨, 대비, 터치 대상 크기가 승인 가능한지 확인
- 최종 레이아웃이 앱의 기존 시각 언어와 일치하는지 확인
