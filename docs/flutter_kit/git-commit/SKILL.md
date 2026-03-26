---
name: git-commit
description: Conventional Commits 형식으로 원자적이고 잘 구조화된 Git 커밋을 생성합니다. s_pass 프로젝트에 맞춘 한글 커밋 메시지와 브랜치 전략을 사용합니다.
---

# Git 커밋

로컬 변경사항에서 Git 커밋을 생성할 때 이 규칙을 따릅니다.

## 핵심 규칙

- 변경사항을 논리적 범위로 분할
- 범위당 하나의 커밋
- 사용자가 무시하도록 요청한 파일 포함 금지
- `.gitignore`에 일치하는 파일 포함 금지
- 커밋 이력은 읽기 쉽고 되돌리기 쉬워야 함

## 변경사항 분석

```bash
git status --short
```

로 staged 및 unstaged 변경사항 검사. 변경된 파일을 논리적 범위로 그룹핑: 기능, 모듈, 계층, 관심사. `auth`, `api`, `ui`, `domain`, `data` 같은 실용적인 범위 사용.

## 브랜칭 전략

- 새 작업 시 명확한 기능 branch 선호: `feat/xxx`, `fix/xxx`
- 필수 확인과 리뷰 완료 후에만 `main` merge
- 리포지토리가 활성 branch 전략이 있으면 그 규약 먼저 따르기

**s_pass 브랜치 구조:**
- `main` — 릴리스 브랜치 (보호)
- `dev` — 개발 브랜치
- `test` — 테스트 브랜치
- `feat/feature-name` — 기능 branch
- `fix/bug-name` — 버그 수정 branch

## 커밋 메시지 규칙

Conventional Commits 형식 사용:

```
<type>(<scope>): <message>
```

- `type`과 `scope`은 영어
- 커밋 `message`는 한글
- 커밋 body도 한글

### 허용된 Type

- `feat` — 새로운 기능
- `fix` — 버그 수정
- `docs` — 문서화
- `style` — 코드 스타일 (기능 변경 없음)
- `refactor` — 코드 재구조화
- `perf` — 성능 개선
- `test` — 테스트 추가 또는 수정
- `build` — 빌드 시스템 변경
- `ci` — CI/CD 변경
- `chore` — 기타 변경
- `revert` — 커밋 되돌리기

### 한글 작성 스타일

동사 과거형보다 **명사형/구문형** 선호:

- ✅ `로그인 검증 추가` (O)
- ❌ `로그인 검증을 추가했다` (X)

- ✅ `잘못된 요청 전달 방지` (O)
- ❌ `잘못된 요청이 전달되는 것을 막기 위해서다` (X)

- ✅ `필드별 validator 추가` (O)
- ❌ `필드별 validator를 추가했다` (X)

- ✅ `유효하지 않은 경우 제출 차단 로직 적용` (O)
- ❌ `유효하지 않으면 제출을 막도록 변경했다` (X)

변경이 복잡하지 않으면 상세한 설명 회피.

## 커밋 body 추가 시점

다음 중 해당할 때:
- 변경이 로직 업데이트 포함
- 변경이 여러 단계 포함
- 변경 이유가 명확하지 않음
- 변경이 breaking이거나 동작에 영향

## 커밋 body 규칙

- subject와 body를 빈 줄로 분리
- 필요하면 `What`, `Why`, `How` 설명
- 각 줄은 짧고 직접적
- 장문의 prose보다 짧은 bullet-like 구문이나 labeled 섹션 선호

## 실행 흐름

1. `git status --short` 실행
2. 범위별로 파일 그룹핑
3. 현재 범위의 파일만 stage
4. Conventional Commits 형식으로 subject 작성
5. 변경이 설명 필요하면 body를 한글로 작성
6. 그 범위만 커밋
7. 나머지 범위 반복
8. `git log -n 5`로 최근 이력 검증

## 커맨드 패턴

```bash
git commit -m "<subject>" -m "<body>"
```

## 예제

### 간단한 커밋 (body 없음)

```bash
git commit -m "feat(auth): 로그인 폼 검증 추가"
```

### 설명 필요한 커밋 (body 포함)

```bash
git commit -m "feat(auth): 로그인 폼 검증 추가" -m "What:
로그인 폼 입력값 검증 추가

Why:
잘못된 요청의 API 전달 방지

How:
필드별 validator 추가
유효하지 않은 경우 제출 차단 로직 적용"
```

### 여러 범위 커밋

```bash
# 첫 번째 범위: auth
git add lib/domain/repositories/auth_repository.dart
git commit -m "feat(auth): 로그인 UseCase 추가"

# 두 번째 범위: ui
git add lib/presentation/auth/screens/login_screen.dart
git add lib/presentation/auth/widgets/login_form.dart
git commit -m "feat(ui): 로그인 폼 위젯 구현"

# 세 번째 범위: test
git add test/presentation/auth/screens/login_screen_test.dart
git commit -m "test(auth): 로그인 화면 테스트 추가"
```

## 최종 확인

- 한 커밋이 하나의 범위만 포함하는지 확인
- 무시되어야 할 파일이 제외되었는지 확인
- `type`과 `scope`이 올바른지 확인
- Subject와 body가 한글로 작성되었는지 확인
- 한글 문구가 간결한 명사형 스타일을 사용하는지 확인
- 최근 커밋 이력이 읽기 쉬운지 확인
