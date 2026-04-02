# 하루 만원 살기 플래너 - 위젯 색상 가이드

iOS (Swift) 및 Android (Kotlin Compose) 홈 스크린 위젯 개발을 위한 색상 및 스타일 가이드입니다.

---

## 📋 목차

1. [상태별 색상 정의](#상태별-색상-정의)
   - [여유 상태 (Comfortable)](#여유-상태-comfortable)
   - [빠듯 상태 (Tight)](#빠듯-상태-tight) 
   - [초과 상태 (Exceeded)](#초과-상태-exceeded)
2. [타이포그래피 가이드](#타이포그래피-가이드)
3. [Swift 구현 예제](#swift-구현-예제)
4. [Kotlin Compose 구현 예제](#kotlin-compose-구현-예제)

---

## 상태별 색상 정의

### 여유 상태 (Comfortable)
> **조건**: 남은 금액 ₩5,000 이상

#### Background (배경색)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#F1F5F9` |
| **RGB** | `rgb(241, 245, 249)` |
| **Swift** | `Color(red: 241/255, green: 245/255, blue: 249/255)` |
| **Compose** | `Color(0xFFF1F5F9)` |
| **Gradient** | `#F8FAFC` → `#F1F5F9` |

#### Primary Text (금액, 제목)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#0F172A` |
| **RGB** | `rgb(15, 23, 42)` |
| **Swift** | `Color(red: 15/255, green: 23/255, blue: 42/255)` |
| **Compose** | `Color(0xFF0F172A)` |

#### Secondary Text (라벨, 설명)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#475569` |
| **RGB** | `rgb(71, 85, 105)` |
| **Swift** | `Color(red: 71/255, green: 85/255, blue: 105/255)` |
| **Compose** | `Color(0xFF475569)` |

#### Accent Background (스트릭 배지)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#E2E8F0` |
| **RGB** | `rgb(226, 232, 240)` |
| **Swift** | `Color(red: 226/255, green: 232/255, blue: 240/255)` |
| **Compose** | `Color(0xFFE2E8F0)` |

---

### 빠듯 상태 (Tight)
> **조건**: 남은 금액 ₩1 ~ ₩4,999

#### Background (배경색)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#FEF3C7` |
| **RGB** | `rgb(254, 243, 199)` |
| **Swift** | `Color(red: 254/255, green: 243/255, blue: 199/255)` |
| **Compose** | `Color(0xFFFEF3C7)` |
| **Gradient** | `#FFFBEB` → `#FEF3C7` |

#### Primary Text (금액, 제목)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#78350F` |
| **RGB** | `rgb(120, 53, 15)` |
| **Swift** | `Color(red: 120/255, green: 53/255, blue: 15/255)` |
| **Compose** | `Color(0xFF78350F)` |

#### Secondary Text (라벨, 설명)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#C2410C` |
| **RGB** | `rgb(194, 65, 12)` |
| **Swift** | `Color(red: 194/255, green: 65/255, blue: 12/255)` |
| **Compose** | `Color(0xFFC2410C)` |

#### Accent Background (스트릭 배지)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#FED7AA` |
| **RGB** | `rgb(254, 215, 170)` |
| **Swift** | `Color(red: 254/255, green: 215/255, blue: 170/255)` |
| **Compose** | `Color(0xFFFED7AA)` |

---

### 초과 상태 (Exceeded)
> **조건**: 남은 금액 ₩0 미만 (초과)

#### Background (배경색)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#FEE2E2` |
| **RGB** | `rgb(254, 226, 226)` |
| **Swift** | `Color(red: 254/255, green: 226/255, blue: 226/255)` |
| **Compose** | `Color(0xFFFEE2E2)` |
| **Gradient** | `#FEF2F2` → `#FEE2E2` |

#### Primary Text (금액, 제목)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#B91C1C` |
| **RGB** | `rgb(185, 28, 28)` |
| **Swift** | `Color(red: 185/255, green: 28/255, blue: 28/255)` |
| **Compose** | `Color(0xFFB91C1C)` |

#### Secondary Text (라벨, 설명)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#DC2626` |
| **RGB** | `rgb(220, 38, 38)` |
| **Swift** | `Color(red: 220/255, green: 38/255, blue: 38/255)` |
| **Compose** | `Color(0xFFDC2626)` |

#### Accent Background (스트릭 배지 or 초과 알림)
| 플랫폼 | 코드 |
|--------|------|
| **HEX** | `#FECACA` |
| **RGB** | `rgb(254, 202, 202)` |
| **Swift** | `Color(red: 254/255, green: 202/255, blue: 202/255)` |
| **Compose** | `Color(0xFFFECACA)` |

---

## 타이포그래피 가이드

### Small 위젯 (2×2)

| 요소 | 폰트 크기 | 폰트 굵기 |
|------|-----------|-----------|
| 남은 예��� 라벨 | 12pt | Medium (500) |
| 금액 (여유 상태) | 36pt | Bold (700) |
| 금액 (빠듯 상태) | 30pt | Bold (700) |
| 금액 (초과 상태) | 24pt | Bold (700) |
| "초과!" 라벨 | 12pt | Medium (500) |

### Medium 위젯 (4×2)

| 요소 | 폰트 크기 | 폰트 굵기 |
|------|-----------|-----------|
| 날짜 | 12pt | Medium (500) |
| 남은 예산 라벨 | 12pt | Medium (500) |
| 금액 (여유 상태) | 48pt | Bold (700) |
| 금액 (빠듯 상태) | 40pt | Bold (700) |
| 금액 (초과 상태) | 32pt | Bold (700) |
| 스트릭 일수 | 12pt | Semibold (600) |
| 오늘 지출 | 12pt | Regular (400) |

### Large 위젯 (4×4)

| 요소 | 폰트 크기 | 폰트 굵기 |
|------|-----------|-----------|
| 날짜 | 12pt | Medium (500) |
| 남은 예산 라벨 | 12pt | Medium (500) |
| 금액 (여유 상태) | 56pt | Bold (700) |
| 금액 (빠듯 상태) | 48pt | Bold (700) |
| 금액 (초과 상태) | 40pt | Bold (700) |
| "오늘의 지출" 섹션 제목 | 12pt | Medium (500) |
| 지출 카테고리명 | 14pt | Medium (500) |
| 지출 금액 | 14pt | Bold (700) |
| 지출 시간 | 12pt | Regular (400) |

---

## Swift 구현 예제

### WidgetColors.swift

```swift
import SwiftUI

enum WidgetStatus {
    case comfortable
    case tight
    case exceeded
}

struct WidgetColors {
    let background: Color
    let primaryText: Color
    let secondaryText: Color
    let accentBg: Color
    
    static func colors(for status: WidgetStatus) -> WidgetColors {
        switch status {
        case .comfortable:
            return WidgetColors(
                background: Color(red: 241/255, green: 245/255, blue: 249/255),
                primaryText: Color(red: 15/255, green: 23/255, blue: 42/255),
                secondaryText: Color(red: 71/255, green: 85/255, blue: 105/255),
                accentBg: Color(red: 226/255, green: 232/255, blue: 240/255)
            )
        case .tight:
            return WidgetColors(
                background: Color(red: 254/255, green: 243/255, blue: 199/255),
                primaryText: Color(red: 120/255, green: 53/255, blue: 15/255),
                secondaryText: Color(red: 194/255, green: 65/255, blue: 12/255),
                accentBg: Color(red: 254/255, green: 215/255, blue: 170/255)
            )
        case .exceeded:
            return WidgetColors(
                background: Color(red: 254/255, green: 226/255, blue: 226/255),
                primaryText: Color(red: 185/255, green: 28/255, blue: 28/255),
                secondaryText: Color(red: 220/255, green: 38/255, blue: 38/255),
                accentBg: Color(red: 254/255, green: 202/255, blue: 202/255)
            )
        }
    }
    
    static func fontSize(for status: WidgetStatus, widgetSize: WidgetSize) -> CGFloat {
        switch (widgetSize, status) {
        case (.small, .comfortable):
            return 36
        case (.small, .tight):
            return 30
        case (.small, .exceeded):
            return 24
        case (.medium, .comfortable):
            return 48
        case (.medium, .tight):
            return 40
        case (.medium, .exceeded):
            return 32
        case (.large, .comfortable):
            return 56
        case (.large, .tight):
            return 48
        case (.large, .exceeded):
            return 40
        }
    }
}

enum WidgetSize {
    case small
    case medium
    case large
}
```

### 사용 예제 (SmallWidget.swift)

```swift
import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let remainingAmount: Int
    let status: WidgetStatus
    
    var body: some View {
        let colors = WidgetColors.colors(for: status)
        let fontSize = WidgetColors.fontSize(for: status, widgetSize: .small)
        
        ZStack {
            colors.background
            
            VStack(spacing: 8) {
                Text("남은 예산")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                
                Text("₩\(remainingAmount.formatted())")
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(colors.primaryText)
                
                if status == .exceeded {
                    Text("초과!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                }
            }
        }
        .containerBackground(for: .widget) {
            colors.background
        }
    }
}
```

---

## Kotlin Compose 구현 예제

### WidgetColors.kt

```kotlin
import androidx.compose.ui.graphics.Color

enum class WidgetStatus {
    COMFORTABLE,
    TIGHT,
    EXCEEDED
}

data class WidgetColors(
    val background: Color,
    val primaryText: Color,
    val secondaryText: Color,
    val accentBg: Color
)

enum class WidgetSize {
    SMALL,
    MEDIUM,
    LARGE
}

object WidgetTheme {
    fun getColors(status: WidgetStatus): WidgetColors {
        return when (status) {
            WidgetStatus.COMFORTABLE -> WidgetColors(
                background = Color(0xFFF1F5F9),
                primaryText = Color(0xFF0F172A),
                secondaryText = Color(0xFF475569),
                accentBg = Color(0xFFE2E8F0)
            )
            WidgetStatus.TIGHT -> WidgetColors(
                background = Color(0xFFFEF3C7),
                primaryText = Color(0xFF78350F),
                secondaryText = Color(0xFFC2410C),
                accentBg = Color(0xFFFED7AA)
            )
            WidgetStatus.EXCEEDED -> WidgetColors(
                background = Color(0xFFFEE2E2),
                primaryText = Color(0xFFB91C1C),
                secondaryText = Color(0xFFDC2626),
                accentBg = Color(0xFFFECACA)
            )
        }
    }
    
    fun getFontSize(status: WidgetStatus, widgetSize: WidgetSize): Int {
        return when (widgetSize to status) {
            WidgetSize.SMALL to WidgetStatus.COMFORTABLE -> 36
            WidgetSize.SMALL to WidgetStatus.TIGHT -> 30
            WidgetSize.SMALL to WidgetStatus.EXCEEDED -> 24
            WidgetSize.MEDIUM to WidgetStatus.COMFORTABLE -> 48
            WidgetSize.MEDIUM to WidgetStatus.TIGHT -> 40
            WidgetSize.MEDIUM to WidgetStatus.EXCEEDED -> 32
            WidgetSize.LARGE to WidgetStatus.COMFORTABLE -> 56
            WidgetSize.LARGE to WidgetStatus.TIGHT -> 48
            WidgetSize.LARGE to WidgetStatus.EXCEEDED -> 40
            else -> 24
        }
    }
}
```

### 사용 예제 (SmallWidget.kt)

```kotlin
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.text.Text
import androidx.glance.text.TextStyle

@Composable
fun SmallWidget(
    remainingAmount: Int,
    status: WidgetStatus
) {
    val colors = WidgetTheme.getColors(status)
    val fontSize = WidgetTheme.getFontSize(status, WidgetSize.SMALL)
    
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(colors.background),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "남은 예산",
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = colors.secondaryText
                )
            )
            
            Text(
                text = "₩${String.format("%,d", remainingAmount)}",
                style = TextStyle(
                    fontSize = fontSize.sp,
                    fontWeight = FontWeight.Bold,
                    color = colors.primaryText
                )
            )
            
            if (status == WidgetStatus.EXCEEDED) {
                Text(
                    text = "초과!",
                    style = TextStyle(
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = colors.secondaryText
                    )
                )
            }
        }
    }
}
```

---

## 애니메이션 가이드

### iOS (SwiftUI)

**빠듯 상태 미세 떨림 효과**
```swift
.modifier(ShakeEffect(animatableData: status == .tight ? 1 : 0))

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(animatableData * .pi * 2) * 2, y: 0))
    }
}
```

**숫자 카운트다운 애니메이션**
```swift
@State private var displayedAmount: Int = 10000

Text("₩\(displayedAmount)")
    .animation(.easeOut(duration: 0.5), value: displayedAmount)
```

### Android (Compose)

**빠듯 상태 미세 떨림 효과**
```kotlin
val infiniteTransition = rememberInfiniteTransition()
val shake by infiniteTransition.animateFloat(
    initialValue = -2f,
    targetValue = 2f,
    animationSpec = infiniteRepeatable(
        animation = tween(100, easing = LinearEasing),
        repeatMode = RepeatMode.Reverse
    )
)

if (status == WidgetStatus.TIGHT) {
    Modifier.offset(x = shake.dp)
}
```

**숫자 카운트다운 애니메이션**
```kotlin
var displayedAmount by remember { mutableStateOf(10000) }

AnimatedContent(targetState = displayedAmount) { amount ->
    Text(text = "₩${String.format("%,d", amount)}")
}
```

---

## 추가 리소스

### 라운드 처리
- **위젯 모서리**: 24dp / 24pt (rounded-3xl)
- **내부 카드**: 16dp / 16pt (rounded-xl)
- **배지**: 12dp / 12pt (rounded-full)

### 그림자 (Shadow)
```swift
// Swift
.shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
```

```kotlin
// Kotlin Compose
modifier = Modifier.shadow(
    elevation = 4.dp,
    shape = RoundedCornerShape(24.dp)
)
```

### 아이콘
- 🔥 스트릭 (연속 성공일)
- 🍚 식비
- ☕ 카페
- 🚗 교통
- 🛍️ 쇼핑
- 🍪 간식

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-04-01  
**작성자**: 하루 만원 살기 플래너 개발팀
