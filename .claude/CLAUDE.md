# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**하루 만원 (Daily Manwon)** — 하루 1만원 예산 관리 앱. 숫자 자체가 감정을 표현하는 미니멀 디자인. 도토리(acorn) 보상 시스템과 업적(achievement) 기능을 포함.

## Common Commands

```bash
# Run app
flutter run

# Code generation (freezed, injectable, drift, riverpod) — 변경 후 반드시 실행
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Analyze
flutter analyze

# Run all tests
flutter test

# Run single test
flutter test test/path/to/test_file.dart

# Clean rebuild
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

## Architecture

**Clean Architecture + MVVM** with feature-based modularization.

```
lib/
├── core/               # 공유 인프라
│   ├── constants/      # AppConstants, ExpenseCategory, CharacterMood enums
│   ├── database/       # Drift (SQLite) — AppDatabase, 4 tables
│   ├── di/             # GetIt + Injectable DI setup
│   ├── router/         # GoRouter with StatefulShellRoute (bottom nav)
│   ├── theme/          # AppColors (디자인 토큰), AppTypography, AppTheme (light + dark)
│   └── utils/          # currency_formatter, app_date_utils, time_based_theme, result
├── features/           # Feature modules
│   ├── home/           # 메인 화면 (잔액, 지출 목록, 도토리/스트릭)
│   ├── calendar/       # 월별 캘린더 뷰
│   ├── settings/       # 설정
│   ├── achievement/    # 업적 시스템
│   ├── expense/        # 지출 입력 (바텀시트)
│   └── onboarding/     # 온보딩 플로우
```

Each feature follows: `data/datasources/` → `data/repositories/` → `domain/entities/` (freezed) → `domain/repositories/` (interface) → `presentation/viewmodels/` → `presentation/screens/`

## Key Technical Decisions

- **State Management**: flutter_riverpod 3.x + riverpod_annotation 4.x (@riverpod 코드젠 사용)
- **DI**: GetIt + Injectable (`configureDependencies()` in main, `@module` for 3rd-party like AppDatabase)
- **Database**: Drift (SQLite) with drift_flutter for platform-aware connection. Tables: `Expenses`, `DailyBudgets`, `Acorns`, `Achievements`
- **Models**: freezed for immutable domain entities, manual mapper classes for DB ↔ Entity conversion
- **Error Handling**: 커스텀 sealed class `Result<T>` (Success/Failed) — `lib/core/utils/result.dart`
- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` for bottom navigation (홈/캘린더/설정). Full-screen routes (achievement, onboarding) use `parentNavigatorKey`
- **Font**: Pretendard (400/500/600/700/800/900)
- **Animation**: flutter_animate

## Code Generation

Files ending in `.g.dart`, `.freezed.dart`, `.config.dart` are generated — never edit them manually. Run `build_runner` after modifying:
- `@freezed` entities
- `@riverpod` providers/notifiers
- `@DriftDatabase` / table definitions
- `@injectable` / `@module` DI annotations

## Design System

- **디자인 토큰**: 모든 색상은 `AppColors`에 정의. 절대로 `Color(0xFF...)` 하드코딩 금지
- 숫자 감정 색상: comfortable (`#2DBD8E`), warning (`#F5A623`), danger (`#E85D5D`), over (`#C0392B`)
- 시간대별 배경 7단계: dawn/morning/forenoon/noon/afternoon/evening/night (AppColors.bg* 토큰)
- 카테고리 칩 색상: chipFood/chipTransport/chipCafe/chipShopping/chipEtc
- Dark mode 필수 — `AppColors.dark*` variants
- All Korean UI text (한국어)

## Development Guidelines — flutter_kit 참조

`docs/flutter_kit/` 하단에 개발 시 반드시 참고해야 할 가이드 문서가 있다. 코드 작성, 리뷰, 리팩토링 시 해당 문서의 규칙을 따른다.

### Architecture (`docs/flutter_kit/flutter-architecture/`)
- 의존성 방향: **Presentation → Domain ← Data** (Domain은 순수 Dart, Flutter import 금지)
- Repository는 Domain Entity를 반환, DataSource는 외부 접근만 담당
- UI에서 절대로 DB/API에 직접 접근 금지 — 반드시 Repository 경유
- `dynamic` 사용 금지, 명시적 타입 또는 `Object?` 사용
- 파일 300줄 이내, 함수 50줄 이내 유지
- Public 클래스/메서드에 `///` 문서 주석 작성
- Logging은 `Logger` 사용 (`print()` 금지)

### UI/UX (`docs/flutter_kit/flutter-ui-ux/`)
- 색상, 간격, 폰트 등 절대 하드코딩 금지 — AppColors, AppTypography 토큰 사용
- Light + Dark 테마 모두 대응 (단일 brightness 가정 금지)
- loading, error, empty, success 상태 모두 구현
- 터치 영역 최소 48x48dp, 접근성 고려
- 긴 리스트는 `ListView.builder` 등 lazy render 사용
- 100줄 이상이거나 재사용되는 UI는 별도 위젯 클래스로 추출 (`_build*()` 메서드 금지)

### Code Generation (`docs/flutter_kit/flutter-codegen/`)
- 소스 변경 즉시 `build_runner` 실행
- 생성된 파일 직접 수정 금지
- 소스 정의와 생성 결과를 같은 커밋에 포함

### Optimization (`docs/flutter_kit/flutter-optimization/`)
- 최적화 전 반드시 측정 (DevTools 프로파일링)
- `build()` 내에 무거운 작업 금지
- `ref.watch`는 필요한 상태만 (select 사용 권장)
- 불필요한 중간 컬렉션, `.toList()` 변환 지양

### Algorithms & Logic (`docs/flutter_kit/flutter-algorithms-logic/`)
- 데이터 구조 선택: Map(키 조회), Set(중복 제거), List(순서/인덱스)
- 비즈니스 로직은 위젯 밖 순수 함수/서비스에 배치
- 검증 로직은 중앙 집중화 (여러 화면에서 중복 금지)
- O(n²) 이상의 로직은 사용자 경로에서 재고

### Git Commit (`docs/flutter_kit/git-commit/`)
- 하나의 커밋 = 하나의 scope
- 형식: `<type>(<scope>): <한국어 메시지>` (type/scope 영어, 메시지 한국어)
- 메시지는 명사/구문형 선호 ("로그인 검증 추가" ✅, "로그인 검증을 추가했다" ❌)
- 허용 type: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

---

<!-- OMC:START -->
<!-- OMC:VERSION:4.9.1 -->

# oh-my-claudecode - Intelligent Multi-Agent Orchestration

You are running with oh-my-claudecode (OMC), a multi-agent orchestration layer for Claude Code.
Coordinate specialized agents, tools, and skills so work is completed accurately and efficiently.

<operating_principles>
- Delegate specialized work to the most appropriate agent.
- Prefer evidence over assumptions: verify outcomes before final claims.
- Choose the lightest-weight path that preserves quality.
- Consult official docs before implementing with SDKs/frameworks/APIs.
</operating_principles>

<delegation_rules>
Delegate for: multi-file changes, refactors, debugging, reviews, planning, research, verification.
Work directly for: trivial ops, small clarifications, single commands.
Route code to `executor` (use `model=opus` for complex work). Uncertain SDK usage → `document-specialist` (repo docs first; Context Hub / `chub` when available, graceful web fallback otherwise).
</delegation_rules>

<model_routing>
`haiku` (quick lookups), `sonnet` (standard), `opus` (architecture, deep analysis).
Direct writes OK for: `~/.claude/**`, `.omc/**`, `.claude/**`, `CLAUDE.md`, `AGENTS.md`.
</model_routing>

<skills>
Invoke via `/oh-my-claudecode:<name>`. Trigger patterns auto-detect keywords.
Tier-0 workflows include `autopilot`, `ultrawork`, `ralph`, `team`, and `ralplan`.
Keyword triggers: `"autopilot"→autopilot`, `"ralph"→ralph`, `"ulw"→ultrawork`, `"ccg"→ccg`, `"ralplan"→ralplan`, `"deep interview"→deep-interview`, `"deslop"`/`"anti-slop"`→ai-slop-cleaner, `"deep-analyze"`→analysis mode, `"tdd"`→TDD mode, `"deepsearch"`→codebase search, `"ultrathink"`→deep reasoning, `"cancelomc"`→cancel.
Team orchestration is explicit via `/team`.
Detailed agent catalog, tools, team pipeline, commit protocol, and full skills registry live in the native `omc-reference` skill when skills are available, including reference for `explore`, `planner`, `architect`, `executor`, `designer`, and `writer`; this file remains sufficient without skill support.
</skills>

<verification>
Verify before claiming completion. Size appropriately: small→haiku, standard→sonnet, large/security→opus.
If verification fails, keep iterating.
</verification>

<execution_protocols>
Broad requests: explore first, then plan. 2+ independent tasks in parallel. `run_in_background` for builds/tests.
Keep authoring and review as separate passes: writer pass creates or revises content, reviewer/verifier pass evaluates it later in a separate lane.
Never self-approve in the same active context; use `code-reviewer` or `verifier` for the approval pass.
Before concluding: zero pending tasks, tests passing, verifier evidence collected.
</execution_protocols>

<hooks_and_context>
Hooks inject `<system-reminder>` tags. Key patterns: `hook success: Success` (proceed), `[MAGIC KEYWORD: ...]` (invoke skill), `The boulder never stops` (ralph/ultrawork active).
Persistence: `<remember>` (7 days), `<remember priority>` (permanent).
Kill switches: `DISABLE_OMC`, `OMC_SKIP_HOOKS` (comma-separated).
</hooks_and_context>

<cancellation>
`/oh-my-claudecode:cancel` ends execution modes. Cancel when done+verified or blocked. Don't cancel if work incomplete.
</cancellation>

<worktree_paths>
State: `.omc/state/`, `.omc/state/sessions/{sessionId}/`, `.omc/notepad.md`, `.omc/project-memory.json`, `.omc/plans/`, `.omc/research/`, `.omc/logs/`
</worktree_paths>

## Setup

Say "setup omc" or run `/oh-my-claudecode:omc-setup`.

<!-- OMC:END -->
