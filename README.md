# 하루 만원 (Daily Manwon)

하루 1만원 예산 관리 앱. 숫자 자체가 감정을 표현하는 미니멀 디자인.
도토리(acorn) 보상 시스템과 업적(achievement) 기능 포함.

---

## 개발 환경 (2026-04-11 기준)

| 항목    | 버전            |
| ------- | --------------- |
| Flutter | 3.41.5 (stable) |
| Dart    | 3.11.3          |

---

## 환경 설정 (새 맥에서 시작할 때)

### 1. Flutter SDK 설치

```bash
# Homebrew로 설치 (권장)
brew install --cask flutter

# 또는 공식 사이트에서 직접 다운로드
# https://docs.flutter.dev/get-started/install/macos
```

설치 후 환경 변수 설정 (`~/.zshrc`에 추가):

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

### 2. 의존성 도구 설치

```bash
# Xcode (App Store에서 설치 후 커맨드라인 도구 설정)
xcode-select --install
sudo xcodebuild -license accept

# CocoaPods (iOS 빌드에 필요)
sudo gem install cocoapods

# Android Studio (Android 개발 시)
brew install --cask android-studio
```

### 3. 환경 확인

```bash
flutter doctor
```

모든 항목에 `[✓]` 표시되면 준비 완료.

---

## 프로젝트 설정

```bash
# 저장소 클론
git clone https://github.com/seong9566/Daily_manwon.git
cd Daily_manwon

# 패키지 설치
flutter pub get

# 코드 생성 (freezed / injectable / drift / riverpod)
dart run build_runner build --delete-conflicting-outputs

# 앱 실행
flutter run
```

---

## 주요 명령어

```bash
# 앱 실행
flutter run

# 코드 생성 (소스 변경 후 반드시 실행)
dart run build_runner build --delete-conflicting-outputs

# 코드 생성 감시 모드
dart run build_runner watch --delete-conflicting-outputs

# 정적 분석
flutter analyze

# 테스트 전체 실행
flutter test

# 클린 재빌드
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

---

## 프로젝트 구조

```
lib/
├── core/               # 공유 인프라
│   ├── constants/      # AppConstants, ExpenseCategory, CharacterMood
│   ├── database/       # Drift (SQLite) — AppDatabase
│   ├── di/             # GetIt + Injectable DI
│   ├── router/         # GoRouter (bottom nav)
│   ├── theme/          # AppColors, AppTypography, AppTheme
│   └── utils/          # 유틸리티
├── features/
│   ├── home/           # 메인 화면 (잔액, 지출, 도토리, 스트릭)
│   ├── calendar/       # 월별 캘린더
│   ├── settings/       # 설정 (예산, 이월, 알림, 다크모드)
│   ├── achievement/    # 업적 시스템
│   ├── expense/        # 지출 입력 바텀시트
│   └── onboarding/     # 온보딩
```

각 feature는 `data → domain → presentation` Clean Architecture 구조를 따른다.

---

## 기술 스택

- **상태 관리**: flutter_riverpod 3.x + riverpod_annotation 4.x
- **DI**: GetIt + Injectable
- **DB**: Drift (SQLite) — Expenses, DailyBudgets, Acorns, Achievements 테이블
- **모델**: freezed (불변 엔티티)
- **라우팅**: GoRouter (`StatefulShellRoute.indexedStack`)
- **애니메이션**: flutter_animate
- **폰트**: Pretendard
