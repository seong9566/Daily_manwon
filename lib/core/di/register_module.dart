import 'package:daily_manwon/core/database/app_database.dart';
import 'package:injectable/injectable.dart';

/// 외부 패키지 및 써드파티 의존성을 GetIt에 등록하는 모듈.
/// injectable이 직접 어노테이션할 수 없는 클래스를 여기서 수동 등록한다.
@module
abstract class RegisterModule {
  /// AppDatabase 싱글톤 등록
  /// drift_flutter의 driftDatabase()가 내부적으로 경로를 처리하므로 별도 path 설정 불필요
  @singleton
  AppDatabase get appDatabase => AppDatabase();
}
