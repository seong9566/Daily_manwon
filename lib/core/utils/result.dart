/// 레이어 경계에서 사용하는 커스텀 Result 타입
/// dartz 패키지 대신 sealed class로 직접 구현
sealed class Result<T> {
  const Result();

  /// 성공 결과 생성
  factory Result.success(T data) = Success<T>;

  /// 실패 결과 생성
  factory Result.failure(Failure failure) = Failed<T>;

  /// 패턴 매칭 헬퍼
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failed(failure: final f) => failure(f),
    };
  }

  /// 성공 데이터 추출 (실패 시 null)
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failed() => null,
      };

  /// 성공 여부
  bool get isSuccess => this is Success<T>;
}

/// 성공 결과
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// 실패 결과
final class Failed<T> extends Result<T> {
  final Failure failure;
  const Failed(this.failure);
}

/// 도메인 실패 타입
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// DB 관련 실패
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// 유효성 검사 실패
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 알 수 없는 실패
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다']);
}
