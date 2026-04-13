//
//  FavoriteItem.swift
//  DailyHomeWidget
//

import Foundation

/// 위젯 즐겨찾기 빠른 입력 버튼 데이터 모델
struct FavoriteItem: Codable, Identifiable {
    let id: Int
    /// 지출 금액 (양수값; 음수가 전달되면 formatNumber가 음수 표기를 그대로 표시함)
    let amount: Int
    let category: Int   // ExpenseCategory enum index (0=식비,1=교통,2=카페,3=쇼핑,4=기타)
    let memo: String

    /// 카테고리 index → Asset Catalog 이미지 이름 (앱과 동일한 _clean PNG 사용)
    var categoryAssetName: String {
        switch category {
        case 0: return "CategoryFood"
        case 1: return "CategoryTransport"
        case 2: return "CategoryCoffee"
        case 3: return "CategoryShopping"
        default: return "CategoryEtc"
        }
    }

    /// 금액 포맷 — 1만 이상이면 "1.2만", 미만이면 "3,500"
    var formattedAmount: String {
        if amount >= 10000 {
            let remainder = amount % 10000
            let displayString: String
            if remainder == 0 {
                displayString = "\(amount / 10000)"
            } else {
                displayString = String(format: "%.1f", Double(amount) / 10000)
            }
            return "\(displayString)만"
        }
        return formatNumber(amount)
    }
}
