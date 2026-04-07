import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// 지출 내역 테이블
/// - category는 ExpenseCategory enum의 index 값으로 저장
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()(); // 금액 (원)
  IntColumn get category => integer()(); // ExpenseCategory enum index
  TextColumn get memo => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

/// 일별 예산 테이블
/// - date는 unique 제약으로 하루에 하나의 예산만 존재
/// - carryOver: 전날 절약한 금액이 이월된 값
class DailyBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  IntColumn get baseAmount =>
      integer().withDefault(const Constant(10000))(); // 기본 1만원
  IntColumn get carryOver =>
      integer().withDefault(const Constant(0))(); // 이월 금액
}

/// 도토리 테이블
/// - 절약 달성 시 획득하는 보상 단위
class Acorns extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get count => integer()();
  TextColumn get reason => text()(); // 도토리 획득 사유
}

/// 업적 테이블
/// - 특정 조건 달성 시 기록되는 업적 데이터
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 업적 타입 식별자
  DateTimeColumn get achievedAt => dateTime()();
}

/// 사용자 설정 테이블
/// - 다크모드, 알림 등 앱 설정을 단일 row로 저장
/// - id=1 고정 (앱당 하나의 설정 row만 존재)
class UserPreferences extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get isDarkMode =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isOnboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 알림 설정 테이블
/// - 점심/저녁 알림 활성화 여부 및 시간을 단일 row로 저장
/// - id=1 고정 (앱당 하나의 설정 row만 존재)
/// - 시간은 'HH:mm' 형식의 문자열로 저장 (TimeOfDay 직렬화 불가)
class NotificationSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get lunchEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get lunchTime =>
      text().withDefault(const Constant('12:00'))(); // 기본 12:00
  BoolColumn get dinnerEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get dinnerTime =>
      text().withDefault(const Constant('20:00'))(); // 기본 20:00

  @override
  Set<Column> get primaryKey => {id};
}

/// 앱 전체에서 사용하는 Drift 데이터베이스 클래스
/// drift_flutter의 driftDatabase()를 사용하여 플랫폼별 DB 연결을 자동 처리
@DriftDatabase(tables: [
  Expenses,
  DailyBudgets,
  Acorns,
  Achievements,
  UserPreferences,
  NotificationSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // schema v2: UserPreferences 테이블 추가
          if (from < 2) {
            await m.createTable(userPreferences);
          }
          // schema v3: NotificationSettings 테이블 추가
          if (from < 3) {
            await m.createTable(notificationSettings);
          }
          // schema v4: isOnboardingCompleted 컬럼 추가
          if (from < 4) {
            await m.addColumn(
                userPreferences, userPreferences.isOnboardingCompleted);
          }
        },
      );
}

/// 플랫폼에 맞는 데이터베이스 연결을 생성
/// drift_flutter가 iOS/Android/Desktop 환경을 자동으로 판별
QueryExecutor _openConnection() {
  return driftDatabase(name: 'daily_manwon');
}
