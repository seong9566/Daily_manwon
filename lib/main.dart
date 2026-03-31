import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GetIt DI 초기화 — NotificationService를 포함한 모든 의존성 등록
  await configureDependencies();

  // 알림 서비스 초기화 — Android/iOS/macOS에서만 실행 (Linux/Windows 미지원)
  const notifPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };
  if (notifPlatforms.contains(defaultTargetPlatform)) {
    await GetIt.instance<NotificationService>().init();
  }

  // ProviderScope는 Riverpod 상태관리를 위해 반드시 유지
  runApp(const ProviderScope(child: DailyManwonApp()));
}

/// appThemeModeProvider를 구독하여 다크모드 전환을 실시간 반영한다
/// 라우터는 한 번만 생성하여 GlobalKey 중복 방지
class DailyManwonApp extends ConsumerStatefulWidget {
  const DailyManwonApp({super.key});

  @override
  ConsumerState<DailyManwonApp> createState() => _DailyManwonAppState();
}

class _DailyManwonAppState extends ConsumerState<DailyManwonApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
    // DB에서 저장된 다크모드 설정을 로드
    Future.microtask(() {
      ref.read(appThemeModeProvider.notifier).loadFromDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: '하루 만원',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
