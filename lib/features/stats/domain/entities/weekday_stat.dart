import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekday_stat.freezed.dart';

/// 최근 4주 요일별 일평균 지출
/// [weekday]: SQLite strftime('%w') 기준 (0=일, 1=월 … 6=토)
/// [avgAmount]: 해당 요일 일평균 지출 (원, 소수 버림)
@freezed
sealed class WeekdayStat with _$WeekdayStat {
  const factory WeekdayStat({
    required int weekday,
    required int avgAmount,
  }) = _WeekdayStat;
}
