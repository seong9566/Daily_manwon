#!/usr/bin/env node
/**
 * flutter_kit 코드 규칙 검증 훅
 * PostToolUse(Edit|Write) 시 lib/*.dart 파일이면 claude -p 로 6개 항목 검토
 */

import { readFileSync } from 'fs';
import { execSync } from 'child_process';

// 재귀 방지 — 이 훅이 스폰한 claude 세션에서 다시 실행되지 않도록
if (process.env.FLUTTER_KIT_HOOK_ACTIVE === '1') process.exit(0);

// stdin 에서 PostToolUse JSON 읽기
let toolData;
try {
  toolData = JSON.parse(readFileSync(0, 'utf8'));
} catch {
  process.exit(0);
}

const filePath = toolData?.tool_input?.file_path ?? '';

// lib/ 하위 .dart 파일만 처리
if (!filePath.match(/\/lib\/.+\.dart$/)) process.exit(0);

// 변경 내용 요약 (Edit: old/new, Write: 전체 content 앞 60줄)
const toolName = toolData?.tool_name ?? '';
let changeSummary = '';
if (toolName === 'Edit') {
  const oldStr = (toolData?.tool_input?.old_string ?? '').slice(0, 400);
  const newStr = (toolData?.tool_input?.new_string ?? '').slice(0, 400);
  changeSummary = `변경 전:\n${oldStr}\n\n변경 후:\n${newStr}`;
} else if (toolName === 'Write') {
  const content = (toolData?.tool_input?.content ?? '').split('\n').slice(0, 60).join('\n');
  changeSummary = `작성 내용 (앞 60줄):\n${content}`;
}

const prompt = `검토 대상 파일: ${filePath}
도구: ${toolName}

${changeSummary}

위 변경 내용과 해당 파일을 바탕으로 아래 SKILL.md 파일들을 읽고 6가지 항목을 순서대로 검사하세요.
각 항목의 SKILL.md를 반드시 Read 도구로 읽은 뒤 판단하세요.

**[algorithms-logic]** docs/flutter_kit/flutter-algorithms-logic/SKILL.md 기준
- 자료 구조가 접근 패턴에 맞게 선택되었는지
- 자주 실행되는 경로에 O(n²) 이상 중첩 루프가 없는지
- 이벤트 빈도가 높을 때 debounce/throttle이 적용되었는지
- 비즈니스 로직이 UI와 분리되어 재사용 가능한지
- validation 로직이 여러 곳에 중복 없이 중앙화되었는지

**[architecture]** docs/flutter_kit/flutter-architecture/SKILL.md 기준
- 계층 의존성이 Presentation → Domain ← Data 방향인지
- Domain 레이어에 Flutter import가 없는지
- DataSource가 외부 접근과 원본 데이터 처리만 담당하는지
- Repository가 Domain Entity를 반환하고 매핑 책임을 소유하는지
- UI가 Domain Entity나 API 모델을 직접 사용하지 않는지
- ViewModel이 다른 ViewModel의 상태를 watch/read하지 않는지

**[codegen]** docs/flutter_kit/flutter-codegen/SKILL.md 기준
- @freezed, @riverpod, @JsonSerializable 주석이 있는 파일에 part 선언이 있는지
- 위 주석이 있는 파일이 수정되었다면 build_runner 재실행이 필요한지

**[optimization]** docs/flutter_kit/flutter-optimization/SKILL.md 기준
- build() 내에 비용이 큰 작업이 없는지
- ref.watch 범위가 최소화되어 있는지 (select 활용 여부)
- 크거나 비제한적인 컬렉션에 lazy 렌더링(ListView.builder 등)이 있는지
- 단단한 루프 내 불필요한 객체 생성이 없는지
- Controller/subscription/listener가 올바르게 폐기되는지

**[ui-ux]** docs/flutter_kit/flutter-ui-ux/SKILL.md 기준
- 하드코딩된 색상/간격/반경/타이포그래피 없이 AppColors·AppTypography 등 토큰 사용하는지
- 라이트/다크 테마 모두 대응하는지
- 100줄 이상이거나 재사용 UI는 별도 위젯으로 추출되었는지
- loading·error·empty 상태가 처리되었는지 (해당하는 경우)
- 비UI 파일(domain, data 레이어)이면 N/A 처리

**[git-commit]** docs/flutter_kit/git-commit/SKILL.md 기준
- 이 파일의 변경 내용을 Conventional Commits 형식으로 한 줄 제안
- type·scope는 영어, message는 한글 명사형
- 예: feat(ui): 칩 배경색 white 통일 및 다크모드 대응

**출력 형식 (이 형식만 사용, 다른 설명 없이):**

flutter_kit: {
  algorithms-logic: PASS,
  architecture: PASS,
  codegen: PASS,
  optimization: PASS,
  ui-ux: PASS,
  git-commit: <type>(<scope>): <한글 메시지>
}

실패 항목은 이유를 함께 표기:
flutter_kit: {
  algorithms-logic: PASS,
  architecture: FAIL — Domain 레이어에 Flutter import 감지,
  codegen: FAIL — dart run build_runner build --delete-conflicting-outputs 실행 필요,
  optimization: PASS,
  ui-ux: FAIL — AppColors 대신 Color(0xFF...) 하드코딩 감지,
  git-commit: style(ui): 칩 배경색 토큰으로 교체
}

파일을 수정하지 마세요. 위 형식만 출력하세요.`;

try {
  const result = execSync('claude --model claude-haiku-4-5-20251001 -p -', {
    input: prompt,
    encoding: 'utf8',
    timeout: 100_000,
    env: { ...process.env, FLUTTER_KIT_HOOK_ACTIVE: '1' },
  });

  process.stdout.write(result.trim() + '\n');
} catch {
  process.exit(0);
}
