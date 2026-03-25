import 'package:freezed_annotation/freezed_annotation.dart';

part 'acorn.freezed.dart';

@freezed
sealed class AcornEntity with _$AcornEntity {
  const factory AcornEntity({
    required int id,
    required DateTime date,
    required int count,
    required String reason,
  }) = _AcornEntity;
}
