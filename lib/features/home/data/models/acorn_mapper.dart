import 'package:daily_manwon/core/database/app_database.dart';
import 'package:daily_manwon/features/home/domain/entities/acorn.dart';

/// Drift의 Acorn DataClass ↔ AcornEntity 변환 확장
extension AcornMapper on Acorn {
  /// DB 레코드를 도메인 엔티티로 변환
  AcornEntity toEntity() => AcornEntity(
        id: id,
        date: date,
        count: count,
        reason: reason,
      );
}

/// AcornEntity → Drift Insert Companion 변환 확장
/// - 신규 도토리 획득 기록 시 사용
extension AcornEntityMapper on AcornEntity {
  AcornsCompanion toCompanion() => AcornsCompanion.insert(
        date: date,
        count: count,
        reason: reason,
      );
}
