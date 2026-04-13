import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_background_callback.dart';
import 'core/services/widget_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 위젯 인터랙티비티 콜백 등록 (백그라운드 지출 저장)
  HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);

  // GetIt DI 초기화
  await configureDependencies();

  // 알림 서비스 초기화 — Android/iOS에서만 실행 (Linux/Windows/macOS 미지원)
  const notifPlatforms = {TargetPlatform.android, TargetPlatform.iOS};
  if (notifPlatforms.contains(defaultTargetPlatform)) {
    await GetIt.instance<NotificationService>().init();
  }

  // 홈 위젯 서비스 초기화
  await GetIt.instance<WidgetService>().init();

  // 온보딩 완료 여부 및 다크모드 설정을 runApp 전에 미리 로드 (첫 프레임 flicker 방지)
  final datasource = GetIt.instance<SettingsLocalDatasource>();
  final isOnboardingCompleted = await datasource.getIsOnboardingCompleted();
  final isDarkMode = await datasource.getIsDarkMode();

  runApp(
    ProviderScope(
      child: DailyManwonApp(
        isOnboardingCompleted: isOnboardingCompleted,
        isDarkMode: isDarkMode,
      ),
    ),
  );
}

class DailyManwonApp extends ConsumerStatefulWidget {
  const DailyManwonApp({
    super.key,
    required this.isOnboardingCompleted,
    required this.isDarkMode,
  });

  final bool isOnboardingCompleted;
  final bool isDarkMode;

  @override
  ConsumerState<DailyManwonApp> createState() => _DailyManwonAppState();
}

class _DailyManwonAppState extends ConsumerState<DailyManwonApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(isOnboardingCompleted: widget.isOnboardingCompleted);
    // runApp 전에 미리 로드한 isDarkMode 값으로 초기 테마를 설정
    Future.microtask(() {
      ref
          .read(appThemeModeProvider.notifier)
          .setMode(widget.isDarkMode ? ThemeMode.dark : ThemeMode.light);
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
