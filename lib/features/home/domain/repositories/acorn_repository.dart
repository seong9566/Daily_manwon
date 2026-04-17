import 'package:daily_manwon/features/home/domain/entities/acorn.dart';

/// 고양이 발도장 저장/조회 Repository 인터페이스 (U-24)
///
/// 구현체: AcornRepositoryImpl (data/repositories)
abstract interface class AcornRepository {
  /// 전체 고양이 발도장 개수를 반환한다
  Future<int> getTotalAcorns();

  /// 고양이 발도장을 추가한다
  ///
  /// [count] 추가할 고양이 발도장 수
  /// [reason] 고양이 발도장 획득 사유 (예: '하루 만원 달성', '5천원 이상 절약 보너스')
  /// [date] 고양이 발도장을 기록할 날짜 (기본값: 오늘)
  Future<void> addAcorn(int count, String reason, {DateTime? date});

  /// 특정 날짜의 고양이 발도장 목록을 반환한다
  Future<List<AcornEntity>> getAcornsByDate(DateTime date);

  /// 오늘부터 과거로 역추적하여 연속 성공 일수를 반환한다
  ///
  /// 연속 성공: 해당 날짜에 도토리가 1개 이상 기록된 경우
  Future<int> getStreakDays();
}
