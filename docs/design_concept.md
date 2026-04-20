## 디자인 컨셉: 하루 만원 살기 플래너

**Date**: 2026-03-25
**Updated**: 2026-04-21
**Status**: 구현 완료 (Sprint 1 + 2)

---

### 1. 디자인 철학

**컨셉 키워드**: 심플 미니멀 + 숫자와 고양이가 함께 감정을 표현하는 앱

**핵심 방향**:
- **숫자 축**: 남은 금액 숫자의 크기·색상·모션이 예산 상태를 즉각적으로 전달
- **고양이 축**: 손그림 낙서체 고양이 캐릭터가 예산 상태를 감성적으로 표현
- 불필요한 장식 배제, 숫자와 고양이·여백으로만 상태를 전달
- 타이포그래피와 색상 변화로 잔액 상태를 직관적으로 표현
- 다크모드 지원으로 야간 사용 편의성 확보

**디자인 원칙**:
1. **숫자 + 고양이 이중 감정**: 숫자(즉각적 인식)와 고양이(감성적 공감)가 동일한 예산 상태를 각자의 언어로 표현
2. **3초 룰**: 앱을 열고 3초 안에 오늘 예산 상태를 파악할 수 있어야 한다
3. **원탭 기록**: 지출 기록까지 최소 탭으로 도달
4. **색상 = 정보**: 프로그레스 바, 캘린더 dot, 고양이 상태 모두 동일한 4단계 상태 색상 사용
5. **여백의 미**: 요소 간 충분한 여백으로 깔끔한 인상 유지
6. **비율 기반 상태**: 예산 잔액은 절댓값이 아닌 비율(%)로 상태 판단 — 향후 금액 커스텀 대응

---

### 2. 컬러 팔레트

#### 상태 색상 (HeroBudgetNumber, 프로그레스 바, 캘린더 dot)

숫자 감정 표현에 사용되는 핵심 색상. `app_colors.dart` 기준으로 구현됨.

> 폰트 크기 44sp 고정 (상태 전환 시 레이아웃 흔들림 방지).
> 임계값: `comfortableRatioThreshold = 0.5` (50%), `normalRatioThreshold = 0.3` (30%)

```
Status Colors (숫자 감정 — 구현 완료)
├── 여유 (≥50%):  #000000 라이트 / #FFFFFF 다크  (fontWeight 900, 44sp)
├── 보통 (30~49%): #F5A623  (앰버 오렌지, fontWeight 800, 44sp)
├── 위험 (0~29%):  #E85D5D  (코랄 레드, fontWeight 700, 44sp)
├── 초과 (<0%):    #C0392B  (딥 레드, fontWeight 700, 44sp)
└── 보조 액센트:  #4A90D9  (스카이 블루 — 수정 스와이프 배경)
```

#### 기반 색상 (AppColors — 테마, 네비게이션, 카드 등)

```
Primary Colors (메인 색상)
├── 프라이머리 (라이트): #000000 검정 — 버튼 배경, 네비게이션 강조
├── 프라이머리 (다크):   #FFFFFF 흰색 — 다크모드 버튼, 강조
└── 프라이머리 라이트:   #EEEEEE 연회색 — 네비게이션 인디케이터 배경

Category Colors (카테고리 대표 색상)
├── 식비:          #FF9B9B  (파스텔 레드)
├── 교통:          #9BB8FF  (파스텔 블루)
├── 카페:          #C4A882  (파스텔 브라운)
├── 쇼핑:          #C49BFF  (파스텔 퍼플)
└── 기타:          #B8B8B8  (라이트 그레이)

Category Chip Colors (카테고리 배경 칩 — 구현 완료)
├── 식비:          #FFF0E0  (연한 오렌지)
├── 교통:          #E8F4FD  (연한 블루)
├── 카페:          #F5ECD7  (연한 브라운)
├── 쇼핑:          #F3E8FD  (연한 퍼플)
└── 기타:          #F0F0F0  (연한 그레이)

Neutral Colors (뉴트럴)
├── 텍스트 메인:   #3D3D3D  (다크 그레이)
├── 텍스트 서브:   #8E8E8E  (미디엄 그레이)
├── 구분선:        #E5E7EB  (라이트 그레이)
└── 카드 배경:     #FFFFFF  (화이트)
```

#### 다크 모드

```
Dark Mode Colors (구현 완료)
├── 배경:          #1A1A1A
├── 서피스:        #2A2A2A
├── 카드:          #333333
├── 텍스트 메인:   #F0F0F0
├── 텍스트 서브:   #A0A0A0
└── 구분선:        #3D3D3D
```

---

### 3. 타이포그래피

**폰트**: Pretendard (400/500/600/700/800/900)

| 용도 | 크기 | 굵기 | 구현 파일 |
|------|------|------|----------|
| 남은 금액 (여유) | **44sp 고정** | Black (900) | `hero_budget_number.dart` |
| 남은 금액 (보통) | 44sp 고정 | ExtraBold (800) | `hero_budget_number.dart` |
| 남은 금액 (위험) | 44sp 고정 | Bold (700) | `hero_budget_number.dart` |
| 남은 금액 (초과) | 44sp 고정 | Bold (700) | `hero_budget_number.dart` |
| 바텀시트 금액 입력 | 44sp | Bold (700) | `expense_add_screen.dart` |
| 섹션 타이틀 | 18sp | SemiBold (600) | AppTypography.titleMedium |
| 리스트 항목 금액 | 16sp | Medium (500) | AppTypography.bodyLarge |
| 리스트 항목 설명 | 14sp | Regular (400) | AppTypography.bodyMedium |
| 캡션/시간 | 12sp | Regular (400) | AppTypography.bodySmall |

상태 전환 시 `AnimatedDefaultTextStyle`로 크기+색상+웨이트 동시 애니메이션 (400ms, easeInOut).

---

### 4. 숫자의 감정

숫자 자체가 잔액 상태를 감각적으로 표현한다. `HeroBudgetNumber` 위젯에 구현됨.

| 상태 | 조건 (비율) | 10,000원 기준 | 크기 | 색상 (라이트/다크) | 모션 |
|------|------------|--------------|------|------|------|
| 여유 | ≥ 50% | ≥ 5,000원 | 44sp, w900 | 검정 / 흰색 | 없음 (정적) |
| 보통 | 30~49% | 3,000~4,999원 | 44sp, w800 | #F5A623 | shakeX (2px, 1회) |
| 위험 | 0~29% | 1~2,999원 | 44sp, w700 | #E85D5D | shakeX (2px, 1회) |
| 초과 | < 0% | < 0원 | 44sp, w700 | #C0392B | shakeX (4px, hz:4, 1회) |

**지출 기록 시 인터랙션** (구현 완료):
- 금액 변경 시: `ValueKey(remainingBudget)`로 바운스 scale 1.08→1.0 (elasticOut, 300ms)
- 위험/초과 진입 시: shake 1회 후 멈춤

**이월 금액 표시** (구현 완료):
- 히어로 숫자 하단: `+ 어제 이월 ₩2,300`
- fadeIn (300ms, delay 200ms) + slideY (0.3→0, easeOut)

---

### 5. ~~시간대별 배경 톤 변화~~ (2026-04-07 제거됨)

> **제거 사유**: Primary Color를 검정/흰색으로 전환하면서 시간대별 배경 톤 개념 폐기.
> `TimeBasedTheme` 유틸리티 및 관련 `AppColors.bg*` 토큰 삭제 완료.
>
> **현재 배경**: 라이트모드 `#FFFFFF`, 다크모드 `#1A1A1A` 고정.

---

### 6. UI 컴포넌트 스타일

**전체 무드**: 심플 미니멀 + 숫자 중심

**카드**:
- 모서리 반경: 16px (부드러운 라운드)
- 그림자: 매우 연하게 (elevation 1~2)
- 패딩: 16px

**버튼**:
- FAB (지출 추가): 둥근 원형, **검정 배경 (#1A1A2E) + 흰색 + 아이콘** (구현 완료)
- 카테고리 버튼: 둥근 사각형 칩, 선택 시 해당 카테고리 칩 색상으로 채워짐 (구현 완료)
- 저장 버튼: 풀 와이드, 검정 배경, 라운드 14px (구현 완료)
- 삭제 다이얼로그: 둥근 카드 (20px), 이모지 + 부드러운 문구 (구현 완료)

**아이콘**:
- 스타일: 라운드 라인 아이콘 (Material Rounded)
- 카테고리 아이콘 (이모지):
  - 식비: 🍚 밥그릇
  - 교통: 🚌 버스
  - 카페: ☕ 커피잔
  - 쇼핑: 🛍️ 쇼핑백
  - 기타: 📦 상자

**스와이프 인터랙션** (구현 완료):
- 오른쪽→왼쪽 (endToStart): 삭제 — 코랄 레드 (#E85D5D) 배경, 휴지통 아이콘
- 왼쪽→오른쪽 (startToEnd): 수정 — 스카이 블루 (#4A90D9) 배경, 편집 아이콘
- dismiss threshold: 50% (절반 이상 드래그 시 동작)

**삭제 다이얼로그** (구현 완료):
- 🗑️ 이모지 + "정말 삭제할까요?" + "이 지출 기록이 사라져요"
- "아니요" (아웃라인) / "삭제할게요" (코랄 레드 배경)
- 둥근 모서리 (20px), 다크모드 대응

**마이크로 인터랙션 가이드**:
- 숫자 상태 전환: AnimatedDefaultTextStyle (300ms, easeInOut) — 색상·웨이트만 변화
- 금액 변경: TweenAnimationBuilder<int> 카운팅 (600ms, easeOutCubic)
- 위험 상태 진입: shakeX 2px, 1회 후 멈춤
- 초과 상태 진입: shakeX 4px, hz:4, 1회
- 이월 금액: fadeIn + slideY (300ms)
- 숫자 키패드 탭: HapticFeedback.lightImpact()

---

### 7. 화면별 디자인 방향

#### 메인 화면 (구현 완료 — `home_screen.dart`)

```
┌─────────────────────────┐
│                         │  ← 배경: 라이트 #FFFFFF / 다크 #1A1A1A
│     2026. 03. 26        │  ← 날짜, 12sp
│     오늘 남은 금액       │  ← 12sp, 보조 색상
│                         │
│     ₩7,200              │  ← 히어로 숫자 (44sp, 검정 — 여유 상태)
│  + 어제 이월 ₩1,200     │  ← 이월 금액, fadeIn 애니메이션
│                         │
│     ━━━━━━━━░░          │  ← 프로그레스 바 (상태별 색상)
│                         │
│  🌰 12 · 🔥 7일         │  ← 도토리 + 스트릭
│                         │
│  ── 오늘의 지출    2건 ── │
│                         │
│  🍚 점심 김밥    -3,500  │  ← 카테고리 칩 배경색
│     12:30               │
│                         │
│  ☕ 아이스 아메   -1,300  │  ← ← 스와이프: 수정/삭제
│     15:15               │
│                         │
│              ┌───┐      │
│              │ + │ FAB  │  ← 검정 원형, 흰색 +
│              └───┘      │
│                         │
│  🏠    📅    📊    ⚙️    │
│  홈  캘린더 통계  설정   │
└─────────────────────────┘
```

#### 지출 입력 화면 (구현 완료 — `expense_add_screen.dart`)

```
┌─────────────────────────┐
│         ────            │  ← 드래그 핸들
│  지출 기록          ✕    │  ← titleMedium
│                         │
│    ₩ 23,680 원          │  ← 44sp, 실시간 갱신
│                         │
│  🍚  🚌  ☕  🛍️  📦     │  ← 카테고리 칩 (선택 시 고유 배경색)
│                         │
│  ─────────────────────  │
│  [  1  ][  2  ][  3  ]  │
│  [  4  ][  5  ][  6  ]  │  ← 커스텀 숫자 키패드
│  [  7  ][  8  ][  9  ]  │     햅틱 피드백
│  [     ][  0  ][ ←  ]   │
│                         │
│  [      기록하기      ]  │  ← 검정 배경, 흰색 텍스트
└─────────────────────────┘
```

#### 캘린더 화면 (구현 완료 — `calendar_screen.dart`)

```
┌─────────────────────────┐
│  <   2026. 03   >       │  ← 월 네비게이션
│                         │
│  연속 7일 · 성공 24회    │  ← 통계
│                         │
│  일 월 화 수 목 금 토    │
│           1  2  3  4    │
│   5  6  7  8  9 10 11   │
│  12 13 14 15 16 17 18   │  ← 성공: 검정 dot, 실패: 빨강 dot
│  19 20 21 22 23 24 25   │     미래: 연한 회색
│  26 27 28 29 30 31      │
│                         │
│  ── 3월 24일  -4,800원 ── │
│                         │
│  ☕ 아침        -2,000   │  ← 선택일 지출 내역
│  ☕ 커피        -2,800   │
│                         │
│  🏠    📅    ⚙️          │
└─────────────────────────┘
```

#### 설정 화면 (구현 완료 — `settings_screen.dart`)

```
┌─────────────────────────┐
│  설정                    │
│                         │
│  매일 알림        [🔘]   │  ← Switch 토글
│  ─────────────────────  │
│  알림 시간     21:00 >   │  ← TimePicker
│  ─────────────────────  │
│  데이터 백업          >  │
│  ─────────────────────  │
│  데이터 초기화        >  │  ← 빨간색 텍스트
│  ─────────────────────  │
│  다크 모드        [🔘]   │  ← ThemeMode 전환
│  ─────────────────────  │
│  버전            1.0.0   │
│  ─────────────────────  │
│  개인정보 처리방침    >  │
│  ─────────────────────  │
│  오픈소스 라이선스    >  │
│                         │
│  🏠    📅    ⚙️          │
└─────────────────────────┘
```

#### 축하 다이얼로그 (구현 완료 — `success_dialog.dart`)

```
┌─────────────────────────┐
│  (반투명 오버레이)       │
│                         │
│  ┌───────────────────┐  │
│  │      🎉          ✕│  │
│  │                   │  │
│  │ 만원 챌린지 성공!  │  │
│  │ 오늘 5,200원을     │  │
│  │ 남겼어요!          │  │
│  │                   │  │
│  │ 🌰 도토리 획득  +1 │  │
│  │ 🔥 연속 성공  7일째│  │
│  │                   │  │
│  │ [     확인     ]  │  │  ← 검정 버튼
│  └───────────────────┘  │
│                         │
│  (confetti 파티클)       │
└─────────────────────────┘
```

---

### 8. 구현 파일 매핑

| 디자인 요소 | 구현 파일 |
|------------|----------|
| 숫자 감정 표현 | `lib/features/home/presentation/widgets/hero_budget_number.dart` |
| 금액 카운트다운 | `lib/features/home/presentation/widgets/budget_countdown.dart` |
| 고양이 캐릭터 | `lib/features/home/presentation/widgets/budget_cat_indicator.dart` |
| 도토리/스트릭 뱃지 | `lib/core/widgets/acorn_streak_badge.dart` |
| 이월 배지 | `lib/features/home/presentation/widgets/carryover_badge_widget.dart` |
| 지출 리스트 아이템 | `lib/features/home/presentation/widgets/expense_list_item.dart` |
| 메인 홈 화면 | `lib/features/home/presentation/screens/home_screen.dart` |
| 바텀시트 | `lib/features/expense/presentation/screens/expense_add_screen.dart` |
| 숫자 키패드 | `lib/features/expense/presentation/widgets/number_keypad.dart` |
| 카테고리 선택 | `lib/features/expense/presentation/widgets/category_selector.dart` |
| 즐겨찾기 템플릿 | `lib/features/expense/presentation/widgets/favorite_templates_section.dart` |
| 캘린더 화면 | `lib/features/calendar/presentation/screens/calendar_screen.dart` |
| 캘린더 날짜 셀 | `lib/features/calendar/presentation/widgets/calendar_day_cell.dart` |
| 통계 화면 | `lib/features/stats/presentation/screens/stats_screen.dart` |
| 설정 화면 | `lib/features/settings/presentation/screens/settings_screen.dart` |
| 축하 다이얼로그 | `lib/features/home/presentation/widgets/success_dialog.dart` |
| 다크모드 전환 | `lib/core/theme/theme_provider.dart` |
| 컬러 팔레트 | `lib/core/theme/app_colors.dart` |
| 타이포그래피 | `lib/core/theme/app_typography.dart` |
| 카테고리 이모지/칩색 | `lib/core/constants/app_constants.dart` (ExpenseCategory enum) |
| 바텀 네비게이션 | `lib/core/router/app_shell.dart` |
