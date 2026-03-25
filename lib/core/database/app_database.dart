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

/// 앱 전체에서 사용하는 Drift 데이터베이스 클래스
/// drift_flutter의 driftDatabase()를 사용하여 플랫폼별 DB 연결을 자동 처리
@DriftDatabase(tables: [Expenses, DailyBudgets, Acorns, Achievements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

/// 플랫폼에 맞는 데이터베이스 연결을 생성
/// drift_flutter가 iOS/Android/Desktop 환경을 자동으로 판별
QueryExecutor _openConnection() {
  return driftDatabase(name: 'daily_manwon');
}
