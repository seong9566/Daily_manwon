import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GetIt DI 초기화
  await configureDependencies();

  // 알림 서비스 초기화 — Android/iOS에서만 실행 (Linux/Windows/macOS 미지원)
  const notifPlatforms = {TargetPlatform.android, TargetPlatform.iOS};
  if (notifPlatforms.contains(defaultTargetPlatform)) {
    await GetIt.instance<NotificationService>().init();
  }

  // 홈 위젯 서비스 초기화
  await GetIt.instance<WidgetService>().init();

  // 온보딩 완료 여부 확인
  final isOnboardingCompleted = await GetIt.instance<SettingsLocalDatasource>()
      .getIsOnboardingCompleted();

  runApp(ProviderScope(
    child: DailyManwonApp(isOnboardingCompleted: isOnboardingCompleted),
  ));
}

class DailyManwonApp extends ConsumerStatefulWidget {
  const DailyManwonApp({super.key, required this.isOnboardingCompleted});

  final bool isOnboardingCompleted;

  @override
  ConsumerState<DailyManwonApp> createState() => _DailyManwonAppState();
}

class _DailyManwonAppState extends ConsumerState<DailyManwonApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(
        isOnboardingCompleted: widget.isOnboardingCompleted);
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
