//
//  BudgetStatus.swift
//  DailyHomeWidget
//

import Foundation

// MARK: - 예산 상태 Enum
enum BudgetStatus {
    case comfortable  // 여유: ≥ 5,000
    case normal       // 주의: 1,000 ~ 4,999
    case danger       // 위험: 0 ~ 999
    case over         // 초과: < 0

    init(remaining: Int) {
        if remaining >= 5000 {
            self = .comfortable
        } else if remaining >= 1000 {
            self = .normal
        } else if remaining >= 0 {
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
