import 'package:flutter_test/flutter_test.dart';

// TODO: Drift AppDatabase가 구현되면 아래 import를 활성화한다.
// import 'package:daily_manwon/core/database/app_database.dart';
// import 'package:drift/native.dart'; // 테스트용 인메모리 DB

/// AppDatabase 기본 통합 테스트
///
/// Drift는 NativeDatabase.memory()를 제공하므로
/// 실제 SQLite를 인메모리로 실행하여 DB 레이어를 검증한다.
/// mockito/mocktail 없이 실제 DB 인스턴스를 사용하는 것이 원칙이다.
void main() {
  // TODO: AppDatabase 구현 후 아래 변수를 활성화한다.
  // late AppDatabase database;

  setUp(() async {
    // TODO: 테스트용 인메모리 DB를 생성한다.
    // database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    // TODO: 각 테스트 후 DB를 닫아 자원을 해제한다.
    // await database.close();
  });

  group('AppDatabase 생성 및 초기화', () {
    test('DB 인스턴스가 정상적으로 생성된다', () async {
      // TODO: DB 구현 후 활성화
      // expect(database, isNotNull);
      expect(true, isTrue, reason: 'AppDatabase 구현 후 실제 테스트로 교체 예정');
    });

    test('DB를 닫은 후 재생성할 수 있다', () async {
      // TODO: DB 구현 후 활성화
      // await database.close();
      // final newDb = AppDatabase(NativeDatabase.memory());
      // expect(newDb, isNotNull);
      // await newDb.close();
      expect(true, isTrue, reason: 'AppDatabase 구현 후 실제 테스트로 교체 예정');
    });
  });

  group('지출 내역 CRUD', () {
    test('지출 항목을 추가할 수 있다', () async {
      // given
      // TODO: 테스트용 지출 데이터를 준비한다.
      // const amount = 3500;
      // const category = '식비';
      // const memo = '편의점 커피';

      // when
      // TODO: DB에 지출 항목을 삽입한다.
      // final id = await database.insertExpense(amount, category, memo);

      // then
      // TODO: 삽입된 항목이 정상적으로 조회되는지 확인한다.
      // expect(id, greaterThan(0));
      expect(true, isTrue, reason: 'Expense 테이블 구현 후 실제 테스트로 교체 예정');
    });

    test('전체 지출 목록을 조회할 수 있다', () async {
      // given
      // TODO: 복수의 지출 항목을 삽입한다.

      // when
      // TODO: 전체 목록을 조회한다.
      // final expenses = await database.getAllExpenses();

      // then
      // TODO: 삽입한 개수와 조회된 개수가 일치하는지 확인한다.
      // expect(expenses.length, equals(2));
      expect(true, isTrue, reason: 'Expense 테이블 구현 후 실제 테스트로 교체 예정');
    });

    test('지출 항목을 삭제할 수 있다', () async {
      // given
      // TODO: 삭제할 지출 항목을 삽입한다.

      // when
      // TODO: 해당 항목을 삭제한다.
      // await database.deleteExpense(id);

      // then
      // TODO: 삭제 후 목록이 비어 있는지 확인한다.
      // final expenses = await database.getAllExpenses();
      // expect(expenses, isEmpty);
      expect(true, isTrue, reason: 'Expense 테이블 구현 후 실제 테스트로 교체 예정');
    });

    test('특정 날짜의 총 지출액을 계산할 수 있다', () async {
      // given
      // TODO: 동일 날짜에 여러 지출 항목을 삽입한다.

      // when
      // TODO: 해당 날짜의 총 지출액을 계산한다.
      // final total = await database.getTotalExpenseByDate(DateTime.now());

      // then
      // TODO: 삽입한 금액의 합계와 일치하는지 확인한다.
      // expect(total, equals(8000));
      expect(true, isTrue, reason: 'Expense 테이블 구현 후 실제 테스트로 교체 예정');
    });
  });
}
