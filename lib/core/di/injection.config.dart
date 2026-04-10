// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/achievement/data/datasources/achievement_local_datasource.dart'
    as _i484;
import '../../features/achievement/data/repositories/achievement_repository_impl.dart'
    as _i640;
import '../../features/achievement/domain/repositories/achievement_repository.dart'
    as _i200;
import '../../features/calendar/data/datasources/calendar_local_datasource.dart'
    as _i494;
import '../../features/calendar/data/repositories/calendar_repository_impl.dart'
    as _i712;
import '../../features/calendar/domain/repositories/calendar_repository.dart'
    as _i241;
import '../../features/calendar/domain/usecases/get_monthly_calendar_data_use_case.dart'
    as _i814;
import '../../features/expense/data/datasources/expense_local_datasource.dart'
    as _i272;
import '../../features/expense/data/repositories/expense_repository_impl.dart'
    as _i587;
import '../../features/expense/domain/repositories/expense_repository.dart'
    as _i31;
import '../../features/expense/domain/usecases/add_expense_use_case.dart'
    as _i367;
import '../../features/expense/domain/usecases/update_expense_use_case.dart'
    as _i920;
import '../../features/home/data/datasources/acorn_local_datasource.dart'
    as _i717;
import '../../features/home/data/datasources/daily_budget_local_datasource.dart'
    as _i1053;
import '../../features/home/data/repositories/acorn_repository_impl.dart'
    as _i1051;
import '../../features/home/data/repositories/daily_budget_repository_impl.dart'
    as _i180;
import '../../features/home/domain/repositories/acorn_repository.dart' as _i837;
import '../../features/home/domain/repositories/daily_budget_repository.dart'
    as _i891;
import '../../features/home/domain/usecases/check_and_award_title_use_case.dart'
    as _i486;
import '../../features/home/domain/usecases/delete_expense_use_case.dart'
    as _i1008;
import '../../features/home/domain/usecases/evaluate_and_award_acorn_use_case.dart'
    as _i497;
import '../../features/home/domain/usecases/get_acorn_stats_use_case.dart'
    as _i1018;
import '../../features/home/domain/usecases/get_today_budget_use_case.dart'
    as _i597;
import '../../features/home/domain/usecases/get_today_expenses_use_case.dart'
    as _i578;
import '../../features/settings/data/datasources/notification_settings_datasource.dart'
    as _i972;
import '../../features/settings/data/datasources/settings_local_datasource.dart'
    as _i723;
import '../../features/settings/data/repositories/notification_settings_repository_impl.dart'
    as _i414;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/notification_settings_repository.dart'
    as _i91;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/get_notification_settings_use_case.dart'
    as _i1007;
import '../../features/settings/domain/usecases/save_notification_settings_use_case.dart'
    as _i836;
import '../database/app_database.dart' as _i982;
import '../services/notification_service.dart' as _i941;
import '../services/widget_service.dart' as _i511;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.singleton<_i982.AppDatabase>(() => registerModule.appDatabase);
  gh.lazySingleton<_i941.NotificationService>(
    () => _i941.NotificationService(),
  );
  gh.lazySingleton<_i511.WidgetService>(() => _i511.WidgetService());
  gh.lazySingleton<_i484.AchievementLocalDatasource>(
    () => _i484.AchievementLocalDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i494.CalendarLocalDatasource>(
    () => _i494.CalendarLocalDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i272.ExpenseLocalDatasource>(
    () => _i272.ExpenseLocalDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i717.AcornLocalDatasource>(
    () => _i717.AcornLocalDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i1053.DailyBudgetLocalDatasource>(
    () => _i1053.DailyBudgetLocalDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i972.NotificationSettingsDatasource>(
    () => _i972.NotificationSettingsDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i723.SettingsLocalDatasource>(
    () => _i723.SettingsLocalDatasource(gh<_i982.AppDatabase>()),
  );
  gh.lazySingleton<_i200.AchievementRepository>(
    () =>
        _i640.AchievementRepositoryImpl(gh<_i484.AchievementLocalDatasource>()),
  );
  gh.lazySingleton<_i674.SettingsRepository>(
    () => _i955.SettingsRepositoryImpl(gh<_i723.SettingsLocalDatasource>()),
  );
  gh.lazySingleton<_i891.DailyBudgetRepository>(
    () => _i180.DailyBudgetRepositoryImpl(
      gh<_i1053.DailyBudgetLocalDatasource>(),
    ),
  );
  gh.lazySingleton<_i486.CheckAndAwardTitleUseCase>(
    () => _i486.CheckAndAwardTitleUseCase(gh<_i200.AchievementRepository>()),
  );
  gh.lazySingleton<_i91.NotificationSettingsRepository>(
    () => _i414.NotificationSettingsRepositoryImpl(
      gh<_i972.NotificationSettingsDatasource>(),
    ),
  );
  gh.lazySingleton<_i597.GetTodayBudgetUseCase>(
    () => _i597.GetTodayBudgetUseCase(
      gh<_i891.DailyBudgetRepository>(),
      gh<_i674.SettingsRepository>(),
    ),
  );
  gh.lazySingleton<_i241.CalendarRepository>(
    () => _i712.CalendarRepositoryImpl(gh<_i494.CalendarLocalDatasource>()),
  );
  gh.lazySingleton<_i1007.GetNotificationSettingsUseCase>(
    () => _i1007.GetNotificationSettingsUseCase(
      gh<_i91.NotificationSettingsRepository>(),
    ),
  );
  gh.lazySingleton<_i836.SaveNotificationSettingsUseCase>(
    () => _i836.SaveNotificationSettingsUseCase(
      gh<_i91.NotificationSettingsRepository>(),
    ),
  );
  gh.lazySingleton<_i837.AcornRepository>(
    () => _i1051.AcornRepositoryImpl(gh<_i717.AcornLocalDatasource>()),
  );
  gh.lazySingleton<_i1018.GetAcornStatsUseCase>(
    () => _i1018.GetAcornStatsUseCase(gh<_i837.AcornRepository>()),
  );
  gh.lazySingleton<_i31.ExpenseRepository>(
    () => _i587.ExpenseRepositoryImpl(gh<_i272.ExpenseLocalDatasource>()),
  );
  gh.lazySingleton<_i367.AddExpenseUseCase>(
    () => _i367.AddExpenseUseCase(gh<_i31.ExpenseRepository>()),
  );
  gh.lazySingleton<_i920.UpdateExpenseUseCase>(
    () => _i920.UpdateExpenseUseCase(gh<_i31.ExpenseRepository>()),
  );
  gh.lazySingleton<_i1008.DeleteExpenseUseCase>(
    () => _i1008.DeleteExpenseUseCase(gh<_i31.ExpenseRepository>()),
  );
  gh.lazySingleton<_i578.GetTodayExpensesUseCase>(
    () => _i578.GetTodayExpensesUseCase(gh<_i31.ExpenseRepository>()),
  );
  gh.lazySingleton<_i814.GetMonthlyCalendarDataUseCase>(
    () => _i814.GetMonthlyCalendarDataUseCase(gh<_i241.CalendarRepository>()),
  );
  gh.lazySingleton<_i497.EvaluateAndAwardAcornUseCase>(
    () => _i497.EvaluateAndAwardAcornUseCase(
      gh<_i891.DailyBudgetRepository>(),
      gh<_i837.AcornRepository>(),
    ),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
