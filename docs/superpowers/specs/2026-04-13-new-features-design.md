# Daily Manwon — 신규 기능 설계 스펙

**작성일**: 2026-04-13  
**범위**: 편의성 개선 + 인사이트 기능 추가 (풀 패키지)  
**우선순위**: 편의성(C) → 인사이트(B)

---

## 1. 템플릿 + 빠른 반복 입력

### 목적

반복 지출(매일 커피, 버스 등)을 탭 한 번으로 입력할 수 있도록 한다.

### 기능 설명

#### 1-1. 자동학습 템플릿

- 최근 30일 지출을 `(금액, 카테고리)` 기준 `GROUP BY` 집계 → 빈도 상위 3개 자동 추출
- 지출 입력 바텀시트 하단 영역에 "자주 쓰는 항목" 칩으로 표시
- 칩 탭 시 금액 + 카테고리 자동 채움 → "저장"만 누르면 완료
- **새 테이블 없음** — 기존 `Expenses` 테이블 집계 쿼리로 동작

#### 1-2. 수동 Favorite (고정 즐겨찾기)

- 지출 저장 시 "즐겨찾기에 추가" 체크박스로 수동 등록
- 바텀시트 상단에 **고정 즐겨찾기(수동)** 먼저, 그 아래 **자동학습 추천** 표시
- 수동 즐겨찾기는 `usageCount` 내림차순 정렬, 최대 10개 (초과 시 가로 스크롤)
- 자동학습과 수동 즐겨찾기가 중복될 경우 수동 즐겨찾기 우선 표시 (중복 제거)

#### 1-3. 빠른 반복 입력

- 홈 화면 지출 목록 각 항목에 **↩ 반복** 버튼 추가
- 탭 시 현재 시각으로 동일 금액/카테고리/메모의 새 지출 즉시 저장 (확인 다이얼로그 없음)

### 데이터 모델

```
// 신규 테이블: FavoriteExpenses (Drift) — 수동 즐겨찾기 전용
id         INTEGER PRIMARY KEY
amount     INTEGER NOT NULL
category   TEXT NOT NULL        -- ExpenseCategory enum 값
memo       TEXT
usageCount INTEGER DEFAULT 0
createdAt  DATETIME NOT NULL

// 자동학습: Expenses 테이블 집계 쿼리 (테이블 변경 없음)
SELECT amount, category, COUNT(*) AS frequency
FROM expenses
WHERE created_at >= [30일 전]
GROUP BY amount, category
ORDER BY frequency DESC
LIMIT 3
```

### UX 규칙

- 수동 즐겨찾기 + 자동학습 모두 0개일 때는 템플릿 섹션 미표시
- ↩ 반복 후 홈 화면 잔액/목록 즉시 리프레시 (기존 Riverpod 상태 갱신 방식 그대로)

---

## 2. 홈 위젯

### 목적

앱을 열지 않고도 잔액 확인 및 즐겨찾기 빠른 입력이 가능하도록 한다.

### 위젯 종류

| 크기       | 내용                                                                    |
| ---------- | ----------------------------------------------------------------------- |
| 소형 (2×2) | 앱 타이틀 + 스트릭 뱃지, 남은 예산, 고양이 캐릭터, 진행 바, 상태 메시지 |
| 중형 (4×2) | 총 예산, 남은/사용 예산, 고양이 캐릭터, 진행 바, 상태 메시지            |
| 대형 (4×4) | 중형 내용 + 즐겨찾기 빠른 입력 버튼 4개                                 |

### 디자인 기준

- 배경색 `#FFFFFF`, 텍스트 `#3D3D3D` / `#8E8E8E` — 현행 앱과 동일
- 스트릭 뱃지: 🔥 + 일수, 배경 `#FFF0E0`, 텍스트 `#F5A623`
- 진행 바: 트랙 `#F0E8E0`, 채움 `#F5A623`
- 남은 예산 금액: 잔액 비율에 따라 색상 변경 (`comfortable` → `#3D3D3D`, `warning` → `#F5A623`, `danger` / `over` → `#E85D5D`)

### 고양이 캐릭터

잔액 비율에 따라 `CharacterMood` enum과 동일 기준으로 PNG 4종 자동 교체:

| 상태 | 조건             | 파일             |
| ---- | ---------------- | ---------------- |
| 여유 | 잔액 > 70%       | `여유_clean.png` |
| 보통 | 30% < 잔액 ≤ 70% | `보통_clean.png` |
| 위험 | 0% < 잔액 ≤ 30%  | `위험_clean.png` |
| 초과 | 잔액 ≤ 0%        | `초과_clean.png` |

### 기술 구현

- **패키지**: `home_widget 0.6.0` (iOS WidgetKit + Android AppWidget 통합)
- **데이터 동기화**: 지출 추가/삭제/수정 시 `HomeWidget.saveWidgetData()` 호출 → 위젯 리렌더
- **빠른 입력 (대형) — 앱 열지 않고 백그라운드 저장 가능**:

  **iOS 실행 흐름** (`openAppWhenRun = false`, Widget Extension 프로세스에서 실행):

  ```
  위젯 버튼 탭
    → AppIntent.perform() [Widget Extension 프로세스]
    → HomeWidgetBackgroundWorker.run(url:appGroup:)
    → Flutter 백그라운드 isolate 실행
    → Drift DB 저장 (App Group 경로)
    → WidgetCenter.shared.reloadAllTimelines()
  ```

  **Android 실행 흐름** (BroadcastReceiver 기반):

  ```
  위젯 버튼 탭
    → PendingIntent → HomeWidgetBackgroundReceiver
    → Flutter 헤드리스 엔진 초기화
    → Dart backgroundCallback 실행
    → SQLite 쓰기 (10초 제한 내)
  ```

  **Dart 콜백 등록** (`@pragma` 어노테이션 필수 — 없으면 릴리즈 빌드에서 tree shaking으로 제거됨):

  ```dart
  @pragma('vm:entry-point')
  FutureOr<void> backgroundCallback(Uri? data) async {
    // 앱 열지 않고 Drift DB 저장
  }
  HomeWidget.registerInteractivityCallback(backgroundCallback);
  ```

- **플랫폼 버전 요건**:
  - iOS: **17.0 이상** (현 앱 `IPHONEOS_DEPLOYMENT_TARGET = 17.0` — 이미 충족, fallback 불필요)
  - Android: API 21 이상 (위젯 클릭 PendingIntent는 Android 12+ 백그라운드 제한 예외 적용)
- **전제 조건**: Drift DB가 App Group 컨테이너(`group.com.xxx.dailyManwon`)에 위치해야 함 — 기존 계획서(`2026-04-13-quick-expense-recording.md`) Task 2 참조
- **실행 시간 제한**: iOS 수 초 이내 (Apple 비공개), Android BroadcastReceiver 10초 이내 (초과 시 WorkManager 위임)
- **네이티브 번들링**: 고양이 PNG 4장을 iOS (`Runner/Assets.xcassets`) 및 Android (`res/drawable`) 양쪽에 포함

### 기존 계획서와의 관계

`docs/superpowers/plans/2026-04-13-quick-expense-recording.md`의 Task 2(위젯 프리셋)를 기반으로 확장:

- 기존: 소형 + 중형 위젯
- 추가: 대형 위젯 (4×4), 고양이 캐릭터 PNG 연동

### 데이터 모델 변경 없음

위젯은 기존 `DailyBudgets`, `Expenses`, `UserPreferences` 테이블 읽기 전용으로 사용.

---

## 3. 인사이트 / 분석

### 목적

소비 패턴을 시각화하여 사용자가 지출 습관을 파악할 수 있도록 한다.

### 3-1. 카테고리별 소비 도넛 차트 (우선순위 1)

- **진입**: 캘린더 화면 상단 탭 ("통계" 탭 추가)
- **내용**: 선택 월의 카테고리별 지출 비율 도넛 차트 + 범례
- **색상**: 기존 `AppColors.category*` 토큰 그대로 사용
- **인터랙션**: 월 선택 가능 (캘린더와 동일한 월 선택기 재사용)

### 3-2. 요일별 소비 패턴 바 차트 (우선순위 2)

- **내용**: 최근 4주 기준 요일별 평균 지출 바 차트
- **하이라이트**: 오늘 요일 `#F5A623` 강조
- **인사이트 메시지**: 지출이 가장 높은 요일 자동 감지 → 한 줄 메시지 ("금·토에 지출이 집중되는 편이에요")
- **위치**: 카테고리 차트 아래 동일 통계 탭

### 3-3. 주간/월간 요약 리포트 (우선순위 3)

- **진입**: 캘린더 탭 하단 "요약 보기" 버튼 → 바텀 시트
- **별도 화면 없음** — 모달 시트로 표시
- **주간 내용**: 총 지출, 예산 달성일 수, 가장 많은 카테고리
- **월간 내용**: 총 지출, 예산 달성일 수, 가장 많은 카테고리

### 데이터 모델 변경 없음

기존 `Expenses`, `DailyBudgets` 테이블 집계 쿼리로 계산.

---

## 구현 순서 (권장)

1. **자동학습 + 수동 Favorite 템플릿 + 빠른 반복** — DB 변경 최소(`FavoriteExpenses` 1개), 즉각적인 체감 효과
2. **인사이트 (카테고리 차트 → 요일 패턴 → 요약 리포트)** — DB 변경 없음, UI만 추가
3. **홈 위젯** — 네이티브 플랫폼 작업 필요, 별도 스프린트 권장

---

## 영향 범위 요약

| 항목        | 변경 유형                                                                            |
| ----------- | ------------------------------------------------------------------------------------ |
| DB 스키마   | `FavoriteExpenses` 테이블 신규 추가 (마이그레이션 필요), 자동학습은 기존 테이블 집계 |
| 기존 테이블 | 변경 없음                                                                            |
| 신규 화면   | 캘린더 내 "통계" 탭                                                                  |
| 변경 화면   | 지출 입력 바텀시트, 홈 화면 지출 목록                                                |
| 네이티브    | iOS WidgetKit, Android AppWidget 각 1개 추가                                         |
| 패키지 추가 | `home_widget`                                                                        |
