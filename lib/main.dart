import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

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
