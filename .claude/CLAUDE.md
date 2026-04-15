# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**하루 만원 (Daily Manwon)** — 하루 1만원 예산 관리 앱. 숫자 자체가 감정을 표현하는 미니멀 디자인. .

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

## Development Guidelines — flutter_kit 참조

`docs/flutter_kit/` 하단에 개발 시 반드시 참고해야 할 가이드 문서가 있다. 코드 작성, 리뷰, 리팩토링 시 해당 문서의 규칙을 따른다.

### Architecture

- `docs/flutter_kit/flutter-architecture/` 참고

### UI/UX

- `docs/flutter_kit/flutter-ui-ux/` 참고

### Code Generation

- `docs/flutter_kit/flutter-codegen/` 참고

### Optimization

- `docs/flutter_kit/flutter-optimization/` 참고

### Algorithms & Logic

- `docs/flutter_kit/flutter-algorithms-logic/` 참고

### Git Commit

- `docs/flutter_kit/git-commit/` 참고

---
