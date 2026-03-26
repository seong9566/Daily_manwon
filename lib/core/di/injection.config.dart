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

import '../../features/calendar/data/datasources/calendar_local_datasource.dart'
    as _i494;
import '../../features/calendar/data/repositories/calendar_repository_impl.dart'
    as _i712;
import '../../features/calendar/domain/repositories/calendar_repository.dart'
    as _i241;
import '../../features/expense/data/datasources/expense_local_datasource.dart'
    as _i272;
import '../../features/expense/data/repositories/expense_repository_impl.dart'
    as _i587;
import '../../features/expense/domain/repositories/expense_repository.dart'
    as _i31;
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
import '../database/app_database.dart' as _i982;
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
  gh.lazySingleton<_i891.DailyBudgetRepository>(
    () => _i180.DailyBudgetRepositoryImpl(
      gh<_i1053.DailyBudgetLocalDatasource>(),
    ),
  );
  gh.lazySingleton<_i241.CalendarRepository>(
    () => _i712.CalendarRepositoryImpl(gh<_i494.CalendarLocalDatasource>()),
  );
  gh.lazySingleton<_i837.AcornRepository>(
    () => _i1051.AcornRepositoryImpl(gh<_i717.AcornLocalDatasource>()),
  );
  gh.lazySingleton<_i31.ExpenseRepository>(
    () => _i587.ExpenseRepositoryImpl(gh<_i272.ExpenseLocalDatasource>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
