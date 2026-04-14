import 'package:injectable/injectable.dart';

import '../../../settings/domain/repositories/settings_repository.dart';

/// DB에 저장된 유저 일일 예산을 조회한다.
/// 설정값이 없으면 AppConstants.dailyBudget(10,000) 기본값을 반환한다.
@lazySingleton
class GetDailyBudgetUseCase {
  final SettingsRepository _repository;

  GetDailyBudgetUseCase(this._repository);

  Future<int> execute() => _repository.getDailyBudget();
}
