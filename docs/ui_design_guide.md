## UI 디자인 가이드: 심플 미니멀 UI + 숫자 감정 표현

**Date**: 2026-03-25
**Status**: 초안
**컨셉**: 숫자 자체가 감정을 표현하는 미니멀 앱

---

### 디자인 원칙

1. **숫자가 주인공**: 남은 금액 숫자가 크기·색상·모션으로 감정을 전달
2. **미니멀 레이아웃**: 불필요한 장식 제거, 핵심 정보만 화면에
3. **마이크로 인터랙션**: 모든 인터랙션에 의미 있는 피드백 제공
4. **시간대 반응**: 배경 톤이 하루의 흐름을 자연스럽게 반영

---

## 1. 숫자 감정 표현 스펙

### 1.1 남은 금액 숫자 상태 정의

| 상태 | 조건 | 의미 |
|------|------|------|
| **여유** | 잔액 ≥ 5,000원 | 오늘 잘 하고 있음 |
| **주의** | 1,000원 ≤ 잔액 < 5,000원 | 아껴써야 할 시점 |
| **위험** | 잔액 < 1,000원 | 거의 다 씀 |
| **초과** | 잔액 < 0원 | 예산 초과 |

### 1.2 상태별 타이포그래피 스펙

| 상태 | 폰트 크기 | 폰트 웨이트 | 색상 | 색상 코드 |
|------|----------|-----------|------|----------|
| 여유 | 72sp | Black (900) | 민트 그린 | `#2DBD8E` |
| 주의 | 60sp | ExtraBold (800) | 앰버 오렌지 | `#F5A623` |
| 위험 | 52sp | Bold (700) | 코랄 레드 | `#E85D5D` |
| 초과 | 48sp | Bold (700) | 딥 레드 | `#C0392B` |

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

## 2. 시간대별 배경 톤 스펙

### 2.1 시간 구간 및 색상

| 시간대 | 구간 | 배경색 | 색상 코드 | 분위기 |
|--------|------|--------|----------|--------|
| 새벽 | 00:00 ~ 04:59 | 딥 블루그레이 | `#1A1D2E` | 고요함 |
| 아침 | 05:00 ~ 08:59 | 따뜻한 크림 | `#FFF8E7` | 상쾌한 시작 |
| 오전 | 09:00 ~ 11:59 | 밝은 화이트 | `#F8F9FA` | 집중 |
| 점심 | 12:00 ~ 13:59 | 연한 민트 화이트 | `#F0FAF6` | 활기 |
| 오후 | 14:00 ~ 16:59 | 밝은 화이트 | `#F8F9FA` | 집중 |
| 저녁 | 17:00 ~ 20:59 | 따뜻한 앰버 | `#FFF3E0` | 하루 마무리 |
| 밤 | 21:00 ~ 23:59 | 차분한 블루그레이 | `#EEF0F8` | 휴식 |

### 2.2 텍스트 색상 (배경 대비)

| 시간대 | 주 텍스트 | 보조 텍스트 |
|--------|----------|-----------|
| 새벽 (다크) | `#FFFFFF` | `#A0A8C0` |
| 나머지 (라이트) | `#1A1A2E` | `#6B7280` |

### 2.3 구현 코드

```dart
Color _getBackgroundColor(int hour) {
  if (hour >= 0 && hour < 5)   return const Color(0xFF1A1D2E);  // 새벽
  if (hour >= 5 && hour < 9)   return const Color(0xFFFFF8E7);  // 아침
  if (hour >= 9 && hour < 12)  return const Color(0xFFF8F9FA);  // 오전
  if (hour >= 12 && hour < 14) return const Color(0xFFF0FAF6);  // 점심
  if (hour >= 14 && hour < 17) return const Color(0xFFF8F9FA);  // 오후
  if (hour >= 17 && hour < 21) return const Color(0xFFFFF3E0);  // 저녁
  return const Color(0xFFEEF0F8);                                // 밤
}

// 전환: 매 분마다 체크, AnimatedContainer로 자연스럽게
AnimatedContainer(
  duration: const Duration(seconds: 3),
  curve: Curves.easeInOut,
  color: _getBackgroundColor(DateTime.now().hour),
  child: child,
)
```

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
| 색상 | 민트 그린 `#2DBD8E` |

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
| 파티클 색상 | `[#2DBD8E, #F5A623, #E85D5D, #4A90D9]` |
| 발사 각도 | 상단 중앙 → 180° 확산 |

```dart
ConfettiWidget(
  confettiController: _confettiController,
  blastDirectionality: BlastDirectionality.explosive,
  numberOfParticles: 30,
  colors: const [
    Color(0xFF2DBD8E),
    Color(0xFFF5A623),
    Color(0xFFE85D5D),
    Color(0xFF4A90D9),
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

| 이름 | 용도 | 색상 코드 |
|------|------|----------|
| Primary Green | 여유 상태, 성공, CTA 버튼 | `#2DBD8E` |
| Amber Orange | 주의 상태, 경고 | `#F5A623` |
| Coral Red | 위험 상태, 에러 | `#E85D5D` |
| Deep Red | 초과 상태 | `#C0392B` |
| Sky Blue | 보조 액센트, 링크 | `#4A90D9` |

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
| Display | 메인 금액 숫자 | 48~72sp | Black 900 |
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
└──────── [+ 지출 기록] ───────┘  ← FAB, Primary Green
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
│  [      기록하기      ]      │  ← 확인 버튼, Primary Green
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
- **배경색**: Primary Green `#2DBD8E`
- **텍스트색**: 흰색
- **스타일**: 미니멀, 볼드 타이포그래피 중심
- **생성 도구**: Recraft AI (SVG) 또는 Figma에서 직접 제작
