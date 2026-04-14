import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_stat.freezed.dart';

/// 특정 날짜의 총 지출
/// [date]: 해당 날짜 00:00:00
/// [amount]: 당일 총 지출 (원), 지출 없으면 0
@freezed
sealed class DailyStat with _$DailyStat {
  const factory DailyStat({
    required DateTime date,
    required int amount,
  }) = _DailyStat;
}
