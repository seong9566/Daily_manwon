import 'package:daily_manwon/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// Drift SQLite를 통한 사용자 설정 로컬 접근 객체
/// 단일 row(id=1)로 설정 값을 관리한다
@lazySingleton
class SettingsLocalDatasource {
  final AppDatabase _db;

  SettingsLocalDatasource(this._db);

  /// 다크모드 설정 값을 조회한다 (row가 없으면 false 반환)
  Future<bool> getIsDarkMode() async {
    final row = await (_db.select(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    return row?.isDarkMode ?? false;
  }

  /// 다크모드 설정 값을 upsert한다
  Future<void> setIsDarkMode({required bool value}) async {
    await _db.into(_db.userPreferences).insertOnConflictUpdate(
          UserPreferencesCompanion.insert(
            isDarkMode: Value(value),
          ),
        );
  }
}
