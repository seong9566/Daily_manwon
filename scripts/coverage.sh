#!/usr/bin/env bash
# coverage.sh — 테스트 커버리지 측정 → HTML 리포트 생성 → 브라우저 열기
# 사용: bash scripts/coverage.sh
#
# 기본 동작: settings 피처 커버리지만 측정
# 전체 커버리지: bash scripts/coverage.sh --all

set -euo pipefail

COVERAGE_DIR="coverage"
LCOV_FILE="$COVERAGE_DIR/lcov.info"
FILTERED_FILE="$COVERAGE_DIR/lcov_filtered.info"
SCOPED_FILE="$COVERAGE_DIR/lcov_settings.info"
HTML_DIR="$COVERAGE_DIR/html"
SCOPE="${1:-settings}"  # 기본값: settings 피처만

# 1. 테스트 실행 (coverage 수집)
echo "▶ Running tests with coverage..."
fvm flutter test --no-pub --coverage

# 2. generated 파일 및 platform-dependent 코드 제거
echo "▶ Filtering generated and platform-dependent files..."
lcov \
  --remove "$LCOV_FILE" \
  '*.g.dart' \
  '*.freezed.dart' \
  '*.config.dart' \
  '*/notification_service.dart' \
  --output-file "$FILTERED_FILE" \
  --ignore-errors unused

if [[ "$SCOPE" != "--all" ]]; then
  # 3a. settings 피처만 추출
  echo "▶ Scoping to settings feature..."
  lcov \
    --extract "$FILTERED_FILE" \
    '*/features/settings/*' \
    --output-file "$SCOPED_FILE" \
    --quiet

  TARGET_FILE="$SCOPED_FILE"
  TITLE="Daily Manwon Settings Coverage"
else
  # 3b. 전체 커버리지 사용
  TARGET_FILE="$FILTERED_FILE"
  TITLE="Daily Manwon Full Coverage"
fi

# 4. 커버리지 요약 출력
echo ""
echo "▶ Coverage summary:"
lcov --summary "$TARGET_FILE"

# 5. HTML 리포트 생성
echo ""
echo "▶ Generating HTML report → $HTML_DIR/"
genhtml "$TARGET_FILE" \
  --output-directory "$HTML_DIR" \
  --title "$TITLE" \
  --show-details \
  --quiet

# 6. 브라우저 열기
INDEX="$HTML_DIR/index.html"
if [[ "$OSTYPE" == "darwin"* ]]; then
  open "$INDEX"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  xdg-open "$INDEX"
fi

echo ""
echo "✅ Coverage report: $INDEX"
