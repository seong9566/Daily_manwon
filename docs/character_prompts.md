## Leonardo AI 캐릭터 프롬프트 가이드

**Date**: 2026-03-24
**Status**: 준비 완료
**용도**: "하루 만원 살기 플래너" 앱 캐릭터 에셋 생성

---

### 공통 설정

| 항목 | 설정값 |
|------|--------|
| 모델 | Leonardo Phoenix 또는 SDXL |
| 스타일 프리셋 | Illustration / Anime |
| 네거티브 프롬프트 | realistic, photorealistic, 3D render, dark, horror, complex background, text, watermark |
| 배치 수량 | 각 프롬프트당 4장 생성 → 베스트 1장 선택 |

---

### 에셋 목록 & 프롬프트

#### 1. 기본 캐릭터 시트 (레퍼런스용)

- **용도**: 이후 모든 프롬프트의 Image Reference로 사용
- **우선순위**: 가장 먼저 생성

```
A cute chibi-style squirrel character sheet, multiple poses and expressions on one page, pastel orange and cream color palette, big round sparkling eyes, small round body, fluffy tail, holding an acorn, simple flat illustration style, clean outlines, minimal shading, kawaii aesthetic, white background, mobile app mascot design, front view and side view, character turnaround
```

> **TIP**: 이 이미지를 Leonardo AI의 "Image Guidance" 기능에 업로드하면 이후 모든 생성에서 캐릭터 일관성을 유지할 수 있습니다.

---

#### 2. 행복 상태 — P0

- **용도**: 메인 화면 (남은 금액 >= 5,000원)
- **사이즈**: 200x200px

```
A single cute chibi squirrel character, very happy expression, sparkling big eyes, rosy pink cheeks, hugging a pile of golden acorns lovingly, fluffy orange tail wagging, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app sticker style, 200x200 resolution
```

---

#### 3. 걱정 상태 — P0

- **용도**: 메인 화면 (남은 금액 1,000~4,999원)
- **사이즈**: 200x200px

```
A single cute chibi squirrel character, worried nervous expression, one eye squinting, small sweat drop on forehead, holding one small acorn tightly with both paws, slightly hunched posture, fluffy orange tail curled inward, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app sticker style, 200x200 resolution
```

---

#### 4. 울상 상태 — P0

- **용도**: 메인 화면 (남은 금액 < 1,000원 또는 초과)
- **사이즈**: 200x200px

```
A single cute chibi squirrel character, crying softly, big teary eyes with small tear drops, lying flat on the ground face down, empty small cloth bag beside it, droopy fluffy orange tail, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app sticker style, 200x200 resolution
```

---

#### 5. 놀람 리액션 — P1

- **용도**: 지출 기록 시 리액션 (대형 지출 > 5,000원)
- **사이즈**: 120x120px

```
A single cute chibi squirrel character, very surprised shocked expression, mouth wide open, eyes popping out, jumping backward, acorn flying out of paws, exclamation mark above head, fluffy orange tail standing straight up, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app sticker style, 120x120 resolution
```

---

#### 6. 끄덕 리액션 — P1

- **용도**: 지출 기록 시 리액션 (소액 지출 <= 2,000원)
- **사이즈**: 120x120px

```
A single cute chibi squirrel character, gentle nodding expression, eyes closed softly smiling, one paw giving thumbs up, small sparkle effect nearby, relaxed fluffy orange tail, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app sticker style, 120x120 resolution
```

---

#### 7. 앱 아이콘 — P0

- **용도**: iOS/Android 앱 아이콘
- **사이즈**: 1024x1024px

```
A cute chibi squirrel face close-up icon, front facing, big sparkling round eyes, rosy cheeks, tiny smile, small golden acorn on top of head like a hat, pastel orange and cream color, perfect circle composition, simple flat illustration style, bold clean outlines, kawaii aesthetic, solid pastel orange background (#FFB366), app icon design, high detail, 1024x1024 resolution
```

---

#### 8. 스플래시 화면용 — P1

- **용도**: 앱 시작 스플래시 화면
- **사이즈**: 300x300px

```
A cute chibi squirrel character standing proudly, holding a golden acorn above its head with both paws like a trophy, small sparkles and stars around, happy confident expression, fluffy orange tail, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app splash screen illustration, 300x300 resolution
```

---

#### 9. 빈 상태용 — P1

- **용도**: 지출 기록이 없을 때 표시
- **사이즈**: 150x150px

```
A cute chibi squirrel character sitting alone, looking up curiously with tilted head, question mark floating above, paws resting on lap, waiting patiently, fluffy orange tail wrapped around body, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app empty state illustration, 150x150 resolution
```

---

#### 10. 도토리 획득 축하 — P1

- **용도**: 하루 만원 이내 성공 시 축하 화면
- **사이즈**: 200x200px

```
A cute chibi squirrel character jumping with joy, arms raised high, eyes sparkling with excitement, golden acorns raining down from above, small confetti and star particles around, fluffy orange tail bouncing, pastel orange and cream body color, simple flat illustration style, clean vector-like lines, kawaii aesthetic, pure white background, no shadow, centered composition, mobile app celebration illustration, 200x200 resolution
```

---

#### 11. 도토리 아이템 (단독) — P1

- **용도**: 도토리 카운터 아이콘, UI 요소
- **사이즈**: 64x64px

```
A single cute golden acorn icon, simple flat illustration style, warm brown cap on top, shiny golden body, small kawaii face with tiny dot eyes and small smile on the acorn, pastel warm tones, clean outlines, pure white background, no shadow, centered, mobile app item icon, 64x64 resolution
```

---

#### 12. 카테고리 아이콘 세트 — P0

- **용도**: 지출 입력 화면 카테고리 선택 (식비/교통/카페/쇼핑/기타)
- **사이즈**: 각 48x48px

```
A set of 5 cute kawaii food and lifestyle icons in a row, simple flat illustration style with clean outlines: (1) a cute rice bowl with small face, (2) a cute bus with small face, (3) a cute coffee cup with small face, (4) a cute shopping bag with small face, (5) a cute cardboard box with small face. Pastel color palette, each icon in its own pastel color - pink rice bowl, blue bus, brown coffee, purple shopping bag, gray box. Pure white background, mobile app category icons, consistent style across all icons
```

---

### 에셋 생성 순서 (추천)

| 순서 | 에셋 | 우선순위 | 예상 시간 |
|------|------|----------|----------|
| 1 | 기본 캐릭터 시트 (레퍼런스) | - | 20분 |
| 2 | 앱 아이콘 (#7) | P0 | 15분 |
| 3 | 행복 상태 (#2) | P0 | 15분 |
| 4 | 걱정 상태 (#3) | P0 | 15분 |
| 5 | 울상 상태 (#4) | P0 | 15분 |
| 6 | 카테고리 아이콘 (#12) | P0 | 20분 |
| 7 | 놀람 리액션 (#5) | P1 | 10분 |
| 8 | 끄덕 리액션 (#6) | P1 | 10분 |
| 9 | 스플래시 화면 (#8) | P1 | 10분 |
| 10 | 빈 상태 (#9) | P1 | 10분 |
| 11 | 도토리 획득 축하 (#10) | P1 | 10분 |
| 12 | 도토리 아이템 (#11) | P1 | 10분 |
| **합계** | | | **약 2.5시간** |

---

### 후처리 워크플로우

```
Step 1: Leonardo AI에서 이미지 생성 (프롬프트 사용)
    ↓
Step 2: 베스트 이미지 선택 (4장 중 1장)
    ↓
Step 3: 투명 배경 처리
    - ChatGPT (GPT Image): "Remove the background and make it transparent, keep the character exactly the same"
    - 또는 remove.bg (무료)
    ↓
Step 4: 리사이징 & 정리
    - Figma 또는 Canva에서 정확한 사이즈로 리사이징
    - 200x200, 120x120, 1024x1024, 64x64, 48x48
    ↓
Step 5: Flutter 프로젝트에 추가
    - assets/images/character/ 폴더에 저장
    - pubspec.yaml에 에셋 경로 등록
```

---

### 파일 네이밍 규칙

```
assets/images/character/
├── char_happy.png          # 행복 상태
├── char_worried.png        # 걱정 상태
├── char_crying.png         # 울상 상태
├── char_surprised.png      # 놀람 리액션
├── char_nodding.png        # 끄덕 리액션
├── char_celebration.png    # 도토리 획득 축하
├── char_empty_state.png    # 빈 상태
├── char_splash.png         # 스플래시 화면
├── icon_acorn.png          # 도토리 아이템
├── icon_food.png           # 카테고리 - 식비
├── icon_transport.png      # 카테고리 - 교통
├── icon_cafe.png           # 카테고리 - 카페
├── icon_shopping.png       # 카테고리 - 쇼핑
├── icon_etc.png            # 카테고리 - 기타
└── app_icon.png            # 앱 아이콘
```
