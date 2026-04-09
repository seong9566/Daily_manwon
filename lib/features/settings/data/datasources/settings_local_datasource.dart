import 'package:daily_manwon/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

/// Drift SQLite를 통한 사용자 설정 로컬 접근 객체
/// 단일 row(id=1)로 설정 값을 관리한다
@lazySingleton
class SettingsLocalDatasource {
  final AppDatabase _db;

  SettingsLocalDatasource(this._db);

  /// id=1 row를 보장한다. 없으면 기본값으로 INSERT, 있으면 기존 row 반환.
  Future<void> _ensureRow() async {
    final row = await (_db.select(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (row == null) {
      await _db.into(_db.userPreferences).insert(
            UserPreferencesCompanion.insert(),
          );
    }
  }

  /// 다크모드 설정 값을 조회한다 (row가 없으면 false 반환)
  Future<bool> getIsDarkMode() async {
    final row = await (_db.select(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    return row?.isDarkMode ?? false;
  }

  /// 다크모드 설정 값을 저장한다 (해당 컬럼만 UPDATE)
  Future<void> setIsDarkMode({required bool value}) async {
    await _ensureRow();
    await (_db.update(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .write(UserPreferencesCompanion(isDarkMode: Value(value)));
  }

  /// 온보딩 완료 여부를 조회한다 (row가 없으면 false 반환)
  Future<bool> getIsOnboardingCompleted() async {
    final row = await (_db.select(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    return row?.isOnboardingCompleted ?? false;
  }

  /// 온보딩 완료 여부를 저장한다 (해당 컬럼만 UPDATE)
  Future<void> setIsOnboardingCompleted({required bool value}) async {
    await _ensureRow();
    await (_db.update(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .write(
            UserPreferencesCompanion(isOnboardingCompleted: Value(value)));
  }

  /// 일일 예산 설정값을 조회한다 (row가 없으면 10000 반환)
  Future<int> getDailyBudget() async {
    final row = await (_db.select(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    return row?.dailyBudget ?? 10000;
  }

  /// 일일 예산 설정값을 저장한다 (해당 컬럼만 UPDATE)
  /// userPreferences 저장 후 오늘 dailyBudgets row가 존재하면 baseAmount도 동기화한다
  Future<void> setDailyBudget(int amount) async {
    await _ensureRow();
    await (_db.update(_db.userPreferences)
          ..where((t) => t.id.equals(1)))
        .write(UserPreferencesCompanion(dailyBudget: Value(amount)));

    // 오늘 예산 row가 이미 생성된 경우 baseAmount를 즉시 반영
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));

    await (_db.update(_db.dailyBudgets)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          ))
        .write(DailyBudgetsCompanion(baseAmount: Value(amount)));
  }
}
