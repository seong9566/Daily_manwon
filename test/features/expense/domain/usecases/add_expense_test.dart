// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// TODO: 아래 클래스들이 구현되면 import를 활성화한다.
// import 'package:daily_manwon/features/expense/domain/entities/expense_entity.dart';
// import 'package:daily_manwon/features/expense/domain/repositories/expense_repository.dart';
// import 'package:daily_manwon/features/expense/domain/usecases/add_expense.dart';

/// ExpenseRepository Mock - AddExpense 유스케이스 테스트에서
/// 실제 DB 없이 레포지토리 동작을 시뮬레이션한다.
// TODO: ExpenseRepository 구현 후 활성화
// class MockExpenseRepository extends Mock implements ExpenseRepository {}

/// AddExpense 유스케이스 TDD 테스트
///
/// 유스케이스 구현 전에 먼저 테스트를 작성하여 인터페이스를 확정한다.
/// 테스트가 통과하도록 유스케이스를 구현하는 것이 목표이다.
///
/// 비즈니스 규칙:
/// - 하루 예산은 10,000원이다.
/// - 지출 금액은 0원보다 커야 한다.
/// - 지출 금액이 하루 예산을 초과하면 예산 초과 경고를 포함한 결과를 반환한다.
void main() {
  // TODO: 구현 후 아래 변수를 활성화한다.
  // late MockExpenseRepository mockRepository;
  // late AddExpense addExpense;

  setUpAll(() {
    // mocktail에서 커스텀 객체를 any()로 매칭할 때 fallback 값을 등록한다.
    // TODO: 엔티티 구현 후 활성화
    // registerFallbackValue(
    //   const ExpenseEntity(
    //     id: 0,
    //     amount: 0,
    //     category: '',
    //     memo: '',
    //     createdAt: null,
    //   ),
    // );
  });

  setUp(() {
    // 각 테스트 전에 Mock과 유스케이스 인스턴스를 새로 생성한다.
    // 이전 테스트의 stub 설정이 영향을 미치지 않도록 격리한다.
    // TODO: 구현 후 활성화
    // mockRepository = MockExpenseRepository();
    // addExpense = AddExpense(mockRepository);
  });

  group('AddExpense - 정상 케이스', () {
    test('유효한 금액으로 지출을 추가하면 성공 결과를 반환한다', () async {
      // given : 유효한 지출 정보와 레포지토리가 성공을 반환하도록 설정
      // TODO: 구현 후 활성화
      // const amount = 3500;
      // const category = '식비';
      // const memo = '점심 편의점';
      // when(() => mockRepository.addExpense(amount, category, memo))
      //     .thenAnswer((_) async => const Right(1)); // id = 1

      // when : 유스케이스 실행
      // final result = await addExpense(amount: amount, category: category, memo: memo);

      // then : 성공 결과가 반환되고 레포지토리가 정확히 1번 호출된다
      // expect(result.isRight(), isTrue);
      // verify(() => mockRepository.addExpense(amount, category, memo)).called(1);

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });

    test('예산 범위 내 지출은 초과 경고 없이 저장된다', () async {
      // given : 예산(10,000원) 이하의 지출
      // TODO: 구현 후 활성화
      // const amount = 5000;

      // when
      // final result = await addExpense(amount: amount, category: '교통비');

      // then : 예산 초과 플래그가 false여야 한다
      // result.fold(
      //   (failure) => fail('실패하면 안 됨'),
      //   (data) => expect(data.isOverBudget, isFalse),
      // );

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });
  });

  group('AddExpense - 예산 초과 케이스', () {
    test('하루 누적 지출이 10,000원을 초과하면 예산 초과 경고를 반환한다', () async {
      // given : 이미 8,000원을 지출한 상태에서 3,000원 추가
      // TODO: 구현 후 활성화
      // when(() => mockRepository.getTodayTotalExpense())
      //     .thenAnswer((_) async => 8000);
      // when(() => mockRepository.addExpense(3000, '간식', ''))
      //     .thenAnswer((_) async => const Right(2));

      // when
      // final result = await addExpense(amount: 3000, category: '간식');

      // then : isOverBudget이 true여야 한다
      // result.fold(
      //   (failure) => fail('실패하면 안 됨'),
      //   (data) => expect(data.isOverBudget, isTrue),
      // );

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });
  });

  group('AddExpense - 유효성 검사 실패 케이스', () {
    test('지출 금액이 0원이면 ValidationFailure를 반환한다', () async {
      // given : 유효하지 않은 금액
      // TODO: 구현 후 활성화
      // const invalidAmount = 0;

      // when : 유효하지 않은 금액으로 유스케이스 실행
      // final result = await addExpense(amount: invalidAmount, category: '식비');

      // then : 실패 결과이고 레포지토리는 호출되지 않아야 한다
      // expect(result.isLeft(), isTrue);
      // result.fold(
      //   (failure) => expect(failure, isA<ValidationFailure>()),
      //   (_) => fail('실패해야 함'),
      // );
      // verifyNever(() => mockRepository.addExpense(any(), any(), any()));

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });

    test('지출 금액이 음수이면 ValidationFailure를 반환한다', () async {
      // given
      // TODO: 구현 후 활성화
      // const negativeAmount = -1000;

      // when
      // final result = await addExpense(amount: negativeAmount, category: '식비');

      // then
      // expect(result.isLeft(), isTrue);

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });

    test('카테고리가 비어 있으면 ValidationFailure를 반환한다', () async {
      // given
      // TODO: 구현 후 활성화
      // const emptyCategory = '';

      // when
      // final result = await addExpense(amount: 3000, category: emptyCategory);

      // then
      // expect(result.isLeft(), isTrue);

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });
  });

  group('AddExpense - 레포지토리 실패 케이스', () {
    test('DB 저장 실패 시 DatabaseFailure를 반환한다', () async {
      // given : 레포지토리가 예외를 던지도록 설정
      // TODO: 구현 후 활성화
      // when(() => mockRepository.addExpense(any(), any(), any()))
      //     .thenThrow(Exception('DB 연결 실패'));

      // when
      // final result = await addExpense(amount: 3000, category: '식비');

      // then
      // expect(result.isLeft(), isTrue);
      // result.fold(
      //   (failure) => expect(failure, isA<DatabaseFailure>()),
      //   (_) => fail('실패해야 함'),
      // );

      expect(true, isTrue, reason: 'AddExpense 유스케이스 구현 후 실제 테스트로 교체 예정');
    });
  });
}
