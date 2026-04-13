# 통계 탭 바텀 네비 독립 분리 설계

**날짜:** 2026-04-14  
**범위:** 캘린더 화면 내 통계 탭 → 바텀 네비 독립 탭으로 이동

---

## 배경

현재 `CalendarScreen`은 내부에 `TabBar`(캘린더 / 통계)를 갖고 있다. 통계 기능이 성장하면서 캘린더와 동등한 수준의 독립 화면으로 분리하는 것이 UX 및 코드 구조 양쪽에서 이득이다.

---

## 목표

바텀 네비게이션을 **홈 / 캘린더 / 통계 / 설정** 4탭으로 재편한다.

---

## 변경 파일 및 내용

### 1. `lib/core/router/app_router.dart`

- `AppRoutes`에 `stats = '/stats'` 상수 추가
- `StatefulShellRoute.indexedStack`의 `branches` 배열에 통계 브랜치 삽입 (캘린더 뒤, 설정 앞):
  ```dart
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutes.stats,
        builder: (context, state) => const StatsScreen(),
      ),
    ],
  ),
  ```
- `StatsScreen` import 추가

### 2. `lib/core/router/app_shell.dart`

- `NavigationBar.destinations`에 통계 아이템 삽입 (index 2):
  ```dart
  NavigationDestination(
    icon: Icon(Icons.bar_chart_outlined),
    selectedIcon: Icon(Icons.bar_chart_rounded),
    label: '통계',
  ),
  ```

### 3. `lib/features/calendar/presentation/screens/calendar_screen.dart`

- `SingleTickerProviderStateMixin` 제거
- `TabController` 선언·초기화·dispose 제거
- `TabBar` 위젯 제거
- `TabBarView` 제거 → 기존 탭 0 콘텐츠(캘린더 UI)를 `Scaffold.body`로 직접 사용
- FAB의 `isCalendarTab` 조건 분기 제거 → 항상 표시
- `StatsScreen` import 제거

### 4. `lib/features/stats/presentation/screens/stats_screen.dart`

- 최상위 `ColoredBox`를 `Scaffold(backgroundColor: bgColor, body: ...)` 로 교체
- 기존 내부 콘텐츠(로딩/에러/정상 상태)는 그대로 유지

---

## 데이터 흐름

변경 없음. `StatsScreen`은 기존과 동일하게 `statsViewModelProvider`를 watch한다. 다만 이제 GoRouter의 `StatefulShellBranch`로 관리되므로 탭 전환 시 상태가 유지된다(indexedStack).

---

## 에러 처리 / 엣지 케이스

- `StatsScreen`은 이미 loading / error / success 세 상태를 모두 구현하고 있어 추가 작업 불필요
- `CalendarScreen`의 FAB은 캘린더 화면 전용이므로 탭 조건 제거 후 항상 표시해도 무방

---

## 테스트 기준

1. 바텀 네비에 홈 / 캘린더 / 통계 / 설정 4개 탭이 표시된다
2. 통계 탭 선택 시 `StatsScreen`이 정상 렌더링된다
3. 캘린더 탭에 탭바(캘린더/통계 토글)가 사라지고 캘린더 UI만 표시된다
4. 캘린더 화면 FAB이 정상 동작한다
5. 탭 전환 후 돌아와도 각 화면 상태가 유지된다 (indexedStack)
