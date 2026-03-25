## 추가 필요 UI 프롬프트: 하루 만원 살기 플래너

**Date**: 2026-03-25
**용도**: 현재 보유 이미지(6장)와 PRD를 대조하여 누락된 화면의 AI 이미지 생성 프롬프트
**레퍼런스**: docs/ui/ 폴더의 기존 이미지 스타일을 정확히 따를 것

---

### 공통 스타일 (기존 이미지 기반)

```
기존 이미지에서 추출한 스타일 규칙:
- 배경: 순백(#FFFFFF) 또는 아주 옅은 웜 화이트
- 텍스트: 검정(#000000) 또는 다크 그레이(#3D3D3D)
- 서브 텍스트: 라이트 그레이(#8E8E8E)
- 히어로 넘버: 약 48-56pt, Black/Bold weight, ₩ 포함
- 프로그레스 바: 얇은 검정 실선
- 카테고리: 3D 렌더링 스타일 이모지 (🍚🚌☕🛍️📦)
- 바텀 네비: 아이콘 + 한글 레이블 (홈/캘린더/설정)
- FAB: 검정 원형, 흰색 + 아이콘
- 키패드: 테두리 없음, 숫자만, 3열
- 전체적으로 장식 없음, 그림자 없음, 여백 많음
- 해상도: iPhone 15 Pro (393 x 852)
- 반드시 기존 main.png의 레이아웃과 동일한 스타일 유지
```

---

### 1. 메인 — 주의 상태 (잔액 부족) → `main_warning.png`

```
Create a mobile app screenshot identical in layout and style to the attached reference image (main.png), but showing a "cautious" budget state.

Changes from reference:
- Hero number: "₩2,800" instead of "₩5,200"
- Number should be SLIGHTLY smaller than the comfortable state (about 90% of original size)
- Number color: warm muted tone, NOT bright black — use a dark amber or muted warm gray to convey unease
- Progress bar: only about 28% filled (short bar)
- Stats below bar: same "🌰 12 · 🔥 7일"
- "오늘의 지출" section shows 4 items (heavier spending):
  - ☕ 아침 12:00 -2,500
  - 🍚 점심 13:30 -3,200
  - ☕ 커피 15:00 -1,500
  - (total spent: 7,200원)
- Count: "4건" instead of "2건"

Everything else EXACTLY the same: same background, same FAB, same bottom nav, same font, same spacing. The ONLY differences are the number value, number size, bar length, and expense count.
```

---

### 2. 메인 — 위험 상태 (예산 초과) → `main_danger.png`

```
Create a mobile app screenshot identical in layout and style to the attached reference image (main.png), but showing a "budget exceeded" danger state.

Changes from reference:
- Hero number: "-₩2,300" (NEGATIVE, with minus sign)
- Number should be smaller than normal (about 80% of original size)
- Number color: muted coral/red (#FF8B8B or similar pastel red)
- The minus sign should be clearly visible and uncomfortable
- Progress bar: 0% filled — entire bar appears in light red/coral tone
- Background: very faint pink tint (#FFF5F5) — barely noticeable but emotionally present
- Stats: same "🌰 12 · 🔥 7일"
- "오늘의 지출" shows 5 items (overspending):
  - 🍚 아침 08:30 -3,500
  - 🚌 교통 09:00 -1,400
  - 🍚 점심 12:30 -4,200
  - ☕ 커피 15:00 -1,800
  - 🛍️ 간식 17:00 -1,400
- Count: "5건"

The screen should feel slightly tense — the pink background tint and red number create discomfort while remaining minimal.
```

---

### 3. 메인 — 다크 모드 → `main_dark.png`

```
Create a mobile app screenshot identical in layout to the attached reference image (main.png), but in DARK MODE.

Color mapping:
- Background: #1A1A1A (warm dark charcoal, NOT pure black)
- Hero number "₩5,200": #F0F0F0 (bright near-white)
- "남은 예산" label: #666666
- Date "2026. 03. 25": #666666
- Progress bar: #F0F0F0 filled portion on #333333 background
- "🌰 12 · 🔥 7일": #A0A0A0
- "오늘의 지출" header: #A0A0A0
- "2건": #666666
- Expense item names ("점심", "아메리카노"): #F0F0F0
- Expense times ("12:30", "15:15"): #666666
- Expense amounts ("-3,500", "-1,300"): #F0F0F0
- Dividers between items: #2A2A2A (barely visible)
- FAB: white circle with black "+" icon
- Bottom nav background: #2A2A2A
- Bottom nav icons: #666666 (unselected), #F0F0F0 (selected "홈")
- Bottom nav labels: same gray tones
- Category emoji: unchanged (native rendering)

The dark mode should feel WARM, not harsh. Same generous spacing and layout.
```

---

### 4. 메인 — 빈 상태 (지출 없음) → `main_empty.png`

```
Create a mobile app screenshot identical in layout to the attached reference image (main.png), but showing an EMPTY state with no expenses recorded.

Changes from reference:
- Hero number: "₩10,000" (full budget, nothing spent)
- Progress bar: 100% filled
- Stats: "🌰 12 · 🔥 7일" (same)
- "오늘의 지출" header with "0건" on the right

- Instead of expense list items, show centered placeholder text in the empty area:
  - "아직 지출이 없어요" in medium gray (#8E8E8E), 16pt
  - "첫 지출을 기록해볼까요?" in lighter gray (#B0B0B0), 14pt
  - These two lines centered vertically in the space where list items would be

- Same FAB, same bottom nav, same everything else
- The empty state feels aspirational — "full budget remaining is a good thing"
```

---

### 5. 메인 — 시간대별 배경 변화 → `main_time_variations.png`

```
Create a horizontal comparison showing 4 variations of the same home screen (main.png layout) side by side, demonstrating time-of-day background shifts.

Show 4 phone screens in a row, each labeled with time:

1. "아침 (06-12시)" — background: warm cream #FFF8E7
2. "점심 (12-18시)" — background: clean white #F5F5F5
3. "저녁 (18-22시)" — background: warm amber tint #FFF0E0
4. "밤 (22-06시)" — background: cool blue-gray #EEF0F8

Each screen shows the same "₩5,200" layout with 2 expense items. The ONLY difference is the background color. All text, numbers, progress bar, FAB, bottom nav remain identical.

Show all 4 phones at slightly reduced size so they fit side by side horizontally. Add a small time label below each phone.
```

---

### 6. 온보딩 화면 (3-step 캐러셀) → `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png`

```
Design 3 onboarding screens matching the minimal style of the reference images. NO characters, NO illustrations — typography and simple shapes only.

Screen 1 (onboarding_1.png):
- White background with generous padding
- Center: "₩10,000" in very large bold text (64pt), black
- Below: thin green progress bar at 100%
- Title: "하루 만원으로 도전!" in bold 20pt
- Subtitle: "매일 만원 안에서 생활하는\n새로운 절약 습관을 만들어요" in gray 14pt
- Bottom: page dots ● ○ ○ (first filled)
- "다음" button: black rounded rectangle, white text

Screen 2 (onboarding_2.png):
- Center: simplified representation of the number keypad layout
  - "3,500" in bold centered, with 5 small emoji icons below (🍚🚌☕🛍️📦)
  - Styled like a simplified version of the bottom_sheet
- Title: "3탭으로 기록"
- Subtitle: "금액 입력, 카테고리 선택, 끝.\n가장 빠른 지출 기록" in gray
- Page dots: ○ ● ○
- "다음" button

Screen 3 (onboarding_3.png):
- Center: three stacked number displays showing states:
  - "₩7,200" large, in dark/stable color (comfortable)
  - "₩2,800" medium, in muted amber (cautious)
  - "-₩2,300" small, in coral red (over budget)
- Title: "숫자가 말해줘요"
- Subtitle: "남은 예산에 따라 숫자의 크기와\n색상이 감정을 표현해요" in gray
- Page dots: ○ ○ ●
- "시작하기" button: black, full width, white text
```

---

### 7. 스플래시 화면 → `splash_light.png`, `splash_dark.png`

```
Design a minimal splash screen matching the app's style.

Light version (splash_light.png):
- Pure white background (#FFFFFF)
- Centered vertically:
  - "₩" symbol in very large size (80pt), light gray (#CCCCCC)
  - Below with small gap: "하루 만원" in bold 24pt, black
- Bottom center: thin circular loading spinner in black, subtle

Dark version (splash_dark.png):
- Background: #1A1A1A
- "₩" symbol: #333333 (subtle, barely visible)
- "하루 만원": #F0F0F0
- Spinner: white

Absolutely nothing else on screen. Stark, confident, brand-mark only.
```

---

### 8. 업적/배지 화면 → `achievement.png`

```
Design an achievements screen matching the minimal style of the reference images.

Layout:
- Top left: "업적" title, same style as "설정" in setting.png
- No app bar background

- Current status section (top area):
  - "현재 칭호: 알뜰러 🏅" left-aligned, bold
  - "보유 도토리: 🌰 42개" below, in gray

- Badge grid (3 columns, evenly spaced):
  Row 1 (achieved — full opacity):
    - ⭐ "첫 기록" (gold tint)
    - 🔥 "7일 연속" (orange tint)
    - ✨ "0원 지출" (green tint)
  Row 2 (locked — gray silhouette):
    - 🔒 "???" (gray)
    - 🔒 "???" (gray)
    - 🔒 "???" (gray)

  Each badge: circular container (60px), emoji centered, label below in small text
  Achieved: normal color | Locked: all gray, emoji replaced with 🔒

- Title progression section below:
  - "절약 새싹 (3일)" — checkmark, completed
  - "알뜰러 (7일)" — checkmark, current (bold)
  - "도토리 수호자 (14일)" — progress bar 7/14, locked
  - "도토리 마스터 (30일)" — progress bar 7/30, locked

- Bottom nav with 홈 tab (not a tab screen, accessed from home)

Background: white, same spacing as other screens
Style: clean list-based, no card wrappers, minimal decoration
```

---

### 9. 다크 모드 — 캘린더 → `calendar_dark.png`

```
Create a dark mode version of the calendar screen (calendar.png reference).

Color mapping:
- Background: #1A1A1A
- Header "2026. 03": #F0F0F0
- Navigation arrows: #A0A0A0
- "연속 7일 · 성공 24회": #A0A0A0
- Weekday headers (S M T W T F S): #666666
- Date numbers (current month): #F0F0F0
- Date numbers (not current month/future): #444444
- Today's date: bold #F0F0F0
- Success dots (•): #7EC8A0 (green, same as light)
- Failure dots (•): #FF8B8B (red, same as light)
- Selected day section:
  - "3월 24일": #F0F0F0
  - "-4,800원": #A0A0A0
  - Expense items: #F0F0F0 (name), #666666 (sub)
- Bottom nav: #2A2A2A background, 캘린더 selected #F0F0F0
```

---

### 10. 다크 모드 — 설정 → `setting_dark.png`

```
Create a dark mode version of the settings screen (setting.png reference).

Color mapping:
- Background: #1A1A1A
- "설정" title: #F0F0F0
- Setting item labels: #F0F0F0
- Setting item values/chevrons: #666666
- "데이터 초기화": coral red (#FF8B8B), same as light mode
- Toggle switch (on): white knob on green track (or keep current style but inverted)
- Toggle switch (off): gray
- Dividers: #2A2A2A
- Bottom nav: #2A2A2A, 설정 selected #F0F0F0
- "버전 1.0.0": #666666
```

---

### 11. 앱 아이콘 → `app_icon.png`

```
Design a minimal app icon for "하루 만원" budget tracker.

Square icon (1024x1024px) with rounded corners (iOS style):
- Background: solid white (#FFFFFF)
- Center: "₩" symbol in bold black, large, filling about 60% of the icon
- Clean, stark, instantly recognizable
- NO gradients, NO shadows, NO illustrations
- The ₩ symbol IS the entire brand identity

Alternative option:
- Background: solid black (#1A1A1A)
- "₩" symbol in white

Generate both versions for comparison.
```

---

### 12. 지출 수정 화면 (스와이프 액션) → `expense_swipe.png`

```
Create a screenshot showing the swipe-to-delete interaction on an expense list item, based on main.png layout.

Show the home screen with:
- One expense item being swiped left, revealing a red delete button
- The swiped item: "☕ 아메리카노 -1,300" is shifted left
- Behind it: red background area with white trash can icon or "삭제" text
- The other expense item ("🍚 점심 -3,500") remains in normal position

Same layout, same style as main.png — just showing the swipe interaction state.
```

---

### 생성 우선순위

| 순위 | 파일명 | PRD 항목 | 구현 영향도 |
|------|--------|---------|-----------|
| 1 | `main_warning.png` | P0-1 숫자 감정 | 높음 — 핵심 차별화 |
| 2 | `main_danger.png` | P0-1 숫자 감정 | 높음 — 핵심 차별화 |
| 3 | `main_dark.png` | P0-4 다크모드 | 높음 — MVP 필수 |
| 4 | `main_empty.png` | P0-3 빈 상태 | 중간 |
| 5 | `onboarding_1~3.png` | S-24 온보딩 | 중간 |
| 6 | `achievement.png` | P1-7 업적 | 중간 |
| 7 | `splash_light/dark.png` | S-24 스플래시 | 낮음 |
| 8 | `main_time_variations.png` | P0-4 시간대 배경 | 낮음 (비교용) |
| 9 | `calendar_dark.png` | 다크모드 | 낮음 |
| 10 | `setting_dark.png` | 다크모드 | 낮음 |
| 11 | `app_icon.png` | S-31 앱 아이콘 | Phase 6 |
| 12 | `expense_swipe.png` | S-12 스와이프 삭제 | 낮음 |

---

### 사용법

1. 기존 `docs/ui/main.png`을 **레퍼런스 이미지로 첨부**하여 AI 도구에 업로드
2. 각 프롬프트를 복사하여 GPT Image / Midjourney에 입력
3. "attached reference image" 부분에 main.png를 함께 전달
4. 생성된 이미지를 `docs/ui/` 폴더에 해당 파일명으로 저장
