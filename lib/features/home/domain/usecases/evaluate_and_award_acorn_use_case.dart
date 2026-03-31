import 'package:injectable/injectable.dart';

import '../repositories/acorn_repository.dart';
import '../repositories/daily_budget_repository.dart';

/// 전날 예산 결과 평가 및 도토리 지급 UseCase (S-20a)
///
/// - 전날 예산 row가 없으면 스킵
/// - 전날 도토리가 이미 지급됐으면 스킵 (중복 방지)
/// - remaining ≥ 0: 만원 이내 성공 → 도토리 1개
/// - remaining ≥ 5000: 5천원 이상 절약 보너스 → 추가 1개
@lazySingleton
class EvaluateAndAwardAcornUseCase {
  const EvaluateAndAwardAcornUseCase(
    this._budgetRepository,
    this._acornRepository,
  );
  final DailyBudgetRepository _budgetRepository;
  final AcornRepository _acornRepository;

  /// 전날 결과를 평가하고 조건 충족 시 도토리를 지급한다
  Future<void> execute() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    // 전날 예산 row가 없으면 평가 불필요 (첫날 또는 공백일)
    final yesterdayBudget = await _budgetRepository.getBudgetByDate(yesterday);
    if (yesterdayBudget == null) return;

    // 중복 방지: 전날 도토리가 이미 지급됐으면 스킵
    final existingAcorns = await _acornRepository.getAcornsByDate(yesterday);
    if (existingAcorns.isNotEmpty) return;

    final remaining = await _budgetRepository.getRemainingBudget(yesterday);

    if (remaining >= 0) {
      await _acornRepository.addAcorn(1, '하루 만원 달성', date: yesterday);
      if (remaining >= 5000) {
        await _acornRepository.addAcorn(1, '5천원 이상 절약 보너스', date: yesterday);
      }
    }
  }
}
