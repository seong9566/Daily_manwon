## UI 디자인 프롬프트: 하루 만원 살기 플래너

**Date**: 2026-03-25
**Updated**: 2026-03-25
**용도**: AI 이미지 생성 도구(Midjourney, GPT Image, Figma AI 등)에서 각 화면 UI 레퍼런스 생성 시 사용
**디자인 방향**: 심플 미니멀 UI, 캐릭터 없음, 숫자가 감정을 표현하는 앱
**레퍼런스**: docs/ui/ 폴더 이미지 기반

---

### 공통 디자인 스펙

```
- 스타일: 극도로 미니멀, 모노크롬 베이스 + 상태 색상 포인트
- 캐릭터: 없음. 숫자 자체가 감정의 주인공
- 컬러: 거의 흑백, 상태에 따라 파스텔 색상 포인트만 사용
- 다크모드: Background #1A1A1A, Surface #2A2A2A, Card #333333
- 폰트: Pretendard, 숫자에 극강 굵기(Black/Bold)
- 모서리: 16px 라운드
- 그림자: 거의 없음 (elevation 0~1)
- 아이콘: 이모지 카테고리 (🍚🚌☕🛍️📦)
- 여백: 매우 넉넉, 정보 밀도 최소화
- 해상도: iPhone 15 Pro (393 x 852)
- 핵심 원칙: 앱을 열면 3초 안에 남은 금액 파악
```

---

### 1. 메인 화면 — 여유 상태 (라이트)

```
Design a hyper-minimal mobile app home screen for a daily budget tracker called "하루 만원".

The design philosophy: NO characters, NO illustrations — the NUMBER itself is the emotional expression.

Layout (top to bottom):
- Date at top center: "2026. 03. 25" in small light gray text
- Label: "남은 예산" in small gray text, centered
- HERO NUMBER: "₩5,200" displayed extremely large (48-56pt), bold black, centered
  - This number is the emotional core of the app
  - In "comfortable" state (≥5,000원): large, steady, confident typography
- Thin horizontal progress bar below the number: 52% filled, subtle dark color
- Below progress bar: "🌰 12 · 🔥 7일" in small gray text (acorn count and streak)

- Large whitespace gap

- Section: "오늘의 지출" left-aligned, small gray text, with "2건" count on right
- Expense list (no cards, just clean rows with generous padding):
  - Row 1: ☕ emoji (small, muted) | "점심" in black | "12:30" below in gray | "-3,500" right-aligned in black
  - Row 2: ☕ emoji | "아메리카노" | "15:15" | "-1,300"
  - Each row separated by very subtle divider or whitespace only

- FAB button: solid black circle with white "+" icon, bottom right corner
- Bottom navigation bar: 3 icons only, no labels or very small labels
  - 🏠 홈 (selected, black)
  - 📅 캘린더 (gray)
  - ⚙️ 설정 (gray)

Background: pure white or very warm white (#FAFAFA)
Typography: one large hero number dominates the screen, everything else is intentionally small and quiet
Style: Apple-like minimalism, Muji-inspired, lots of breathing room
NO decorations, NO gradients, NO shadows, NO cards with borders
Device frame: iPhone 15 Pro
```

---

### 2. 메인 화면 — 여유 상태 (다크)

```
Same layout as #1, but dark mode:

- Background: #1A1A1A (warm dark, not pure black)
- Hero number "₩5,200": #F0F0F0 (near white)
- All text: #F0F0F0 (main) or #666666 (sub/labels)
- Progress bar: #333333 background, #F0F0F0 filled portion
- Bottom nav: #2A2A2A background
- FAB: white circle with black "+" icon
- Expense amounts: #F0F0F0
- Dividers: #2A2A2A (barely visible)
- Emoji icons: unchanged (native emoji rendering)

The dark mode should feel warm and restful, not harsh. Minimal contrast adjustments — the hero number remains the brightest element on screen.
```

---

### 3. 메인 화면 — 주의 상태 (잔액 부족)

```
Same minimal layout as #1, but the NUMBER expresses worry:

- Hero number: "₩2,800" — slightly smaller font size than comfortable state (44pt instead of 52pt)
- Number color: muted warm tone or pastel yellow #FFD966
- Very subtle micro-shake or tremor implied in the typography (slightly tilted baseline or uneven letter spacing to convey nervousness)
- Progress bar: 28% filled, shifted to pastel yellow #FFD966
- Status message below number: "조금만 아껴보자..!" in small muted text

Everything else identical. The ONLY things that change are the number's size, color, and the progress bar color. The minimalism is preserved — the number's personality shift IS the entire mood change.
```

---

### 4. 메인 화면 — 위험 상태 (예산 초과)

```
Same minimal layout, but the NUMBER expresses distress:

- Hero number: "-₩2,300" — smaller font (40pt), displayed in pastel red #FF8B8B
- The minus sign is prominent and uncomfortable
- Background: very faint pink tint (#FFF5F5) — almost imperceptible but emotionally present
- Progress bar: 0% filled, entire bar in pastel red #FF8B8B
- Status message: "으앙... 한도 초과!" in small muted red text

The screen should feel slightly uncomfortable — the pink tint and red number create subtle tension without being aggressive. Still minimal, still clean, but the vibe has shifted.
```

---

### 5. 메인 화면 — 시간대별 배경 변화

```
Show 4 variations of the same home screen side by side (or as a sequence), demonstrating how the background tone shifts with time of day:

1. Morning (06:00-11:59): warm cream background #FFF8E7, soft and fresh feeling
2. Afternoon (12:00-17:59): clean white background #F5F5F5, bright and neutral
3. Evening (18:00-21:59): warm amber tint #FFF0E0, cozy sunset feeling
4. Night (22:00-05:59): cool blue-gray #EEF0F8, calm and restful

Each frame shows the same "₩5,200" hero number and expense list, but the background color creates a distinctly different mood. The transition between times should feel natural and ambient — like the app is breathing with the user's day.

Show these as 4 phone screens in a row, labeled with time.
```

---

### 6. 지출 입력 화면 (바텀시트)

```
Design a bottom sheet for expense input, overlaying the dimmed home screen.

Bottom sheet (white, rounded top corners 24px, 65% screen height):
- Drag handle: small gray pill at top center
- Title row: "지출 기록" left-aligned, "✕" close button right
-
- Amount display: "0" in large bold centered text (48pt), with blinking cursor feel
  - As user types, number grows: "3" → "35" → "350" → "3,500"
-
- Category row (5 emoji buttons, evenly spaced, centered):
  - 🍚 (selected: tiny underline below emoji)
  - 🚌
  - ☕
  - 🛍️
  - 📦
  - Each emoji is 32px, with small label below: "식비" "교통" "카페" "쇼핑" "기타"
  - Selected category has a subtle underline or dot, NOT a colored circle
-
- Custom number keypad (3 columns × 4 rows):
  [1] [2] [3]
  [4] [5] [6]
  [7] [8] [9]
  [⌫] [0] [00]  (backspace on left, double-zero on right)
  - Keys: no borders, no backgrounds — just large tappable numbers on white
  - Key text: 24pt, medium weight, dark gray
  - Generous tap targets (64px height per row)

NO "저장하기" button visible — save happens automatically when user taps outside or swipes down, OR a subtle "저장" text button appears after amount + category are selected.

Style reference: docs/ui/image copy.png — extremely clean, no visual noise
Dark mode: sheet background #2A2A2A, key text #F0F0F0
```

---

### 7. 캘린더 화면

```
Design a minimal calendar screen for monthly expense tracking.

Layout:
- Header: "2026. 03" centered, with "<" and ">" arrows for month navigation
- Stats row: "연속 7일 · 성공 24회" centered in small gray text

- Calendar grid:
  - Weekday headers: S M T W T F S (single letters, gray)
  - Date numbers: plain black text, no backgrounds
  - Success indicator: tiny black dot (•) below the date number
  - Failure indicator: tiny red dot (•) below the date number
  - Today: bold text weight, no circle or highlight
  - Future dates: light gray text
  - The dots are the ONLY decoration — no circles, no colored backgrounds

- Below calendar, selected day detail:
  - "3월 24일" left-aligned, bold | "-4,800원" right-aligned
  - Expense rows below (same minimal style as home screen):
    - ☕ 아침 | -2,000
    - ☕ 커피 | -2,800

- Bottom nav with 캘린더 tab selected

Background: white
Style reference: docs/ui/image copy 2.png — the calendar is intentionally sparse
NO colored date backgrounds, NO card wrappers around the calendar
```

---

### 8. 설정 화면

```
Design a minimal settings screen.

Layout:
- Title: "설정" top-left, no app bar background

- Settings list (clean rows, full-width, separated by thin dividers):
  - "매일 알림" — toggle switch on right (black when on)
  - "알림 시간" — "21:00" right-aligned in gray, chevron ">"
  - "데이터 백업" — chevron ">"
  - "데이터 초기화" — text in red/coral color, chevron ">"
  - "다크 모드" — toggle switch on right
  - "버전" — "1.0.0" right-aligned in gray
  - "개인정보 처리방침" — chevron ">"
  - "오픈소스 라이선스" — chevron ">"

- No section headers, no grouping boxes — just a flat list
- No icons on the left side of settings items
- Toggle switches: simple, black fill when on, gray outline when off

- Bottom nav with 설정 tab selected

Background: white
Style reference: docs/ui/image copy 3.png — flat, no decoration, Apple Settings-like but simpler
```

---

### 9. 홈 위젯 (iOS/Android)

```
Design home screen widgets for the budget tracker app. Show both sizes on a realistic phone home screen background.

Small widget (2×2):
┌─────────────┐
│ 하루 만원     │  ← small gray label
│              │
│  ₩5,200     │  ← large bold number, status color
│              │
│ ━━━━░░ 52%  │  ← thin progress bar
└─────────────┘

Medium widget (4×2):
┌──────────────────────────┐
│ 하루 만원    2026.03.25   │
│                          │
│     ₩5,200              │  ← hero number
│  오늘도 알뜰살뜰!        │  ← status message
│                          │
│  ━━━━━━━━░░░░ 52%       │
│              [지출 기록 →]│  ← tap to open app
└──────────────────────────┘

Widget style:
- Rounded corners (iOS style)
- Semi-transparent white background with blur (iOS WidgetKit style)
- Number color changes with budget status (green/yellow/red)
- Dark mode: semi-transparent dark background
- Tap anywhere opens the app, "지출 기록" opens directly to expense input

Show widgets on a real iOS home screen with app icons around them.
```

---

### 10. 온보딩 화면 (3-step)

```
Design a 3-screen onboarding carousel. NO characters — use typography and simple geometric shapes.

Screen 1 — "하루 만원으로 도전!":
- Center: giant "₩10,000" number in bold (72pt)
- Below: thin progress bar at 100% (green)
- Title: "하루 만원으로 도전!"
- Subtitle: "매일 만원 안에서 생활하는\n새로운 절약 습관을 만들어요"
- Page dots: ● ○ ○
- "다음" button at bottom

Screen 2 — "3탭으로 기록":
- Center: simplified illustration of the bottom sheet keypad (flat, geometric)
  - Just the number "3,500" with category emoji row below
- Title: "3탭으로 기록"
- Subtitle: "금액 입력, 카테고리 선택, 끝.\n가장 빠른 지출 기록"
- Page dots: ○ ● ○

Screen 3 — "숫자가 말해줘요":
- Center: three variations of the hero number stacked:
  - "₩7,200" large, green-tinted (comfortable)
  - "₩2,800" medium, yellow-tinted (cautious)
  - "-₩2,300" small, red-tinted (over budget)
- Title: "숫자가 말해줘요"
- Subtitle: "남은 예산에 따라 숫자의 크기와\n색상이 당신의 감정을 대신합니다"
- Page dots: ○ ○ ●
- "시작하기" button (black, full width, white text)

Background: white, generous padding
Style: typographic-driven, no illustrations except geometric shapes
```

---

### 11. 스플래시 화면

```
Design a minimal splash screen.

Light mode:
- White background (#FAFAFA)
- Centered vertically:
  - "₩" symbol in very large size (96pt), light gray (#CCCCCC)
  - Below: "하루 만원" in bold Pretendard (24pt), black
- Small loading spinner at bottom: thin black circular

Dark mode:
- Background: #1A1A1A
- "₩" symbol: #333333 (subtle)
- "하루 만원": #F0F0F0
- Spinner: white

No mascot, no illustration. The ₩ symbol IS the brand mark. Stark, confident, minimal.
```

---

### 12. 빈 상태 (지출 없음)

```
Design the home screen empty state when no expenses are recorded today.

- Same layout as the main home screen
- Hero number: "₩10,000" in large bold text — full budget remaining
- Progress bar: 100% filled, subtle green tint
- Status message: "오늘은 0원 도전?!" in small muted text

- Below "오늘의 지출" section header:
  - "0건" count on right
  - Empty area with centered text:
    - "아직 지출이 없어요" in medium gray
    - "첫 지출을 기록해볼까요?" in light gray, smaller
  - Subtle dotted line or arrow pointing toward the FAB button

The empty state should feel aspirational and motivating — "you haven't spent anything yet, and that's great!" rather than "there's nothing here."

NO sad faces, NO empty box illustrations. Just clean typography.
```

---

### 13. 도토리 획득 축하 팝업

```
Design a celebration modal that appears when the user successfully stays under budget.

- Semi-transparent dark overlay (#00000066) on the home screen
- Centered card (white, 24px rounded corners, no shadow):
  - Top: "🎉" emoji, large (48px)
  - Title: "만원 챌린지 성공!" in bold (20pt)
  - Body: "오늘 5,200원을 남겼어요!" in regular (16pt)
  - Reward line: "🌰 +1 도토리 획득" in medium text
  - Streak line: "🔥 연속 7일째 성공 중!" in small gray text
  -
  - "확인" button: black, full-width, white text, 12px rounded

- Confetti particles (pastel colors: #FFB366, #7EC8A0, #9BB8FF, #C49BFF) falling in the background, behind the card

Dark mode: card background #333333, text #F0F0F0, button white with black text

Style: the ONLY moment in the app with decorative elements (confetti). This contrast makes the celebration feel special.
```

---

### 14. 마이크로 인터랙션 시퀀스

```
Design a sequence showing the expense recording micro-interaction:

Frame 1: User taps FAB "+" button
  - FAB scales up slightly (1.1x) then opens bottom sheet

Frame 2: User types "3500" on keypad
  - Number "3,500" appears in the amount display, growing character by character

Frame 3: User taps ☕ category emoji
  - Subtle underline appears below the selected emoji

Frame 4: Bottom sheet dismisses, returning to home screen
  - The hero number animates: "₩5,200" counting down to "₩1,700"
  - The countdown takes 500ms, numbers visibly ticking
  - New expense row slides up from bottom into the list

Frame 5: Final state
  - "₩1,700" now displayed in smaller size with yellow tint (cautious state)
  - Progress bar has shrunk to 17%
  - New expense "☕ 아메리카노 -3,500" visible in the list

Show these as 5 sequential phone screens with arrows between them, annotated with timing (e.g., "500ms countdown", "300ms slide").
```

---

### 프롬프트 사용 가이드

1. **레퍼런스 첨부**: docs/ui/ 이미지를 AI 도구에 함께 업로드하여 스타일 일관성 유지
2. **도구 선택**: Figma AI(프로토타입), GPT Image(빠른 반복), Midjourney(고퀄리티 목업)
3. **사이즈**: 393x852 (iPhone 15 Pro) 비율
4. **핵심 원칙**: 캐릭터 없음, 숫자가 주인공, 극도의 미니멀리즘
5. **다크모드**: 라이트 먼저 확정 → 색상만 교체하여 다크 생성
6. **후처리**: 생성된 UI를 Figma에서 컴포넌트 정리 → Flutter 구현 레퍼런스로 활용
