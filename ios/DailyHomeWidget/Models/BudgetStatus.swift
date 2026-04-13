//
//  BudgetStatus.swift
//  DailyHomeWidget
//

import Foundation

// MARK: - 예산 상태 Enum
// Flutter AppConstants 기준:
//   comfortable : remaining/total ≥ 0.5 (50%)
//   normal      : remaining/total ≥ 0.3 (30%)
//   danger      : remaining/total ≥ 0.0 (0%)
//   over        : remaining/total <  0.0 (음수)
// Swift 위젯은 Flutter가 계산하여 UserDefaults에 기록한 cat_mood를 그대로 사용하므로
// init(catMood:)를 우선 사용한다. init(remaining:total:)은 폴백 전용.
enum BudgetStatus {
    case comfortable
    case normal
    case danger
    case over

    /// Flutter가 전달한 cat_mood 문자열로 상태를 결정한다 (권장).
    /// Flutter와 동일한 비율 기준이 보장된다.
    init(catMood: String) {
        switch catMood {
        case "comfortable", "new_week": self = .comfortable
        case "normal":                  self = .normal
        case "danger":                  self = .danger
        case "over":                    self = .over
        default:                        self = .comfortable
        }
    }

    /// 폴백용: remaining / total 비율로 상태를 결정한다.
    /// Flutter AppConstants와 동일한 임계값(0.5 / 0.3 / 0.0)을 사용한다.
    init(remaining: Int, total: Int) {
        guard total > 0 else {
            self = remaining >= 0 ? .comfortable : .over
            return
        }
        let ratio = Double(remaining) / Double(total)
        if ratio >= 0.5 {
            self = .comfortable
        } else if ratio >= 0.3 {
            self = .normal
        } else if ratio >= 0.0 {
            self = .danger
        } else {
            self = .over
        }
    }

    // 중복 제거: Small/Medium statusMessage 통합
    var statusMessage: String {
        switch self {
        case .comfortable: return "오늘도 잘 하고 있어요"
        case .normal:      return "조금만 더 아껴볼까요?"
        case .danger:      return "위험해요! 아껴쓰세요"
        case .over:        return "예산을 초과했어요"
        }
    }
}
