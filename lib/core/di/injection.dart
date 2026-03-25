import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// 전역 GetIt 인스턴스 - 앱 전역에서 의존성 주입에 사용
final getIt = GetIt.instance;

/// 앱 시작 시 모든 의존성을 등록한다.
/// main.dart의 runApp() 호출 전에 반드시 실행되어야 한다.
@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => $initGetIt(getIt);
