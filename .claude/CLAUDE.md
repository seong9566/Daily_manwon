# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**하루 만원 (Daily Manwon)** — 하루 1만원 예산 관리 앱. 다람쥐 캐릭터가 남은 잔액에 따라 감정(happy/worried/sad)을 표현하며 절약을 유도한다. 도토리(acorn) 보상 시스템과 업적(achievement) 기능을 포함.

## Common Commands

```bash
# Run app
flutter run

# Code generation (freezed, injectable, drift) — 변경 후 반드시 실행
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
│   ├── theme/          # AppColors, AppTypography, AppTheme (light + dark)
│   └── utils/          # currency_formatter, app_date_utils
├── features/           # Feature modules
│   ├── home/           # 메인 화면 (잔액, 캐릭터, 지출 목록)
│   ├── calendar/       # 월별 캘린더 뷰
│   ├── settings/       # 설정
│   ├── achievement/    # 업적 시스템
│   ├── expense/        # 지출 입력
│   └── onboarding/     # 온보딩 플로우
```

Each feature follows: `data/models/` (mappers) → `domain/entities/` (freezed) → `presentation/screens/`

## Key Technical Decisions

- **State Management**: flutter_riverpod (Notifier/AsyncNotifier 수동 선언, 코드젠 미사용)
- **DI**: GetIt + Injectable (`configureDependencies()` in main, `@module` for 3rd-party like AppDatabase)
- **Database**: Drift (SQLite) with drift_flutter for platform-aware connection. Tables: `Expenses`, `DailyBudgets`, `Acorns`, `Achievements`
- **Models**: freezed for immutable domain entities, manual mapper classes for DB ↔ Entity conversion
- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` for bottom navigation (홈/캘린더/설정). Full-screen routes (achievement, onboarding) use `parentNavigatorKey`
- **Font**: Pretendard (400/500/600/700)
- **Animation**: flutter_animate

## Code Generation

This project relies heavily on code generation. Files ending in `.g.dart`, `.freezed.dart`, `.config.dart` are generated — never edit them manually. Run `build_runner` after modifying:
- `@freezed` entities
- `@DriftDatabase` / table definitions
- `@injectable` / `@module` DI annotations

## Design System

- Pastel orange primary (`#FFB366`), warm white background (`#FFF8F0`)
- Character mood colors: comfortable (green `#7EC8A0`), warning (yellow `#FFD966`), danger (red `#FF8B8B`)
- 5 expense categories each with distinct color: food, transport, cafe, shopping, etc
- Dark mode is required — uses `AppColors.dark*` variants
- All Korean UI text (한국어)

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
