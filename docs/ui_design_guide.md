## UI 디자인 가이드: 심플 미니멀 UI + 숫자 감정 표현

**Date**: 2026-03-25
**Updated**: 2026-04-21
**Status**: v2 — Primary black/white 전환 반영
**컨셉**: 숫자 자체가 감정을 표현하는 미니멀 앱

---

### 디자인 원칙

1. **숫자가 주인공**: 남은 금액 숫자가 색상·굵기·모션으로 감정을 전달
2. **미니멀 레이아웃**: 불필요한 장식 제거, 핵심 정보만 화면에
3. **마이크로 인터랙션**: 모든 인터랙션에 의미 있는 피드백 제공
4. **고양이 캐릭터**: 예산 상태에 따라 고양이 표정이 함께 변화

---

## 1. 숫자 감정 표현 스펙

### 1.1 남은 금액 숫자 상태 정의

| 상태 | 조건 (비율) | 10,000원 기준 | 의미 |
|------|------------|--------------|------|
| **여유** | 잔액 ≥ 50% | ≥ 5,000원 | 오늘 잘 하고 있음 |
| **보통** | 30% ≤ 잔액 < 50% | 3,000~4,999원 | 적당히 사용 중 |
| **위험** | 0% ≤ 잔액 < 30% | 1~2,999원 | 거의 다 씀 |
| **초과** | 잔액 < 0% | 0원 미만 | 예산 초과 |

> 임계값은 `AppConstants.comfortableRatioThreshold = 0.5`, `normalRatioThreshold = 0.3`으로 관리

### 1.2 상태별 타이포그래피 스펙

폰트 크기는 **44sp 고정** (레이아웃 안정성). 색상과 웨이트로만 상태를 구분.

| 상태 | 폰트 크기 | 폰트 웨이트 | 색상 (라이트) | 색상 (다크) |
|------|----------|-----------|------|------|
| 여유 | 44sp | Black (900) | `#000000` 검정 | `#FFFFFF` 흰색 |
| 보통 | 44sp | ExtraBold (800) | `#F5A623` 앰버 오렌지 | `#F5A623` |
| 위험 | 44sp | Bold (700) | `#E85D5D` 코랄 레드 | `#E85D5D` |
| 초과 | 44sp | Bold (700) | `#C0392B` 딥 레드 | `#C0392B` |

### 1.3 상태 전환 모션

```dart
// 상태 전환: 크기 + 색상 동시 애니메이션
AnimatedDefaultTextStyle(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  style: TextStyle(
    fontSize: _getFontSize(remaining),
    color: _getAmountColor(remaining),
    fontWeight: _getFontWeight(remaining),
    fontFeatures: [FontFeature.tabularFigures()],  // 숫자 너비 고정
  ),
  child: Text(formatWon(remaining)),
)
```

### 1.4 지출 입력 시 숫자 감소 애니메이션

```dart
// 차감 숫자 표시: 위에서 내려오며 사라짐
Text('-${formatWon(amount)}', style: subtractStyle)
  .animate()
  .fadeIn(duration: 150.ms)
  .slideY(begin: -0.5, end: 0.5, duration: 500.ms, curve: Curves.easeIn)
  .fadeOut(delay: 250.ms, duration: 250.ms)

// 메인 숫자 bounce
mainAmountWidget
  .animate(key: ValueKey(remaining))
  .scale(
    begin: const Offset(1.08, 1.08),
    end: const Offset(1.0, 1.0),
    duration: 300.ms,
    curve: Curves.elasticOut,
  )
```

### 1.5 이월 금액 표시

```dart
// 이월 금액: 메인 숫자 하단, 작은 보조 텍스트
// 형식: "+ 어제 이월 ₩2,300"
Text('+ 어제 이월 ${formatWon(carryOver)}')
  .animate()
  .fadeIn(duration: 300.ms, delay: 200.ms)
  .slideY(begin: 0.3, duration: 300.ms, curve: Curves.easeOut)
```

---

## 2. 배경 — ~~시간대별 배경 톤~~ (2026-04-07 제거됨)

> **제거 사유**: Primary Color를 검정/흰색으로 전환하면서 시간대별 배경 톤 개념 폐기.
> `TimeBasedTheme` 유틸리티 및 `AppColors.bg*` 토큰 삭제 완료.
>
> 현재 배경: 라이트모드 `#FFFFFF`, 다크모드 `#1A1A1A` 고정.

---

## 3. 마이크로 인터랙션 스펙

### 3.1 지출 기록 버튼 탭

| 항목 | 값 |
|------|-----|
| Duration | 150ms |
| Easing | `Curves.easeInOut` |
| 효과 | scale 1.0 → 0.95 → 1.0 |

```dart
widget
  .animate(onPlay: (c) => c.forward())
  .scale(
    begin: const Offset(1.0, 1.0),
    end: const Offset(0.95, 0.95),
    duration: 75.ms,
  )
  .then()
  .scale(
    begin: const Offset(0.95, 0.95),
    end: const Offset(1.0, 1.0),
    duration: 75.ms,
  )
```

### 3.2 지출 기록 완료 (소액 ≤ 2,000원)

| 항목 | 값 |
|------|-----|
| Duration | 300ms |
| Easing | `Curves.elasticOut` |
| 효과 | 체크 아이콘 scale + fade in |
| 색상 | 에메랄드 그린 `#2DBD8E` (`AppColors.statusComfortableStrong`) |

### 3.3 지출 기록 완료 (대형 > 5,000원)

| 항목 | 값 |
|------|-----|
| Duration | 400ms |
| Easing | `Curves.easeInOut` |
| 효과 | 숫자 shake + 코랄 레드 flash |
| Shake | X축 ±4px, 3회 반복 |

```dart
// shake 효과
mainAmountWidget
  .animate(key: ValueKey('shake_$remaining'))
  .shake(hz: 4, curve: Curves.easeInOut, duration: 400.ms)
```

### 3.4 스트릭 달성 축하

| 항목 | 값 |
|------|-----|
| Duration | 3,000ms |
| 패키지 | `confetti ^0.7.x` |
| 파티클 수 | 80개 |
| 파티클 색상 | 감정색 4종 + 카테고리색 4종 = 8색 (primary black 제외) |
| 발사 각도 | 상단 중앙 → 180° 확산 |

```dart
ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive,
  numberOfParticles: 80,
  colors: const [
    // 감정색
    Color(0xFFF5A623), // 앰버
    Color(0xFFE85D5D), // 코랄
    Color(0xFFC0392B), // 딥레드
    Color(0xFFFFE66D), // 노랑
    // 카테고리색
    Color(0xFFFF9B9B), // 식비
    Color(0xFF9BB8FF), // 교통
    Color(0xFFC4A882), // 카페
    Color(0xFFC49BFF), // 쇼핑
  ],
  child: const SizedBox(),
)
```

### 3.5 예산 초과 경고

| 항목 | 값 |
|------|-----|
| Duration | 600ms |
| 효과 | 배경 flash (딥 레드 10% 불투명도) |
| 숫자 | 딥 레드 + 떨림 |
| 알림 | 바텀 스낵바 (부드러운 slide up) |

### 3.6 금액 입력 키패드

| 항목 | 값 |
|------|-----|
| 진입 애니메이션 | slide up, 300ms, `Curves.easeOut` |
| 퇴장 애니메이션 | slide down, 250ms, `Curves.easeIn` |
| 숫자 버튼 탭 | scale 0.92, 100ms |
| 배경 | 반투명 블러 (BackdropFilter, sigma: 10) |

---

## 4. 홈 위젯 레이아웃 스펙

### 4.1 소형 위젯 (2×2, iOS 스몰 / Android 2×2)

```
┌─────────────────────┐
│  오늘 남은 금액       │  ← caption, 보조 색상
│                     │
│   ₩7,200            │  ← 큰 bold 숫자, 상태 색상
│                     │
│  21:30 기준          │  ← caption2, 연한 색상
└─────────────────────┘
```

| 요소 | 폰트 | 색상 |
|------|------|------|
| 레이블 | 12sp, Regular | 보조 텍스트 |
| 금액 숫자 | 32sp, Black | 상태별 색상 |
| 업데이트 시각 | 10sp, Regular | 연한 텍스트 |
| 배경 | 흰색 or 시스템 위젯 배경 | — |

### 4.2 중형 위젯 (4×2, iOS 미디엄 / Android 4×2)

```
┌──────────────────────────────────────┐
│  하루 만원 살기         오늘 남은 금액  │
│                                      │
│              ₩7,200                  │  ← 중앙 대형 숫자
│                                      │
│  오늘 지출 ₩2,800      스트릭 🔥 5일  │
└──────────────────────────────────────┘
```

### 4.3 home_widget 패키지 연동

```dart
// 패키지: home_widget ^0.6.x
// 데이터 업데이트 (지출 기록 시 호출)
Future<void> updateHomeWidget({
  required int remaining,
  required int todaySpent,
  required int streakDays,
}) async {
  await HomeWidget.saveWidgetData<int>('remaining', remaining);
  await HomeWidget.saveWidgetData<int>('todaySpent', todaySpent);
  await HomeWidget.saveWidgetData<int>('streakDays', streakDays);
  await HomeWidget.saveWidgetData<String>(
    'lastUpdated',
    DateFormat('HH:mm').format(DateTime.now()),
  );
  await HomeWidget.updateWidget(
    iOSName: 'DailyBudgetWidget',
    androidName: 'DailyBudgetWidgetProvider',
  );
}
```

**iOS**: SwiftUI + WidgetKit (`ios/DailyBudgetWidget/`)
**Android**: RemoteViews XML (`android/app/src/main/res/layout/`)

---

## 5. 카테고리 아이콘 이모지 매핑

### 5.1 기본 카테고리

| 카테고리 | 이모지 | 색상 (배경 칩) | 색상 코드 |
|----------|--------|-------------|----------|
| 식비 | 🍚 | 연한 오렌지 | `#FFF0E0` |
| 교통 | 🚌 | 연한 블루 | `#E8F4FD` |
| 카페 | ☕ | 연한 브라운 | `#F5ECD7` |
| 쇼핑 | 🛍️ | 연한 퍼플 | `#F3E8FD` |
| 편의점 | 🏪 | 연한 그린 | `#E8F8F0` |
| 기타 | 📦 | 연한 그레이 | `#F0F0F0` |

### 5.2 카테고리 칩 컴포넌트

```dart
// 선택된 카테고리 칩: 색상 배경 + 이모지 + 레이블
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: category.backgroundColor,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(category.emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 4),
      Text(category.label, style: labelStyle),
    ],
  ),
)
```

### 5.3 감정 태그 (Could-have)

| 태그 | 이모지 | 의미 |
|------|--------|------|
| 필수 | ✅ | 꼭 필요한 지출 |
| 충동 | ⚡ | 충동 구매 |
| 보상 | 🎁 | 나를 위한 선물 |
| 절약 | 💪 | 아낀 지출 |

---

## 6. 컬러 팔레트

### 6.1 주요 색상

| 이름 | 용도 | 라이트 | 다크 |
|------|------|--------|------|
| Primary | CTA 버튼, 네비게이션 강조 | `#000000` 검정 | `#FFFFFF` 흰색 |
| Budget Comfortable | 여유 상태 숫자 | `#000000` 검정 | `#FFFFFF` 흰색 |
| Budget Warning | 보통 상태 숫자 | `#F5A623` 앰버 | `#F5A623` |
| Budget Danger | 위험 상태 숫자 | `#E85D5D` 코랄 | `#E85D5D` |
| Budget Over | 초과 상태 숫자 | `#C0392B` 딥레드 | `#C0392B` |
| Accent | 수정 스와이프 배경, 보조 링크 | `#4A90D9` 스카이블루 | `#4A90D9` |

### 6.2 뉴트럴 색상

| 이름 | 용도 | 색상 코드 |
|------|------|----------|
| Text Primary | 주 텍스트 | `#1A1A2E` |
| Text Secondary | 보조 텍스트 | `#6B7280` |
| Text Tertiary | 힌트, 플레이스홀더 | `#9CA3AF` |
| Surface | 카드, 시트 배경 | `#FFFFFF` |
| Border | 구분선, 테두리 | `#E5E7EB` |

### 6.3 타이포그래피 스케일

| 레벨 | 용도 | 크기 | 웨이트 |
|------|------|------|--------|
| Display | 메인 금액 숫자 | 44sp 고정 | Black 900 (여유) / ExtraBold 800 (보통) / Bold 700 (위험·초과) |
| Headline | 섹션 제목 | 24sp | Bold 700 |
| Title | 카드 제목 | 18sp | SemiBold 600 |
| Body | 본문 | 16sp | Regular 400 |
| Caption | 보조 정보 | 12sp | Regular 400 |
| Overline | 레이블 | 11sp | Medium 500 |

---

## 7. 화면별 레이아웃 가이드

### 7.1 메인 홈 화면

```
┌─────────────────────────────┐
│  [날짜]         [설정 아이콘] │  ← AppBar, 높이 56
│                             │
│  오늘 남은 금액               │  ← Caption, 중앙 정렬
│                             │
│       ₩7,200                │  ← Display 숫자, 상태 색상
│  + 어제 이월 ₩1,200          │  ← Caption, 보조 색상
│                             │
│  ─────────────────────────  │  ← Divider
│                             │
│  오늘 지출                    │  ← Title
│  [지출 리스트 아이템들]        │
│                             │
└──────── [+ 지출 기록] ───────┘  ← FAB, 검정 원형 (#000000)
```

### 7.2 지출 입력 바텀시트

```
┌─────────────────────────────┐
│         ────                │  ← 드래그 핸들
│  얼마 썼나요?                 │  ← Headline
│                             │
│       ₩0                    │  ← Display, 입력 중 실시간 갱신
│                             │
│  [🍚식비] [🚌교통] [☕카페]   │  ← 카테고리 칩
│  [🛍쇼핑] [🏪편의점] [📦기타] │
│                             │
│  [  1  ][  2  ][  3  ]     │
│  [  4  ][  5  ][  6  ]     │  ← 숫자 키패드
│  [  7  ][  8  ][  9  ]     │
│  [ 00  ][  0  ][ ← ]       │
│                             │
│  [      기록하기      ]      │  ← 확인 버튼, 검정 배경 (#000000)
└─────────────────────────────┘
```

---

## 8. 에셋 구조

### 8.1 파일 네이밍 규칙

```
assets/
├── images/
│   ├── app_icon.png              # 앱 아이콘 (1024x1024)
│   └── empty_state.png           # 빈 상태 일러스트 (미니멀)
├── icons/
│   ├── ic_food.svg               # 카테고리 - 식비
│   ├── ic_transport.svg          # 카테고리 - 교통
│   ├── ic_cafe.svg               # 카테고리 - 카페
│   ├── ic_shopping.svg           # 카테고리 - 쇼핑
│   ├── ic_convenience.svg        # 카테고리 - 편의점
│   └── ic_etc.svg                # 카테고리 - 기타
└── lottie/
    └── confetti_celebration.json  # 스트릭 축하 confetti (LottieFiles)
```

### 8.2 앱 아이콘 컨셉

- **형태**: 원형 배경 + 중앙에 "₩" 또는 "만원" 텍스트
- **배경색**: `#000000` 검정
- **텍스트색**: 흰색
- **스타일**: 미니멀, 볼드 타이포그래피 중심
- **생성 도구**: Recraft AI (SVG) 또는 Figma에서 직접 제작
