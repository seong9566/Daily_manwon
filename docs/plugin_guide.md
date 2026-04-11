# 플러그인 활용 가이드

**Date**: 2026-04-11  
**대상**: Claude Code + Superpowers + Impeccable  
**프로젝트**: 하루 만원 (Daily Manwon)

---

## 목차

1. [디자인 가이드 요약](#1-디자인-가이드-요약)
2. [Superpowers — 개발 워크플로우](#2-superpowers--개발-워크플로우)
3. [Impeccable — UI 디자인 품질](#3-impeccable--ui-디자인-품질)
4. [언제 무엇을 쓸까](#4-언제-무엇을-쓸까)

---

## 1. 디자인 가이드 요약

> 상세 내용: `docs/design_concept.md`, `docs/ui_design_guide.md`

### 핵심 철학

- **숫자 + 고양이 이중 감정**: 숫자(즉각 인식) + 고양이(감성 공감)가 동일한 예산 상태를 각자의 언어로 표현
- **3초 룰**: 앱을 열면 3초 안에 오늘 예산 상태를 파악 가능해야 함
- **색상 = 정보**: 하드코딩 금지, 반드시 `AppColors` 토큰 사용

### 예산 상태 색상

| 상태 | 조건 | 색상 토큰 | Hex |
|---|---|---|---|
| 여유 | ≥ 50% | `budgetComfortable` | `#000000` (라이트) |
| 주의 | 10~49% | `budgetWarning` | `#F5A623` |
| 위험 | 0~9% | `budgetDanger` | `#E85D5D` |
| 초과 | < 0 | `budgetOver` | `#C0392B` |

### 타이포그래피 토큰

```dart
AppTypography.displayLarge  // 히어로 숫자 (잔액)
AppTypography.titleMedium   // 화면 제목, 다이얼로그 타이틀
AppTypography.bodyLarge     // 설정 항목, 주요 본문
AppTypography.bodyMedium    // 일반 본문
AppTypography.bodySmall     // 서브 텍스트, 힌트
AppTypography.labelMedium   // 버튼, 액션 레이블
```

### 다크모드 컬러 쌍

```dart
// 항상 isDark 분기로 쌍으로 사용
isDark ? AppColors.darkTextMain    : AppColors.textMain
isDark ? AppColors.darkTextSub     : AppColors.textSub
isDark ? AppColors.darkBackground  : AppColors.background
isDark ? AppColors.darkSurface     : AppColors.white
isDark ? AppColors.darkDivider     : AppColors.divider
```

### UI 컴포넌트 규칙

- 터치 영역 최소 **48×48dp**
- 100줄 이상 또는 재사용 위젯은 **별도 클래스**로 추출 (`_build*()` 메서드 금지)
- 다이얼로그: `Dialog` + 커스텀 레이아웃, `borderRadius: 20`, AppColors/AppTypography 토큰 사용
- 스위치: `SettingsSwitchTile` 스타일 통일 (라이트: black track / 다크: white track)

---

## 2. Superpowers — 개발 워크플로우

> 설치: `superpowers@claude-plugins-official` (이미 설치됨 — v5.0.7)

Superpowers는 **새 기능 개발의 전체 사이클**을 자동화합니다.  
소규모 버그픽스보다 **중간~대형 작업**에서 가치가 극대화됩니다.

### 표준 워크플로우

```
brainstorming → writing-plans → subagent-driven-development → requesting-code-review → verification-before-completion
```

### 스킬별 설명 및 예시

#### `brainstorming` — 설계 검증

코드 작성 전 아이디어를 다듬고 설계를 검증합니다.  
자동 트리거: 새 기능 요청 시

```
"이월 금액 히스토리 화면을 만들고 싶어"
"도토리 상점 기능을 추가하고 싶은데 어떻게 설계할까?"
"캘린더 화면에 주간 요약 카드를 넣고 싶어"
```

#### `writing-plans` — 실행 계획 작성

파일 경로, 코드, 검증 단계까지 담긴 2~5분 단위 태스크로 분해합니다.  
자동 트리거: 설계 확정 후

```
"설계 확정됐어, 플랜 짜줘"
"/writing-plans"
```

**좋은 플랜의 조건:**
- 각 태스크: 파일 경로 명시 + 완료 기준 포함
- TDD: 테스트 먼저 → 구현 순서
- YAGNI: 지금 필요한 것만

#### `subagent-driven-development` — 자동 실행

플랜의 각 태스크를 독립 서브에이전트가 실행 + 2단계 리뷰(스펙 준수 → 코드 품질).

```
"플랜대로 실행해줘"
"/subagent-driven-development"
```

> 몇 시간 자율 실행 가능. 중간 체크포인트에서 확인 요청함.

#### `test-driven-development` — TDD 강제

RED → GREEN → REFACTOR 사이클을 엄격히 따릅니다.

```
"/tdd"  ← 키워드 트리거
"테스트 먼저 작성해줘"
```

**적용 우선순위:**
- Repository 레이어 (Drift 쿼리, 이월 계산 로직)
- ViewModel 상태 변환 로직
- 도토리/업적 판정 로직

#### `systematic-debugging` — 근본 원인 분석

증상이 아닌 근본 원인을 추적합니다.

```
"이월 금액 계산이 가끔 틀리게 나와"
"홈화면 잔액이 새로고침 전까지 업데이트 안 됨"
"도토리 스트릭이 리셋되는 버그 있어"
```

#### `requesting-code-review` — 구현 후 리뷰

플랜 대비 코드 준수 여부, 심각도별 이슈를 리포트합니다.

```
"/requesting-code-review"
"구현 완료했어, 리뷰해줘"
```

#### `using-git-worktrees` — 격리 브랜치

대형 리팩토링이나 실험적 작업을 메인 브랜치와 격리합니다.

```
"업적 시스템 전체 리팩토링 시작할게"
"새 온보딩 플로우 실험해보고 싶어"
```

#### `verification-before-completion` — 완료 전 검증

완료 선언 전 체크리스트로 누락 없이 검증합니다.

```
"다 구현한 것 같아, 검증해줘"
"/verification-before-completion"
```

### 키워드 자동 트리거 목록

| 입력 | 실행 스킬 |
|---|---|
| `"autopilot"` | 아이디어 → 코드 전체 자동화 |
| `"ralph"` | 완료될 때까지 반복 실행 |
| `"ulw"` | 고처리량 병렬 실행 |
| `"ralplan"` | 합의 기반 플래닝 |
| `"tdd"` | TDD 모드 |
| `"deep-analyze"` | 심층 분석 모드 |
| `"ultrathink"` | 깊은 추론 모드 |
| `"deepsearch"` | 코드베이스 전체 탐색 |

---

## 3. Impeccable — UI 디자인 품질

> 설치: `impeccable@impeccable`  
> 웹 중심이지만 **디자인 판단 기준**과 **리뷰 명령어**는 Flutter에도 유용

### 최초 설정 (1회만)

```
/impeccable teach
```

앱의 타겟 유저, 브랜드 톤, 디자인 방향을 `.impeccable.md`에 저장.  
이후 모든 디자인 스킬이 이 컨텍스트를 참조합니다.

**설정 시 입력할 내용 예시:**
```
- 타겟: 20~30대, 절약에 관심 있는 직장인/학생
- 브랜드 톤: 미니멀, 따뜻함, 귀여움 (고양이 캐릭터)
- 방향: 숫자가 감정을 표현하는 앱. 여백 중심, 불필요한 장식 없음
- 컬러: 흑백 기반 + 상태 색상 4단계
```

### 명령어 활용

#### 리뷰/검사 (수정 없이 분석만)

```bash
/audit 설정화면          # 접근성·반응형·성능 점검
/critique 홈화면          # UX 계층구조·명확성 리뷰
/critique 온보딩          # 온보딩 플로우 UX 리뷰
```

#### 개선 (직접 수정)

```bash
/polish 설정화면          # 디자인 시스템 정합성 최종 패스
/typeset 홈화면           # 폰트·타이포 계층 수정
/layout 캘린더화면        # 간격·그리드·비주얼 리듬 수정
/colorize 업적화면        # 전략적 컬러 추가
/animate 지출입력         # 목적 있는 모션 추가
```

#### 강도 조절

```bash
/bolder   # 심심한 디자인 → 임팩트 강화
/quieter  # 너무 화려한 디자인 → 차분하게
/distill  # 핵심만 남기고 단순화
```

---

## 4. 언제 무엇을 쓸까

### 작업 유형별 선택

| 상황 | 사용할 것 | 명령어/키워드 |
|---|---|---|
| 버그 수정 (소규모) | 직접 수정 | — |
| 복잡한 버그 원인 불명 | Superpowers | `systematic-debugging` |
| 새 기능 아이디어 | Superpowers | `brainstorming` |
| 새 기능 구현 (중~대형) | Superpowers | `"autopilot"` 또는 단계별 |
| 구현 후 코드 검토 | Superpowers | `/requesting-code-review` |
| UI 컴포넌트 품질 리뷰 | Impeccable | `/audit`, `/critique` |
| 화면 타이포/레이아웃 문제 | Impeccable | `/typeset`, `/layout` |
| 전체 화면 디자인 개선 | Impeccable | `/polish` |
| 대형 리팩토링 격리 | Superpowers | `using-git-worktrees` |
| TDD로 로직 구현 | Superpowers | `"tdd"` |

### 규모별 워크플로우

#### 소규모 (버그픽스, 1~2파일)
```
직접 수정 → 완료
```

#### 중간 규모 (단일 기능, 3~10파일)
```
brainstorming → writing-plans → executing-plans → requesting-code-review
```

#### 대형 (새 피처, 시스템 변경)
```
brainstorming → using-git-worktrees → writing-plans
→ subagent-driven-development → requesting-code-review
→ verification-before-completion
```

#### UI 전면 개선
```
/impeccable teach → /audit → /critique → /polish
```

### 이 프로젝트에서 자주 쓰게 될 조합

```
# 새 화면 추가 (예: 이월 히스토리)
"이월 히스토리 화면 추가하고 싶어" → brainstorming 자동 실행
설계 확정 → "플랜 짜줘" → "실행해줘"

# 기존 화면 UI 개선
/audit 홈화면
/typeset 홈화면

# DB 로직 버그
"이월 계산 버그 있어" → systematic-debugging

# 완료 전 최종 검증
/verification-before-completion
/requesting-code-review
```

---

> **참고 문서**
> - `docs/design_concept.md` — 디자인 철학 상세
> - `docs/ui_design_guide.md` — UI 컴포넌트 스펙
> - `docs/flutter_kit/` — 코드 작성 규칙
